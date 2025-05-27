# azure-container-app

Sample input:

```
project = "project1"

systemenv = "stage"



resource_group_name = "1555-Tests"

location = "West Europe"

vnet = 

container_app_envs = {
    env1 = {
        subnet_id = "10.64.0.0/18"
        resource_group = "rg1"
        region = "west europe"
    }
}

container_apps = {
    app1 = {
        name = "app1"
        env  = "env1" 
        image = "nginx"
        tag = "latest"
        volume_mounts = ""
        ingress_enabled = true
        ingress = {}

    }
}
```