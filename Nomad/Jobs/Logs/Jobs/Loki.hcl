job "loki" {
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
      name = "loki-memcached"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }
}