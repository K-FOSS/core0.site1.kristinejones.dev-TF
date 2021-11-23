job "pomerium-cache" {
  datacenters = ["core0site1"]

  group "pomerium-redis" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "redis" { 
        to = 6379
      }
    }

    service {
      name = "pomerium"
      port = "redis"

      task = "pomerium-redis-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "redis"]
    }

    task "pomerium-redis-server" {
      driver = "docker"

      config {
        image = "redis:6-alpine3.14"

        command = "redis-server"

        args = ["/local/redis.conf"]
      }

      resources {
        cpu = 128
        memory = 64
        memory_max = 64
      }

      template {
        data = <<EOF
port 0
tls-port 6379

tls-cert-file /secrets/TLS/Server.pem
tls-key-file /secrets/TLS/Server.key

tls-ca-cert-file /local/TLS/CA.pem
EOF

        destination = "local/redis.conf"
      }

      template {
        data = <<EOF
${TLS.CA}
EOF

        destination = "local/TLS/CA.pem"
      }

      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "secrets/TLS/Server.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "secrets/TLS/Server.key"
      }
    }
  }
}