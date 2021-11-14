job "drawio-cache" {
  datacenters = ["core0site1"]

  group "drawio-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "drawio"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled", "cache"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }
}