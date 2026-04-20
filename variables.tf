variable "billing_scope_id" {
  description = "(Required) The Billing Scope ID for the Microsoft Customer Agreement (MCA) where the subscriptions will be created."
  type        = string
  sensitive   = true
}

variable "root_name" {
  description = "(Required) Will set a custom Display Name value for the Enterprise-scale root Management Group."
  type        = string
}

variable "root_parent_id" {
  description = "(Required) The root_parent_id is used to specify where to set the root for all Landing Zone deployments. Usually the Tenant ID when deploying the core Enterprise-scale Landing Zones."
  type        = string
}

variable "subscription_id" {
  description = "(Required) Azure Subscription ID for the provider to authenticate against."
  type        = string
}

variable "tenant_id" {
  description = "(Required) Azure Tenant ID for the provider to authenticate against."
  type        = string
}
