
# Configure the Hetzner Cloud Provider
# Will read roken from env var
provider "hcloud" {

}

provider "hetznerdns" {
}


data "hetznerdns_zone" "dns_zone" {
  name = var.zone
}

# Create server for deployment
resource "hcloud_server" "main" {
  name        = var.image_name
  image       = var.server_os
  server_type = var.server_type
  user_data   = var.user_data
}

resource "hetznerdns_record" "main" {
  zone_id = data.hetznerdns_zone.dns_zone.id
  name    = var.sub_domain
  value   = hcloud_server.main.ipv4_address
  type    = "A"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      ip   = hcloud_server.main.ipv4_address
      username = var.server_username
    }
  )
  filename = "../ansible/hosts"
}

resource "local_file" "group_vars" {
  content = templatefile("group_vars.tmpl",
    {
      subdomain = var.sub_domain
      username = var.server_username
      domain = var.domain
      git_user = var.git_user
      git_repo= var.git_repo
    }
  )
  filename = "../ansible/group_vars/main.yml"
}



