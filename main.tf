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
    source_addresses = [jsonencode(var.user_ips)]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = [jsonencode(concat(var.admin_ips, var.user_ips))]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = [jsonencode(concat(var.admin_ips, var.user_ips))]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "53"
    source_addresses = [jsonencode(concat(var.admin_ips, var.user_ips))]
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
