variable "container_app" {}

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
variable "identity_ids_default" { default = [] }

variable "ingress_enabled_default" { default = true }

variable "secrets_as_list" { default = false }

# Probes
variable "liveness_probe" { default = {} }
variable "liveness_probe_defaults" {
    default = {
        port = 80
        transport = "HTTP"
        failure_count_threshold = 6
        initial_delay = 10
        interval_seconds = 30
        path = "/"
        timeout = 5
    } 
        }

variable "readiness_probe" { default = {} }
variable "readiness_probe_defaults" {
    default = {
        port = 80
        transport = "HTTP"
        failure_count_threshold = 6
        initial_delay = 10
        interval_seconds = 30
        path = "/"
        timeout = 5
        success_count_threshold = 1
    } 
        }

variable "startup_probe" { default = {} }
variable "startup_probe_defaults" {
        default = {
            port = 80
            transport = "HTTP"
            failure_count_threshold = 20
            initial_delay = 5
            interval_seconds = 5
            path = "/"
            timeout = 5
    } 
        }
