job "${lower(Service.Name)}-cache" {
  datacenters = ["core0site1"]

  group "${lower(Service.Name)}-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "${Service.Consul.ServiceName}"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled", "memcached"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:${Version}"
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 64
      }
    }
  }
}