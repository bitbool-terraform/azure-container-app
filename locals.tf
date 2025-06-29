locals {
    app_gw_rule = {
        "${var.app_name}" = {
            hostname = var.app_gw.hostname
            backend_port = var.app_gw.backend_port
            path = lookup(var.app_gw,"path","/*")
            backend_target = var.app_name
            pick_host_name_from_backend_address = var.appgw_hostname_override
        }


    }

    app_gw_backend_target = {
        "${var.app_name}" = {
            fqdns= [resource.azurerm_container_app.container_app.ingress[0].fqdn]
        }

    }


  secrets_selected = {for k,v in var.secrets : k=>v if contains(var.app_secrets, k)}

  secrets_selected_all = merge([
    for group, group_data in local.secrets_selected : {
      for secret_key, secret_data in group_data.secrets : 
      secret_key => {
        group               = group
        secret_name         = secret_data.secret_name
        envvar_name         = secret_data.secret_envvar
        key_vault_name      = group_data.key_vault_name
        identity            = lookup(group_data,"identity",var.identity_default)
      }
    }
  ]...)

  secrets_selected_all_ids = {
    for k, v in local.secrets_selected_all : 
        k => merge(v,{key_vault_secret_id = data.azurerm_key_vault_secret.secret[k].versionless_id})
  }


  secrets_imported_all = merge([
    for group, group_data in local.secrets_selected : {
      for secret_name in data.azurerm_key_vault_secrets.all_secrets[group].names : 
      secret_name => {
        group               = group
        secret_name         = secret_name
        envvar_name         = secret_name
        key_vault_name      = group_data.key_vault_name
      }
    } if lookup(group_data,"import_all",false) == true
  ]...)

  secrets_imported_all_ids = {
    for k, v in local.secrets_imported_all : 
        k => merge(v,{key_vault_secret_id = data.azurerm_key_vault_secret.secret_imported[k].versionless_id})
  }

  secrets_all = merge(local.secrets_imported_all_ids,local.secrets_selected_all_ids)
}
