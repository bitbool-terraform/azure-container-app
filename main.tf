resource "azurerm_container_app" "container_app" {
  
  name                         = var.container_app.name
  resource_group_name          = var.container_app.resource_group
  container_app_environment_id = var.container_app.environment_id
  revision_mode                = lookup(var.container_app,"revision_mode",var.revision_mode_default)
  tags                         = lookup(var.container_app,"tags",var.tags_default)
  workload_profile_name        = var.container_app.workload_profile

  dynamic "secret" {
    for_each = local.secrets_for_secret

    content {
      name                =  secret.value.secret_name
      identity            =  secret.value.identity_id
      key_vault_secret_id =  secret.value.secret_id
    }
  }

  template {
    max_replicas    = lookup(var.container_app,"max_replicas",var.max_replicas_default)
    min_replicas    = lookup(var.container_app,"min_replicas",var.min_replicas_default)

    dynamic "volume" {
      for_each = lookup(var.container_app,"volumes",{})
      content {
        name         = volume.key
        storage_name = volume.value.storage_name
        storage_type = lookup(volume.value,"storage_type", "AzureFile")
      }
    }

    dynamic "custom_scale_rule" {
      for_each = lookup(var.container_app,"custom_scale_rules",var.custom_scale_rules_default)

      content {
        name             = custom_scale_rule.key
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata
      }
    }

    dynamic "http_scale_rule" {
      for_each = lookup(var.container_app,"http_scale_rules",var.http_scale_rules_default)

      content {
        name                = http_scale_rule.key
        concurrent_requests = http_scale_rule.value.concurrent_requests

      }
    }

  container {
        name    = var.container_app.name
        
        image   = lookup(var.container_app,"image",var.image_default)
        command = lookup(var.container_app,"command",var.command_default)
        args    = lookup (var.container_app,"args",null)

        cpu     = lookup(var.container_app,"cpu",var.cpu_default)
        memory  = lookup(var.container_app,"memory",var.memory_default)

        dynamic "env" {
          for_each = lookup(var.container_app,"env_vars",{})

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" { # secrets
          for_each = local.secrets_for_env

          content {
            name        = env.value.envvar_name
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = lookup(var.container_app,"volumes",{})
          content {
            name = volume_mounts.key
            path = volume_mounts.value.path
          }
        }

        dynamic "liveness_probe" {
          for_each = lookup(lookup(var.container_app,"liveness_probe",{}),"enabled",var.liveness_probe_defaults.enabled) == true ? [1] : []
          content {
            port                    = try(var.container_app.liveness_probe.port,var.container_app.ingress.target_port,var.liveness_probe_defaults.port)
            transport               = lookup(lookup(var.container_app,"liveness_probe",{}),"transport",var.liveness_probe_defaults.transport)
            failure_count_threshold = lookup(lookup(var.container_app,"liveness_probe",{}),"failure_count_threshold",var.liveness_probe_defaults.failure_count_threshold)
            host                    = lookup(lookup(var.container_app,"liveness_probe",{}),"host",null)
            initial_delay           = lookup(lookup(var.container_app,"liveness_probe",{}),"initial_delay",var.liveness_probe_defaults.initial_delay)
            interval_seconds        = lookup(lookup(var.container_app,"liveness_probe",{}),"interval_seconds",var.liveness_probe_defaults.interval_seconds)
            path                    = lookup(lookup(var.container_app,"liveness_probe",{}),"transport",var.liveness_probe_defaults.transport) == "TCP" ? null : lookup(lookup(var.container_app,"liveness_probe",{}),"path",var.liveness_probe_defaults.path)
            timeout                 = lookup(lookup(var.container_app,"liveness_probe",{}),"timeout",var.liveness_probe_defaults.timeout)

            dynamic "header" {
              for_each = lookup(lookup(var.container_app,"liveness_probe",{}),"headers",null) != null ? var.container_app.liveness_probe.headers : {}

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = lookup(lookup(var.container_app,"readiness_probe",{}),"enabled",var.readiness_probe_defaults.enabled) == true ? [1] : []
          content {
            port                    = try(var.container_app.readiness_probe.port,var.container_app.ingress.target_port,var.readiness_probe_defaults.port)
            transport               = lookup(lookup(var.container_app,"readiness_probe",{}),"transport",var.readiness_probe_defaults.transport)
            failure_count_threshold = lookup(lookup(var.container_app,"readiness_probe",{}),"failure_count_threshold",var.readiness_probe_defaults.failure_count_threshold)
            host                    = lookup(lookup(var.container_app,"readiness_probe",{}),"host",null)
            initial_delay           = lookup(lookup(var.container_app,"readiness_probe",{}),"initial_delay",var.readiness_probe_defaults.initial_delay)
            interval_seconds        = lookup(lookup(var.container_app,"readiness_probe",{}),"interval_seconds",var.readiness_probe_defaults.interval_seconds)
            path                    = lookup(lookup(var.container_app,"readiness_probe",{}),"transport",var.readiness_probe_defaults.transport) == "TCP" ? null : lookup(lookup(var.container_app,"readiness_probe",{}),"path",var.readiness_probe_defaults.path)
            success_count_threshold = lookup(lookup(var.container_app,"readiness_probe",{}),"success_count_threshold",var.readiness_probe_defaults.success_count_threshold)
            timeout                 = lookup(lookup(var.container_app,"readiness_probe",{}),"timeout",var.readiness_probe_defaults.timeout)

            dynamic "header" {
              for_each = lookup(lookup(var.container_app,"readiness_probe",{}),"headers",null) != null ? var.container_app.readiness_probe.headers : {}

              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = lookup(lookup(var.container_app,"startup_probe",{}),"enabled",var.startup_probe_defaults.enabled) == true ? [1] : []

          content {
            port                    = try(var.container_app.startup_probe.port,var.container_app.ingress.target_port,var.startup_probe_defaults.port)
            transport               = lookup(lookup(var.container_app,"startup_probe",{}),"transport",var.startup_probe_defaults.transport)
            failure_count_threshold = lookup(lookup(var.container_app,"startup_probe",{}),"failure_count_threshold",var.startup_probe_defaults.failure_count_threshold)
            host                    = lookup(lookup(var.container_app,"startup_probe",{}),"host",null)
            initial_delay           = lookup(lookup(var.container_app,"startup_probe",{}),"initial_delay",var.startup_probe_defaults.initial_delay)
            interval_seconds        = lookup(lookup(var.container_app,"startup_probe",{}),"interval_seconds",var.startup_probe_defaults.interval_seconds)
            path                    = lookup(lookup(var.container_app,"startup_probe",{}),"transport",var.startup_probe_defaults.transport) == "TCP" ? null : lookup(lookup(var.container_app,"startup_probe",{}),"path",var.startup_probe_defaults.path)
            timeout                 = lookup(lookup(var.container_app,"startup_probe",{}),"timeout",var.startup_probe_defaults.timeout)

            dynamic "header" {
              for_each = lookup(lookup(var.container_app,"startup_probe",{}),"headers",null) != null ? var.container_app.startup_probe.headers : {}

              content {
                name  = header.value.name
                value = header.value.name
              }
            }
          }
        }

  }
  }

    lifecycle {
    ignore_changes = [
      template[0].container[0].image,
      ingress[0].client_certificate_mode #TODO set to override lack of ingress UI setting "Session affinity". Revisit in future provider versions, maybe they'll fix it...
    ]
  }

  dynamic "identity" {
    for_each = length(lookup(var.container_app, "identity_ids", var.identity_ids_default)) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = toset(lookup(var.container_app, "identity_ids", var.identity_ids_default))
    }
  }
  # dynamic "identity" {
  #   for_each = var.identity_use_system_assigned == true ||  var.identities != null ? ["run"] : []
  #   content {
  #     type         = var.identity_use_system_assigned == true ? (var.identities != null ? "SystemAssigned, UserAssigned" : "SystemAssigned") : var.identities != null ? "UserAssigned" : null
  #     identity_ids = local.identities_full_list
  #   }
  # }

  dynamic "ingress" {
    for_each = lookup(var.container_app.ingress,"enabled",var.ingress_enabled_default) == false ? [] : [var.ingress_enabled_default]

    content {
      allow_insecure_connections = true
      external_enabled           = true
      target_port                = lookup(var.container_app.ingress,"target_port",var.target_port_default)

      traffic_weight {
        percentage = 100
        latest_revision = true
      }
    }
  }

  dynamic "registry" {
    for_each = lookup(var.container_app,"registry",null) != null ? ["run"] : []

    content {
      server               = var.container_app.registry.server
      identity             = lookup(var.container_app.registry,"identity_id",local.identity_id_default)
      password_secret_name = lookup(var.container_app.registry,"password_secret_name",null)
      username             = lookup(var.container_app.registry,"username",null)
    }
  }
}


resource "azurerm_container_app_custom_domain" "custom_domain" {
  count = lookup(var.container_app.ingress,"hostname_override",false) ? 0 : length(flatten([var.container_app.ingress.hostname]))

  name                                     = flatten([var.container_app.ingress.hostname])[count.index]
  container_app_id                         = azurerm_container_app.container_app.id
  # certificate_binding_type                 = "Disabled"
  certificate_binding_type                 = lookup(var.container_app.ingress,"certificate_binding_type","Disabled")
  container_app_environment_certificate_id = lookup(var.container_app.ingress,"container_app_environment_certificate_id",null)
}
