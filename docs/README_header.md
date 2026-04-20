# Azure Management Groups and Subscriptions

This project is responsible for provisioning the core Azure Management Groups and baseline Subscriptions required for the Landing Zone. It defines the core platform Enterprise-scale management groups and hierarchy according to the Cloud Adoption Framework (CAF) and automatically provisions and associates required workload subscriptions (Identity, Management, Connectivity) to their respective management groups.

## Cloud Adoption Framework - Level 1: Core Platform

This repository focuses on **Level 1** of the Cloud Adoption Framework (CAF), provisioning the **Core platform: Enterprise-Scale management groups, Identity, and Subscriptions**. 

Due to technical limitations and state management considerations within Terraform, the configuration of Azure Policies and identity access (Service Principals/RBAC) has been split from this codebase into dedicated repositories. This workspace cleanly exposes the necessary subscription outputs for those downstream repositories to consume.

![Cloud Adoption Framework Levels](./media/caf-hierarchy-levels.png)

## Management Group Structure

The following diagram illustrates the specific Management Group hierarchy provisioned by this Terraform configuration.

![Management Group Structure](./media/sub-organization.png)

## Permissions

The following permissions are required to apply this configuration:
- **AzureRM (Management Groups)**: `Management Group Contributor` or `Owner` on the Tenant Root Management Group.
- **AzureRM (Subscriptions)**: `Azure Subscription Creator` role or explicit permissions on the Microsoft Customer Agreement (MCA) Invoice Section/Billing Profile to provision new subscriptions.

## Authentications

Authentication to Azure can be configured using one of the following methods, with Dynamic Provider Credentials (OIDC) being the recommended approach for automation.

### Dynamic Provider Credentials (OIDC) - Preferred

Use OIDC for secure, passwordless authentication from your CI/CD pipelines (e.g., HCP Terraform Workspaces, GitHub Actions, GitLab CI).

- **Inside the provider block**
  ```hcl
  provider "azurerm" {
    features {}
    
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id

    use_oidc = true
    use_cli  = false
  }
  ```

- **Using HCP Terraform Workspace variables**
  - `TFC_AZURE_PROVIDER_AUTH=true`
  - `TFC_AZURE_RUN_CLIENT_ID`

### Service Principal and Client Secret

Use an Azure AD service principal for non-interactive runs if OIDC is unavailable.

- **Inside the provider block**
  ```hcl
  provider "azurerm" {
    features {}
    
    subscription_id = "<subscription-id>"
    tenant_id       = "<tenant-id>"
    client_id       = "<client-id>"
    client_secret   = "<client-secret>"
  }
  ```

- **Using environment variables**
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`

Documentation:
- [Authenticating to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [Dynamic Provider Credentials (OIDC)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
- [HCP Terraform Dynamic Credentials with Azure](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/azure-configuration)

## Features

- Manages up to 6 levels of Azure Management Group hierarchies dynamically.
- Automatically handles dependencies between parent and child management groups through local variable evaluation.
- Dynamically provisions new Azure Subscriptions for core workloads (e.g., Identity, Management, Connectivity) using MCA Billing Scope IDs.
- Automatically associates provisioned subscriptions to their respective Management Groups.
