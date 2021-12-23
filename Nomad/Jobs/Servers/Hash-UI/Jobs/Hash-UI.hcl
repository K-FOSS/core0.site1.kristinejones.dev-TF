job "servers-hashui-server" {
  datacenters = ["core0site1"]

  group "hashui-server" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" { 
        to = 8000
      }
    }

    service {
      name = "hashui"
      port = "http"

      task = "hashui-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "http"]
    }

    task "hashui-server" {
      driver = "docker"

      config {
        image = "jippi/hashi-ui"

        memory_hard_limit = 256
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 256
      }

      env {
        #
        # Consul
        #
        CONSUL_ENABLE = "1"
        CONSUL_ADDR = "http://agent1.node0.consul.dc1.kjdev.node.kjdev:8500"
        
        
        #
        # Nomad
        #
        NOMAD_ENABLE = "1"
        NOMAD_ADDR = "http://serf.NomadServer.service.kjdev:4646"
      }
    }
  }
}