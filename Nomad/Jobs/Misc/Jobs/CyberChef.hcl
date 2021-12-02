job "misc-cyberchef" {
  datacenters = ["core0site1"]

  group "cyberchef" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8000
      }
    }

    service {
      name = "cyberchef"
      port = "http"

      task = "cyberchef-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "cyberchef-server" {
      driver = "docker"

      config {
        image = "registry.kristianjones.dev/cache/mpepping/cyberchef:latest"
      }

      resources {
        cpu = 64
        memory = 32
        memory_max = 32
      }
    }
  }
}