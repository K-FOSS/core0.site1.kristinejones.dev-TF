job "matterbridge" {
  datacenters = ["core0site1"]

  group "matterbridge" {
    count = 1

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"
    }

    task "matterbridge-server" {
      driver = "docker"

      config {
        image = "${MatterBridge.Image.Repo}:${MatterBridge.Image.Tag}"

        entrypoint = ["/bin/matterbridge"]

        args = ["-conf=/local/Config.toml"]
      }

      template {
        data = <<EOF
${MatterBridge.Config}
EOF

        destination = "local/Config.toml"
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}