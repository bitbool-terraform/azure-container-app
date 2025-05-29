resource "azurerm_container_app" "container_app" {
  
  container_app_environment_id = var.container_app_environment_id
  name                         = format("%s-%s",local.name_prefix,var.app_name)
  resource_group_name          = var.resource_group
  revision_mode                = var.revision_mode
  tags                         = {} #TODO
  workload_profile_name        = var.workload_profile

  # dynamic "secret" {
  #   for_each = 

  #   content {
  #     name                =  #TODO
  #     identity            =  #TODO
  #     key_vault_secret_id =  #TODO
  #   }
  # }
  template {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas



    # dynamic "volume" {
    #   for_each = var.app_volumes

    #   content {
    #     name         = volume.key
    #     storage_name = #TODO
    #     storage_type = #TODO
    #   }
    # }



  container {

        name    = format("%s-%s",local.name_prefix,var.app_name)
        
        image   = var.app_image
        command = var.app_command

        cpu     = var.cpu
        memory  = var.memory



        dynamic "env" { #env vars
          for_each = var.environment

          content {
            name        = env.key
            value       = env.value
          }
        }


        # dynamic "env" { #secrets
        #   for_each = container.value.env == null ? [] : container.value.env

        #   content {
        #     name        = env.value.name
        #     secret_name = env.value.secret_name
        #     value       = env.value.value
        #   }
        # }




        # dynamic "liveness_probe" {
        #   for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]

        #   content {
        #     port                    = liveness_probe.value.port
        #     transport               = liveness_probe.value.transport
        #     failure_count_threshold = liveness_probe.value.failure_count_threshold
        #     host                    = liveness_probe.value.host
        #     initial_delay           = liveness_probe.value.initial_delay
        #     interval_seconds        = liveness_probe.value.interval_seconds
        #     path                    = liveness_probe.value.path
        #     timeout                 = liveness_probe.value.timeout

        #     dynamic "header" {
        #       for_each = liveness_probe.value.header == null ? [] : [liveness_probe.value.header]

        #       content {
        #         name  = header.value.name
        #         value = header.value.value
        #       }
        #     }
        #   }
        # }
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


        # dynamic "volume_mounts" {
        #   for_each = container.value.volume_mounts == null ? [] : container.value.volume_mounts

        #   content {
        #     name = volume_mounts.value.name
        #     path = volume_mounts.value.path
        #   }
        # }
  }
  }

  # dynamic "identity" {
  #   for_each = var.identities #needs data source to retrieve IDs

  #   content {
  #     type         = identity.value.type
  #     identity_ids = identity.value.identity_ids
  #   }
  # }

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
