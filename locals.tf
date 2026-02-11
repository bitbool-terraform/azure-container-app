locals {

identity_id_default = try(var.container_app.identity_ids[0], null)

secret_sets = lookup(var.container_app,"secret_sets",{})
secret_groups = lookup(var.container_app,"secret_groups",[])

secrets_selected = {for k,v in local.secret_sets: k=>v if contains(local.secret_groups, k)}

secrets_all = merge([
  for group, group_data in local.secrets_selected : {
    for secret_key, secret_data in group_data.secrets : 
    secret_key => {
      group               = group
      secret_name         = "${secret_key}"
      envvar_name         = secret_data.secret_envvar
      secret_id           = secret_data.secret_id
      identity_id         = lookup(group_data,"identity_id",local.identity_id_default)
    }
  }
]...)
}
