job "loki-cache" {
  datacenters = ["core0site1"]

  group "loki-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "loki"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled", "memcached"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }
}