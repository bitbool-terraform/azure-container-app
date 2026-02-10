locals {
# Identities
  identity_id_default = try(var.app_identity_ids[0], null)


secret_sets = lookup(var.container_app,"secret_sets",{})
secret_groups = lookup(var.container_app,"secret_groups",[])

# Secrets
secrets_selected = {for k,v in local.secret_sets: k=>v if contains(local.secret_groups, k)}

# -------------------------------
secrets_all = merge([
  for group, group_data in local.secrets_selected : {
    for secret_key, secret_data in group_data.secrets : 
    secret_key => {
      group               = group
      secret_name         = "${group}-${secret_key}"
      envvar_name         = secret_data.secret_envvar
      secret_id           = secret_data.secret_id
      identity_id         = lookup(group_data,"identity_id",local.identity_id_default)
    }
  }
]...)

  # secrets_selected_all_ids = {
  #   for k, v in local.secrets_selected_all : 
  #       k => merge(v,{key_vault_secret_id = data.azurerm_key_vault_secret.secret[k].versionless_id},{identity_id = data.azurerm_user_assigned_identity.id[v.group].id})
  # }


  # secrets_imported_all = merge([
  #   for group, group_data in local.secrets_selected : {
  #     for secret_name in data.azurerm_key_vault_secrets.all_secrets[group].names : 
  #     secret_name => {
  #       group               = group
  #       secret_name         = secret_name
  #       envvar_name         = lookup(group_data,"import_all_as_caps",false) == true ? upper(replace(secret_name,"-","_")) : secret_name
  #       key_vault_name      = group_data.key_vault_name
  #       identity            = lookup(group_data,"identity",local.identity_default)
  #     }
  #   } if lookup(group_data,"import_all",false) == true
  # ]...)

  # secrets_imported_all_ids = {
  #   for k, v in local.secrets_imported_all : 
  #       k => merge(v,{key_vault_secret_id = data.azurerm_key_vault_secret.secret_imported[k].versionless_id},{identity_id = data.azurerm_user_assigned_identity.id[v.group].id})
  # }

  # secrets_all = merge(local.secrets_imported_all_ids,local.secrets_selected_all_ids)
}
