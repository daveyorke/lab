terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

variable "pm_api_url" {
	type = string
}

variable "pm_api_token_id" {
	type = string
	sensitive = true
}

variable "pm_api_token_secret" {
	type = string
	sensitive = true
}

variable "sshkeys" {
	type = string
}

provider "proxmox" {
  pm_tls_insecure = true
	pm_api_url = var.pm_api_url
	pm_api_token_id = var.pm_api_token_id
	pm_api_token_secret = var.pm_api_token_secret
}
