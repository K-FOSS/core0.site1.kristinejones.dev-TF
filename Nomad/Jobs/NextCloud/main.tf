terraform {
  required_providers {
    #
    # Hashicorp Vault
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
    #
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
    }

    #
    # GitHub Provider
    #
    # Used to fetch the latest PSQL file
    #
    # Docs: https://registry.terraform.io/providers/integrations/github/latest
    #
    github = {
      source = "integrations/github"
      version = "4.15.1"
    }

    #
    # Hashicorp Terraform HTTP Provider
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/http/latest/docs
    #
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }

    #
    # Randomness
    #
    # TODO: Find a way to best improve true randomness?
    #
    # Docs: https://registry.terraform.io/providers/hashicorp/random/latest/docs
    #
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

data "github_repository" "Netbox" {
  full_name = "netbox-community/netbox"
}

data "github_release" "Netbox" {
  repository  = data.github_repository.Netbox.name
  owner       = split("/", data.github_repository.Netbox.full_name)[0]
  retrieve_by = "latest"
}

resource "nomad_volume" "Nextcloud" {
  type                  = "csi"
  plugin_id             = "truenas"
  volume_id             = "nextcloud-vol"
  name                  = "nextcloud-vol"
  external_id           = "netxcloud-vol"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true

  mount_options {
    fs_type = "nfs"
    mount_flags = ["nolock"]
  }

  context = {
    node_attach_driver = "nfs"
    provisioner_driver = "freenas-nfs"
    server             = "172.16.51.21"
    share              = "/mnt/Site1.NAS1.Pool1/CSI/vols/nextcloud-vol"
  }
}
