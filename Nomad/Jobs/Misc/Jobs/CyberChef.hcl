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

      env {

      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 128
      }
    }
  }
}