variable "aks_managed_identity" {
  description = "AKS Azure AD managed identity"
  type        = string
}

variable "aks_name" {
  description = "The commonName to use for the deploy"
  type        = string
}

variable "aks_name_suffix" {
  description = "The suffix for the aks clusters"
  type        = number
}

variable "cluster_id" {
  description = "Unique identifier of the cluster across regions and instances."
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "location" {
  description = "The Azure region name."
  type        = string
}

variable "location_short" {
  description = "The Azure region short name."
  type        = string
}

variable "oidc_issuer_url" {
  description = "Kubernetes OIDC issuer URL for workload identity."
  type        = string
}

variable "podmonitor_loadbalancer" {
  description = "Enable podmonitor for loadbalancers?"
  type        = bool
  default     = true
}

variable "podmonitor_kubernetes" {
  description = "Enable podmonitor for kubernetes?"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "The Azure resource group name"
  type        = string
}

variable "subscription_id" {
  description = "The subscription id where your kubernetes cluster is deployed"
  type        = string
}