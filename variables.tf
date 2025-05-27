# General
variable "project" {}
variable "systemenv" {}
variable "location" {}
variable "resource_group" {}
variable "vnet" {}

variable "create_env" { default = false}

# Container app Env app object
variable "env_name" {}
variable "env_subnet" {}
variable "workload_profiles" {}


# Container app object

variable "app_name" {}
variable "app_env" {}
variable "app_image" {}
variable "app_volume_mounts" {}
variable "app_ingress_enabled" {}
variable "app_ingress" {}




# Config Defaults
variable "internal_load_balancer_enabled" { default = false}
variable "zone_redundancy_enabled" { default = false}
variable "logs_destination" { default = "azure-monitor" }
