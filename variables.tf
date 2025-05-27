# General
variable "project" {}
variable "systemenv" {}
variable "location" {}
variable "resource_group" {}



# Container app object

variable "app_name" {}
variable "app_env" {}
variable "app_image" {}
variable "app_volumes" {}
variable "app_ingress_enabled" {}
variable "app_ingress" {}
variable "workload_profile" {}

variable "environment" {}




# Config Defaults
variable "revision_mode" { default = "Single" }
