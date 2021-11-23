job "cortex-cache" {
  datacenters = ["core0site1"]

  group "cortex-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "cortex"
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

      resources {
        cpu = 128
        memory = 32
        memory_max = 64
      }
    }
  }
}