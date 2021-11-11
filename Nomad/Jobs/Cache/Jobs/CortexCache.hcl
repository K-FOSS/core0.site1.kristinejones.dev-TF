groupjob "cortex-cache" {
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
      name = "cortex-memcached"
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