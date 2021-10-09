job "ejabberd" {
  datacenters = ["core0site1"]

  group "ejabberd-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "ejabberd-redis"
      port = "redis"

      task = "redis"

      address_mode = "alloc"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6-alpine3.14"

        command = "redis-server"

        args = ["/local/redis.conf"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=ejabberd,service=redis"
          }
        }
      }

      template {
        data = <<EOF
port 6379

requirepass "${Redis.Password}"
EOF

        destination = "local/redis.conf"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.Redis.Key}
EOF

        destination = "local/cert.key"
      }
    }
  }

  group "ejabberd-server" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "mqtt" { 
        to = 1883
      }
    }

    service {
      name = "ejabberd-mqtt-cont"
      port = "mqtt"

      task = "ejabberd"

      address_mode = "alloc"
    }

    task "ejabberd" {
      driver = "docker"

      user = "101"

      config {
        image = "ejabberd/ecs:${Version}"

        args = ["foreground", "--config", "/local/eJabberD.yaml"]

        logging {
          type = "loki"
          config {
            loki-url = "http://ingressweb-http-cont.service.kjdev:8080/loki/api/v1/push"
          }
        }
      }
    
      env {

      }

      template {
        data = <<EOF
${eJabberD.Config}
EOF

        destination = "local/eJabberD.yaml"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/ca.pem"
      }

      template {
        data = <<EOF
${TLS.MQTT.Cert}
EOF

        destination = "local/cert.pem"
      }

      template {
        data = <<EOF
${TLS.MQTT.Key}
EOF

        destination = "local/cert.key"
      }
    }
  }
}