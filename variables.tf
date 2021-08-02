variable "admin_ips" {
  type        = list(any)
  description = "List of IPv4 addresses allowed to query DNS, proxy HTTP/S connections, and SSH to the proxy instances."
  default     = []
}

variable "user_ips" {
  type        = list(any)
  description = "List of IPv4 addresses allowed to query DNS and proxy HTTP/S connections."
  default     = []
}

variable "ssh_keys" {
  type        = list(any)
  description = "List of DigitalOcean identifiers for a SSH keys to use"
}

variable "image_id" {
  description = "ID of the OS image to use for the instances."
  default     = "ubuntu-20-04-x64"
}

variable "droplet_size" {
  description = "Size of the droplet to create."
  default     = "s-1vcpu-1gb"
}
