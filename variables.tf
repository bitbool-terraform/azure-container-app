variable "container_app" {}



variable "location" {}
variable "resource_group" {}


variable "app_identity_ids" { default = [] }


variable "name" {}

variable "workload_profile" {}

# New to defaults
variable "image_default" { default = "nginx:latest" }
variable "command_default" { default = null }
variable "revision_mode_default" { default = "Single" }
variable "tags_default" { default = null }

variable "max_replicas_default" { default = 1 }
variable "min_replicas_default" { default = 1 }

variable "custom_scale_rules_default" { default = {} }
variable "http_scale_rules_default" { default = {} }

variable "cpu_default" { default = 0.25 }
variable "memory_default" { default = "0.5Gi" }



#########################-----------OLD
# General



# variable "identity_default" { default = null }
variable "app_ingress_enabled" { default = true }

variable "appgw_hostname_override" { default = false }




variable "app_gw" {  default = null  }

variable "container_app_environment_id" {}





variable "app_env" {
  type = map(string)
  default = {}
}




# variable "identity_use_system_assigned" { default = false } #TODO


variable "target_port" { default = 80 }
variable "registry" { default = null }





# Config Defaults



# Probes
variable "liveness_probe" { default = {} }
variable "liveness_probe_defaults" {
                      default = {
                          port = 80
                          transport = "HTTP"
                          failure_count_threshold = 3
                          initial_delay = 60
                          interval_seconds = 30
                          path = "/"
                          timeout = 20
                      } 
                          }

variable "readiness_probe" { default = {} }
variable "readiness_probe_defaults" {
                      default = {
                          port = 80
                          transport = "HTTP"
                          failure_count_threshold = 3
                          initial_delay = 60
                          interval_seconds = 30
                          path = "/"
                          timeout = 20
                          success_count_threshold = 3
                      } 
                          }

variable "startup_probe" { default = {} }
variable "startup_probe_defaults" {
                      default = {
                          port = 80
                          transport = "HTTP"
                          failure_count_threshold = 3
                          initial_delay = 60
                          interval_seconds = 30
                          path = "/"
                          timeout = 20
                      } 
                          }


