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

        command = "/bin/sh"
        args = [
          "-c",
          "consul-backinator backup -file s3://${S3.Bucket}/backup-$(date +%m%d%Y.%s).bak?endpoint=${S3.Connection.Hostname}:${S3.Connection.Port}&secure=false"
        ]
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

      resources {
        cpu = 64
        memory = 64
        memory_max = 128
      }
    }
  }
}