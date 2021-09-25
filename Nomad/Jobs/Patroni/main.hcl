job "Patroni" {
  datacenters = ["core0site1"]

  group "postgres-database" {
    count = 5

    volume "${Volume.name}" {
      type      = "csi"
      read_only = false
      source    = "${Volume.name}"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      mode = "cni/nomadcore1"

      port "psql" {
        to = 5432
      }

      port "http" {
      }
    }

    service {
      name = "patroni-store"
      port = "psql"
      address_mode = "alloc"

      task = "patroni"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      meta {
        id = "$${NOMAD_ALLOC_INDEX}"
      }
    }

    service {
      name = "patroni"
      port = "http"
      address_mode = "alloc"

      task = "patroni"

      tags = ["$${NOMAD_ALLOC_INDEX}"]

      meta {
        id = "$${NOMAD_ALLOC_INDEX}"
      }
    }

    task "patroni" {
      driver = "docker"

      user = "101"

      config {
        image = "registry.opensource.zalan.do/acid/spilo-13:2.1-p1"

        ports = ["psql", "http"]

        command = "/usr/local/bin/patroni"

        args = ["/local/Patroni.yaml"]
      }

      volume_mount {
        volume      = "${Volume.name}"
        destination = "/data"
      }

      template {
        data = <<EOF
${CONFIG}
EOF

        destination = "local/Patroni.yaml"
      }

      resources {
        cpu    = 800
        memory = 256
      }
    }
  }
}