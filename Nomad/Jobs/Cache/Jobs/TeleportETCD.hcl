job "cache-teleport-etcd" {
  datacenters = ["core0site1"]

  group "teleport-etcd" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "etcd" { 
        to = 2379
      }

      port "peers" { 
        to = 2380
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
      port = "etcd"

      task = "teleport-etcd"
      address_mode = "alloc"

      tags = ["coredns.enabled", "etcd", "$${NOMAD_ALLOC_INDEX}.etcd"]
    }

    service {
      name = "teleport"
      port = "peers"

      task = "github-redis-cache"
      address_mode = "alloc"

      tags = ["coredns.enabled", "etcd", "$${NOMAD_ALLOC_INDEX}.peer.etcd", "_etcd-server._tcp.etcd"]
    }

    task "teleport-etcd" {
      driver = "docker"

      config {
        image = "gcr.io/etcd-development/etcd:v3.5.0"

        logging {
          type = "loki"
          config {
            loki-url = "http://http.distributor.loki.service.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=teleport,service=etcd"
          }
        }
      }

      env {
        ETCD_NAME = "etcd$${NOMAD_ALLOC_INDEX}"

        #
        # Data Directory
        #
        # https://etcd.io/docs/v3.4.0/op-guide/configuration/#--data-dir
        #
        #ETCD_DATA_DIR = "/alloc"

        # https://etcd.io/docs/v3.4.0/op-guide/configuration/#--initial-advertise-peer-urls
        ETCD_INITIAL_ADVERTISE_PEER_URLS = "https://$${NOMAD_ALLOC_INDEX}.peer.etcd.teleport.service.dc1.kjdev:2380"

        ETCD_LISTEN_PEER_URLS = "https://0.0.0.0:2380"
        ETCD_LISTEN_CLIENT_URLS = "https://0.0.0.0:2379"
        ETCD_ADVERTISE_CLIENT_URLS = "https://$${NOMAD_ALLOC_INDEX}.etcd.teleport.service.dc1.kjdev:2379"
        ETCD_INITIAL_CLUSTER = "etcd0=https://0.peer.etcd.teleport.service.dc1.kjdev:2380,etcd1=https://1.peer.etcd.teleport.service.dc1.kjdev:2380,etcd2=https://2.peer.etcd.teleport.service.dc1.kjdev:2380"
        ETCD_INITIAL_CLUSTER_STATE = "new"
        ETCD_INITIAL_CLUSTER_TOKEN = "${Secrets.TeleportClusterKey}"

        #
        # mTLS
        #
        ETCD_TRUSTED_CA_FILE = "/local/CA.pem"
        
        ETCD_CERT_FILE = "/secrets/ETCD.pem"
        ETCD_KEY_FILE = "/secrets/ETCD.key"

        #
        # Peer
        #
        # TODO: move this to dedicated everything
        #
        ETCD_PEER_TRUSTED_CA_FILE = "/local/ETCDCA.pem"
        ETCD_PEER_CERT_FILE = "/secrets/ETCD.pem"
        ETCD_PEER_KEY_FILE = "/secrets/ETCD.key"
        ETCD_PEER_CLIENT_CERT_AUTH = "true"

        #
        # Observability
        #

        # Logging
        ETCD_LOG_OUTPUTS = "stdout"
        ETCD_LOG_LEVEL = "warn"

        # Tracing
        ETCD_EXPERIMENTAL_ENABLE_DISTRIBUTED_TRACING = "true"
        ETCD_EXPERIMENTAL_DISTRIBUTED_TRACING_ADDRESS = "grpc.otel.tempo.service.kjdev:4317"
        ETCD_EXPERIMENTAL_DISTRIBUTED_TRACING_SERVICE_NAME = "TeleportETCD"
        ETCD_EXPERIMENTAL_DISTRIBUTED_TRACING_INSTANCE_ID = "$${NOMAD_ALLOC_NAME}"
        #experimental-enable-distributed-tracing

        
      }

      #
      # TLS
      #
      template {
        data = <<EOF
${Teleport.CA}
EOF

        destination = "local/CA.pem"
      }

      template {
        data = <<EOF
${Teleport.ETCD.CA}
EOF

        destination = "local/ETCDCA.pem"
      }

      template {
        data = <<EOF
${Teleport.ETCD.Cert}
EOF

        destination = "secrets/ETCD.pem"
      }

      template {
        data = <<EOF
${Teleport.ETCD.Key}
EOF

        destination = "secrets/ETCD.key"
      }
    }
  }
}

