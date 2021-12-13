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
        image = "redis:latest"
      }

      env {
        ETCD_NAME = "etcd$${NOMAD_ALLOC_INDEX}"

        #
        # Data Directory
        #
        # https://etcd.io/docs/v3.4.0/op-guide/configuration/#--data-dir
        #
        ETCD_DATA_DIR = "/alloc"

        # https://etcd.io/docs/v3.4.0/op-guide/configuration/#--initial-advertise-peer-urls
        ETCD_INITIAL_ADVERTISE_PEER_URLS = "https://$${NOMAD_ALLOC_INDEX}.peer.etcd.teleport.service.dc1.kjdev:2380"

        ETCD_LISTEN_PEER_URLS = "https://0.0.0.0:2380"
        ETCD_LISTEN_CLIENT_URLS = "https://0.0.0.0:2379"
        ETCD_ADVERTISE_CLIENT_URLS = "https://$${NOMAD_ALLOC_INDEX}.etcd.teleport.service.dc1.kjdev:2379"
        ETCD_INITIAL_CLUSTER = "etcd1=https://0.peer.etcd.teleport.service.dc1.kjdev:2380,etcd2=https://1.peer.etcd.teleport.service.dc1.kjdev:2380,etcd3=https://2.peer.etcd.teleport.service.dc1.kjdev:2380"
        ETCD_INITIAL_CLUSTER_STATE = "new"
        ETCD_INITIAL_CLUSTER_TOKEN = "${Secrets.TeleportETCDClusterKey}"

        #
        # mTLS
        #
        ETCD_TRUSTED_CA_FILE = "/local/CA.pem"
        
        ETCD_CERT_FILE = "/secrets/AuthServerCert.pem"
        ETCD_KEY_FILE = "/secrets/AuthServerCert.pem"

        #
        # Peer
        #
        # TODO: move this to dedicated everything
        #
        ETCD_PEER_TRUSTED_CA_FILE = "/local/ETCDCA.pem"
        ETCD_PEER_CERT_FILE = "/secrets/AuthServerCert.pem"
        ETCD_PEER_KEY_FILE = "/secrets/AuthServerCert.pem"
        ETCD_PEER_CLIENT_CERT_AUTH = "true"
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

        destination = "secrets/AuthServerCert.pem"
      }

      template {
        data = <<EOF
${Teleport.ETCD.Cert}
EOF

        destination = "secrets/AuthServerCert.pem"
      }
    }
  }
}

