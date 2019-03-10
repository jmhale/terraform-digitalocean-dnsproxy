# terraform-digitalocean-dnsproxy

Deploys a DNS proxy instance pair using bind9 and sniproxy in the NYC1 and NYC3 DigitalOcean regions

## Variables
| Variable Name | Type | Required |Description |
|---------------|-------------|-------------|-------------|
|`user_ips`|`list`|Yes|List of IPv4 addresses allowed to query DNS and proxy HTTP/S connections.|
|`admin_ips`|`list`|Yes|List of IPv4 addresses allowed to query DNS, proxy HTTP/S connections, and SSH to the proxy instances.|
|`ssh_keys`|`list`|Yes|List of DigitalOcean identifiers for a SSH keys to use.|
|`image_id`|`string`|No|ID of the OS image to use for the instances. Defaults to Ubuntu 18.04.|
|`droplet_size`|`string`|No|Size of the droplet to create. Defaults to s-1vcpu-1gb.|

## Usage

```
module "terraform-digitalocean-dnsproxy" {
  source = "git@github.com:jmhale/terraform-digitalocean-dnsproxy.git"
  admin_ips = "[1.2.3.4]"
  user_ips  = "[5.6.7.8]"
  ssh_keys  = ["00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff"]
}

```
## Outputs
| Output Name | Description |
|---------------|-------------|
|`floating_ip_nyc1`|IPv4 address of the NYC1 droplet.|
|`floating_ip_nyc3`|IPv4 address of the NYC3 droplet.|


---
Copyright © 2019, James Hale
