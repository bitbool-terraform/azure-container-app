resource "azurerm_container_app" "container_app" {
  
  container_app_environment_id = var.container_app_environment_id
  name                         = var.app_name
  resource_group_name          = var.resource_group
  revision_mode                = var.revision_mode
  tags                         = var.tags
  workload_profile_name        = var.workload_profile


  dynamic "secret" {
    for_each = local.secrets_all

    content {
      name                =  secret.value.secret_name
      identity            =  secret.value.identity_id
      key_vault_secret_id =  secret.value.key_vault_secret_id
    }
  }


  template {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas

  container {

        name    = var.app_name
        
        image   = var.app_image
        command = var.app_command

        cpu     = var.cpu
        memory  = var.memory


        dynamic "env" {
          for_each = var.app_env

          content {
            name  = env.key
            value = env.value
          }
        }


        dynamic "env" { # secrets
          for_each = local.secrets_all

          content {
            name        = env.value.envvar_name
            secret_name = env.value.secret_name
          }
        }

        dynamic "liveness_probe" {
          for_each = lookup(var.liveness_probe,"enabled",false) == true ? [var.liveness_probe] : []

          content {
            port                    = lookup(var.liveness_probe,"port",var.liveness_probe_defaults.port)
            transport               = lookup(var.liveness_probe,"transport",var.liveness_probe_defaults.transport)
            failure_count_threshold = lookup(var.liveness_probe,"failure_count_threshold",var.liveness_probe_defaults.failure_count_threshold)
            host                    = lookup(var.liveness_probe,"host",null)
            initial_delay           = lookup(var.liveness_probe,"initial_delay",var.liveness_probe_defaults.initial_delay)
            interval_seconds        = lookup(var.liveness_probe,"interval_seconds",var.liveness_probe_defaults.interval_seconds)
            path                    = lookup(var.liveness_probe,"path",var.liveness_probe_defaults.path)
            timeout                 = lookup(var.liveness_probe,"timeout",var.liveness_probe_defaults.timeout)

            dynamic "header" {
              for_each = lookup(var.liveness_probe,"headers",null) != null ? var.liveness_probe.headers : {}

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        # dynamic "readiness_probe" {
        #   for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]

        #   content {
        #     port                    = readiness_probe.value.port
        #     transport               = readiness_probe.value.transport
        #     failure_count_threshold = readiness_probe.value.failure_count_threshold
        #     host                    = readiness_probe.value.host
        #     interval_seconds        = readiness_probe.value.interval_seconds
        #     path                    = readiness_probe.value.path
        #     success_count_threshold = readiness_probe.value.success_count_threshold
        #     timeout                 = readiness_probe.value.timeout

        #     dynamic "header" {
        #       for_each = readiness_probe.value.header == null ? [] : [readiness_probe.value.header]

        #       content {
        #         name  = header.value.name
        #         value = header.value.value
        #       }
        #     }
        #   }
        # }
        # dynamic "startup_probe" {
        #   for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]

        #   content {
        #     port                    = startup_probe.value.port
        #     transport               = startup_probe.value.transport
        #     failure_count_threshold = startup_probe.value.failure_count_threshold
        #     host                    = startup_probe.value.host
        #     interval_seconds        = startup_probe.value.interval_seconds
        #     path                    = startup_probe.value.path
        #     timeout                 = startup_probe.value.timeout

        #     dynamic "header" {
        #       for_each = startup_probe.value.header == null ? [] : [startup_probe.value.header]

        #       content {
        #         name  = header.value.name
        #         value = header.value.name
        #       }
        #     }
        #   }
        # }

  }
  }

  dynamic "identity" {
    for_each = var.identity_use_system_assigned == true ||  var.identities != null ? [var.identity_use_system_assigned] : []
    content {
      type         = var.identity_use_system_assigned == true ? var.identities != null ? "SystemAssigned, UserAssigned" : "SystemAssigned" : var.identities != null ? "UserAssigned" : null
      identity_ids = local.app_identity_ids
    }
  }


  dynamic "ingress" {
    for_each = var.app_ingress_enabled == false ? [] : [var.app_ingress_enabled]

    content {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = var.target_port

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
  }

  # dynamic "ingress" {
  #   for_each = each.value.ingress == null ? [] : [each.value.ingress]

  #   content {
  #     target_port                = ingress.value.target_port
  #     allow_insecure_connections = ingress.value.allow_insecure_connections
  #     external_enabled           = ingress.value.external_enabled
  #     transport                  = ingress.value.transport

  #     dynamic "traffic_weight" {
  #       for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

  #       content {
  #         percentage      = traffic_weight.value.percentage
  #         label           = traffic_weight.value.label
  #         latest_revision = traffic_weight.value.latest_revision
  #         revision_suffix = traffic_weight.value.revision_suffix
  #       }
  #     }

  #   }
  # }


  # dynamic "registry" {
  #   for_each = each.value.registry == null ? [] : each.value.registry

  #   content {
  #     server               = registry.value.server
  #     identity             = registry.value.identity
  #     password_secret_name = registry.value.password_secret_name
  #     username             = registry.value.username
  #   }
  # }

}

resource "azurerm_container_app_custom_domain" "custom_domain" {
  count = var.appgw_hostname_override ? 0 : 1

  name                                     = var.app_gw.hostname
  container_app_id                         = azurerm_container_app.container_app.id
}
