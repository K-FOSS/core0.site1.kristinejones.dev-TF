job "aaa-teleport-auth" {
  datacenters = ["core0site1"]

  group "teleport-auth" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" { 
        to = 3025
      }

      port "diag" { 
        to = 3000
      }

      dns {
        servers = [
          "10.1.1.53",
          "10.1.1.10",
          "10.1.1.13"
        ]
      }
    }

    service {
      name = "teleport"
      port = "https"

      task = "teleport-auth-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.auth", "$${NOMAD_ALLOC_INDEX}.https.auth"]

      #
      # Liveness check
      #
      check {
        port = "diag"
        address_mode = "alloc"

        type = "http"

        path = "/healthz"
        interval = "5s"
        timeout  = "3s"

        check_restart {
          limit = 6
          grace = "30s"
        }
      }
    }

    service {
      name = "teleport"
      port = "diag"

      task = "teleport-auth-server"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "diag.auth"]
    }

    task "teleport-auth-server" {
      driver = "docker"

      config {
        image = "${Teleport.Repo}:${Teleport.Version}"

        args = ["start", "--diag-addr=0.0.0.0:3000", "--config", "/local/Teleport.yaml", "--roles=auth", "-d", "--bootstrap=/local/github.yaml"]

        memory_hard_limit = 256

        mount {
          type = "bind"
          target = "/etc/ssl/certs/Teleport.pem"
          source = "local/TeleportCA.pem"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=teleport,service=auth"
          }
        }
      }

      meta {
        Service = "Auth"
      }

      resources {
        cpu = 64

        memory = 64
        memory_max = 256
      }

      template {
        data = <<EOF
${Teleport.YAMLConfig}
EOF

        destination = "local/Teleport.yaml"
      }

      template {
        data = <<EOF
${Teleport.SSOConfig}
EOF

        destination = "local/github.yaml"
      }

      #
      # TLS
      #

      template {
        data = <<EOF
${Teleport.TLS.CA}
EOF

        destination = "local/TeleportCA.pem"
      }

      # ETCD
      template {
        data = <<EOF
${Teleport.TLS.ETCD.CA}
EOF

        destination = "local/TeleportETCDCA.pem"
      }


      template {
        data = <<EOF
${Teleport.TLS.Proxy.CA}
EOF

        destination = "local/TeleportProxyCA.pem"
      }

      template {
        data = <<EOF
${Teleport.TLS.Auth.CA}
EOF

        destination = "local/TeleportAuthCA.pem"
      }
      
      template {
        data = <<EOF
${Teleport.TLS.Auth.Cert}
EOF

        destination = "secrets/AuthServerCert.pem"
      }

      template {
        data = <<EOF
${Teleport.TLS.Auth.Key}
EOF

        destination = "secrets/AuthServerCert.key"
      }

      #
      # Proxy
      #
      template {
        data = <<EOF
${Teleport.TLS.Proxy.Cert}
EOF

        destination = "secrets/ProxyServerCert.pem"
      }

      template {
        data = <<EOF
${Teleport.TLS.Proxy.Key}
EOF

        destination = "secrets/ProxyServerCert.key"
      }

      #
      # ENVs
      # 
      template {
        data = <<EOH
#
# Storage
#
AWS_ACCESS_KEY_ID="${Teleport.S3.Credentials.AccessKey}"
AWS_SECRET_ACCESS_KEY="${Teleport.S3.Credentials.SecretKey}"
EOH

        destination = "secrets/file.env"
        env = true
      }
    }
  }
}