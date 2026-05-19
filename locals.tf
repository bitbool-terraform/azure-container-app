locals {

identity_id_default = try(var.container_app.identity_ids[0], null)

secret_groups = lookup(var.container_app,"secret_groups",[])

# SecretSets (secrets provided as dict)
secret_sets = lookup(var.container_app,"secret_sets",{})

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

# SecretLists (secrets provided as lists)
secret_lists = lookup(var.container_app, "secret_lists", {})
secrets_selected_lists = {
    for k, v in local.secret_lists : k => v
      if contains(local.secret_groups, k)
  }

secrets_all_lists = flatten([
  for group, group_data in local.secrets_selected_lists : [
    for secret_data in try(group_data.secrets, []) : {
      group       = group
      secret_name = secret_data.name
      envvar_name = secret_data.envvar
      secret_id   = secret_data.secret_id
      identity_id = lookup(group_data, "identity_id", local.identity_id_default)
    }
  ]
])

secret_names_last = reverse(distinct(reverse([ for s in local.secrets_all_lists : s.secret_name ])))

secrets_for_secret_dynamic_lists = [
  for secret_name in local.secret_names_last :
  [
    for s in local.secrets_all_lists : s
    if s.secret_name == secret_name
  ][length([
    for s in local.secrets_all_lists : s
    if s.secret_name == secret_name
  ]) - 1]
]

secrets_for_env = (
  var.secrets_as_list
  ? local.secrets_all_lists
  : values(local.secrets_all)
)

secrets_for_secret = (
  var.secrets_as_list
  ? local.secrets_for_secret_dynamic_lists
  : values(local.secrets_all)
)
}
