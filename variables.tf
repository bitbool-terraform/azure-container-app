# General
variable "project" {}
variable "systemenv" {}
variable "location" {}
variable "resource_group" {}



# Container app object

variable "app_name" {}
variable "app_env" {}
variable "app_image" {}
variable "app_command" { default = null }
variable "app_volumes" { default = null }
variable "app_secrets" { default = null }
variable "app_ingress_enabled" { default = true }

variable "appgw_hostname_override" { default = false }




variable "app_gw" {  default = null  }
variable "workload_profile" {}
variable "container_app_environment_id" {}

variable "cpu" { default = 0.25 }
variable "memory" { default = "0.5Gi" }
variable "max_replicas" { default = 1 }
variable "min_replicas" { default = 1 }

variable "environment" {}

variable "identities" { default = null }


variable "target_port" { default = 80 }




# Config Defaults
variable "revision_mode" { default = "Single" }

