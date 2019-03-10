# Output file

output "floating_ip_nyc1" {
  value       = "${digitalocean_floating_ip.floating_ip_nyc1.ip_address}"
  description = "IPv4 address of the NYC1 droplet."
}

output "floating_ip_nyc3" {
  value       = "${digitalocean_floating_ip.floating_ip_nyc3.ip_address}"
  description = "IPv4 address of the NYC3 droplet."
}
