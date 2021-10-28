job "backups" {
  datacenters = ["core0site1"]

  type = "batch"

  periodic {
    cron = "*/15 * * * * *"
    prohibit_overlap = true
    time_zone = "America/Winnipeg"
  }

  group "consul-backup" {
    count = 1

    network {
      mode = "cni/nomadcore1"
    }

    task "consul-backup" {
      driver = "docker"

      config {
        image = "myena/consul-backinator"

        entrypoint = ["/bin/sh"]
        tty = true
        command = "/local/entry.sh"
      }

      env {
        AWS_REGION="us-east-1"
      }


      template {
        data = <<EOH
#
# S3
#
AWS_ACCESS_KEY_ID="${S3.Credentials.AccessKey}"
AWS_SECRET_ACCESS_KEY="${S3.Credentials.SecretKey}"

#
# Consul
# 
CONSUL_HTTP_ADDR="${Consul.Hostname}:${Consul.Port}"
CONSUL_HTTP_TOKEN="${Consul.Token}"
EOH

        destination = "secrets/file.env"
        env = true
      }

      # Entrypoint Script
      template {
        data = <<EOF
${EntryScript}
EOF

        destination = "local/entry.sh"

        perms = "777"
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}