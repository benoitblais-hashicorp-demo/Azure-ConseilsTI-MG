# The following resource blocks and for_each logic are used to ensure Management Group deployment respects the
# hierarchical dependencies between Management Groups and their parents. A local variable is used to merge the
# response from each block to return the configuration data in a single object.
# Azure only supports a Management Group depth of 6 levels.

resource "azurerm_management_group" "level_1" {
  for_each = local.azurerm_management_group_level_1

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

}

resource "azurerm_management_group" "level_2" {
  for_each = local.azurerm_management_group_level_2

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

  depends_on = [azurerm_management_group.level_1]

}

resource "azurerm_management_group" "level_3" {
  for_each = local.azurerm_management_group_level_3

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

  depends_on = [azurerm_management_group.level_2]

}

resource "azurerm_management_group" "level_4" {
  for_each = local.azurerm_management_group_level_4

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

  depends_on = [azurerm_management_group.level_3]

}

resource "azurerm_management_group" "level_5" {
  for_each = local.azurerm_management_group_level_5

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

  depends_on = [azurerm_management_group.level_4]

}

resource "azurerm_management_group" "level_6" {
  for_each = local.azurerm_management_group_level_6

  name                       = each.value.id
  display_name               = each.value.display_name
  parent_management_group_id = "${local.provider_path.management_groups}${each.value.parent_management_group_id}"

  depends_on = [azurerm_management_group.level_5]

}
# Subscriptions creation
resource "azurerm_subscription" "this" {
  for_each = {
    for k, v in local.es_core_landing_zones : k => v
    if can(v.subscription_name)
  }

  subscription_name = each.value.subscription_name
  billing_scope_id  = var.billing_scope_id
}

# Subscriptions associations to Management Groups
resource "azurerm_management_group_subscription_association" "this" {
  for_each = {
    for k, v in local.es_core_landing_zones : k => v
    if can(v.subscription_name)
  }

  # Ensure the hierarchy level is created first. Because we don't know the exact level easily in a generic map,
  # we depend on all management groups. 
  depends_on = [
    azurerm_management_group.level_1,
    azurerm_management_group.level_2,
    azurerm_management_group.level_3,
    azurerm_management_group.level_4,
    azurerm_management_group.level_5,
    azurerm_management_group.level_6
  ]

  management_group_id = "${local.provider_path.management_groups}${each.key}"
  subscription_id     = "/subscriptions/${azurerm_subscription.this[each.key].subscription_id}"
}
