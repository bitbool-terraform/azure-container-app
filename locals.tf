locals {
    
    name_prefix = format("%s-%s",var.project,var.systemenv)

    app_gw_rule = {
        "${var.systemenv}-${var.app_name}" = {
            hostname = var.app_gw.hostname
            backend_port = var.app_gw.backend_port
            path = lookup(var.app_gw,"path","/*")
            backend_target = format("%s-%s",var.systemenv,var.app_name)
            pick_host_name_from_backend_address = var.appgw_hostname_override
        }


    }
    app_gw_backend_target = {
        "${var.systemenv}-${var.app_name}" = {
            fqdns= [resource.azurerm_container_app.container_app.ingress[0].fqdn]
        }

    }
}