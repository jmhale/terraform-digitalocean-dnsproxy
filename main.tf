resource "digitalocean_droplet" "proxy_droplet_nyc1" {
  name      = "dns-proxy-nyc1"
  region    = "nyc1"
  size      = var.droplet_size
  image     = var.image_id
  ssh_keys  = var.ssh_keys
  user_data = data.template_file.userdata.rendered
}

resource "digitalocean_droplet" "proxy_droplet_nyc3" {
  name      = "dns-proxy-nyc3"
  region    = "nyc3"
  size      = var.droplet_size
  image     = var.image_id
  ssh_keys  = var.ssh_keys
  user_data = data.template_file.userdata.rendered
}

resource "digitalocean_floating_ip" "floating_ip_nyc1" {
  region = "nyc1"
}

resource "digitalocean_floating_ip" "floating_ip_nyc3" {
  region = "nyc3"
}

resource "digitalocean_floating_ip_assignment" "floating_ip_assignment_nyc1" {
  ip_address = digitalocean_floating_ip.floating_ip_nyc1.id
  droplet_id = digitalocean_droplet.proxy_droplet_nyc1.id
}

resource "digitalocean_floating_ip_assignment" "floating_ip_assignment_nyc3" {
  ip_address = digitalocean_floating_ip.floating_ip_nyc3.id
  droplet_id = digitalocean_droplet.proxy_droplet_nyc3.id
}

resource "digitalocean_record" "nyc1" {
  count  = var.dns_zone == "" ? 0 : 1
  domain = var.dns_zone
  type   = "A"
  name   = "nyc1"
  value  = digitalocean_floating_ip.floating_ip_nyc1.ip_address
}

resource "digitalocean_record" "nyc3" {
  count  = var.dns_zone == "" ? 0 : 1
  domain = var.dns_zone
  type   = "A"
  name   = "nyc3"
  value  = digitalocean_floating_ip.floating_ip_nyc3.ip_address
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    dns_ip_1 = digitalocean_floating_ip.floating_ip_nyc1.ip_address
    dns_ip_2 = digitalocean_floating_ip.floating_ip_nyc3.ip_address
  }
}

resource "digitalocean_firewall" "proxy" {
  name = "allow-dns-https"

  droplet_ids = [
    digitalocean_droplet.proxy_droplet_nyc1.id,
    digitalocean_droplet.proxy_droplet_nyc3.id,
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.admin_ips
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = var.user_ips
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = var.user_ips
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "53"
    source_addresses = var.user_ips
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }
}
