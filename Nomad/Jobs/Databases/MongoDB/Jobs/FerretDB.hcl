job "databases-mongodb-ferretdb" {
  datacenters = ["core0site1"]

  group "ferretdb-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "mongodb" { 
        to = 27017
      }
    }

    service {
      name = "ferretdb"
      port = "mongodb"

      task = "ferretdb-server"

      address_mode = "alloc"

      tags = ["coredns.enabled", "mongo"]
    }

    task "ferretdb-server" {
      driver = "docker"

      config {
        image = "ghcr.io/ferretdb/ferretdb:latest"

        args = ["-listen-addr=:27017", "-postgresql-url=postgres://${FerrtDB.Database.Username}:${FerrtDB.Database.Password}@${FerrtDB.Database.Hostname}:${FerrtDB.Database.Port}/${FerrtDB.Database.Database}"]

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=ferretdb,service=server"
          }
        }
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 256
      }
    }
  }
}