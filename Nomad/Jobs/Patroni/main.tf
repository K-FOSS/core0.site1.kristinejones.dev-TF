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

resource "nomad_volume" "PatroniData" {
  type                  = "csi"
  plugin_id             = "truenas"
  volume_id             = "patroni-data"
  name                  = "patroni-data"
  external_id           = "patroni-data"

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  deregister_on_destroy = true

  mount_options {
    fs_type = "nfs"
    mount_flags = ["nolock", "noatime", "nfsvers=4"]
  }

  context = {
    node_attach_driver = "nfs"
    provisioner_driver = "freenas-nfs"
    server             = "172.16.51.21"
    share              = "/mnt/Site1.NAS1.Pool1/CSI/vols/patroni-data"
  }
}

resource "nomad_job" "PatroniJob" {
  jobspec = templatefile("${path.module}/JobFile.hcl", {
    Volume = nomad_volume.PatroniData

    Patroni = {
      YAMLConfig = templatefile("${path.module}/Configs/Patroni.yaml", {
        Consul = var.Consul
      })

      Entryscript = templatefile("${path.module}/Configs/entry.sh", {

      })
    }
  })
}
