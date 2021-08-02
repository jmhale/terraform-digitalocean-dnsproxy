terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }

    template = {
      source = "hashicorp/template"
    }
  }

  required_version = ">= 1.0.3"
}
