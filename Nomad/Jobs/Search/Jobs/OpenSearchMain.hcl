job "search-opensearch-main" {
  datacenters = ["core0site1"]

  group "opensearch-main-server" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "https" {
        to = 9200
      }

      port "apm" {
        to = 9600
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
      name = "opensearch"
      port = "https"

      task = "opensearch-main-server"
      address_mode = "alloc"

      tags = ["coredns.enabled", "https.master", "$${NOMAD_ALLOC_INDEX}.https.master"]
    }

    task "opensearch-main-server" {
      driver = "docker"

      config {
        image = "${OpenSearch.Image.Repo}/opensearch:${OpenSearch.Image.Tag}"

        memory_hard_limit = 1024

        ulimit {
          nofile = "65536:65536"
        }

        mount {
          type = "bind"
          target = "/usr/share/opensearch/config/opensearch.yml"
          source = "local/opensearch.yml"
          readonly = true
        }

        mount {
          type = "bind"
          target = "/usr/share/opensearch/config/TLS"
          source = "local/TLS"
          readonly = false
        }

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=opensearch,service=$${NOMAD_META_NodeType}$${NOMAD_ALLOC_INDEX}"
          }
        }
      }

      meta {
        NodeType = "Master"
      }

      resources {
        cpu = 256

        memory = 512
        memory_max = 1024
      }

      env {
        OPENSEARCH_JAVA_OPTS = "-Xms512m -Xmx512m"

        OPENSEARCH_HOME = "/usr/share/opensearch"

        OPENSEARCH_PATH_CONF = "/usr/share/opensearch/config"
      }

      template {
        data = <<EOF
${OpenSearch.Config}
EOF

        destination = "local/opensearch.yml"
      }

      #
      # TLS
      #

      #
      # mTLS
      #

      #
      # TODO: Loop over OpenSearch.TLS Object
      #

      template {
        data = <<EOF
${OpenSearch.CA}
EOF

        destination = "local/TLS/CA.pem"
      }

%{ for NodeType, Certs in OpenSearch.TLS ~}
  #
  # ${NodeType}
  #
%{ for NodeName, TLS in Certs ~}
      template {
        data = <<EOF
${TLS.Cert}
EOF

        destination = "local/TLS/${NodeType}/${NodeName}.pem"
      }

      template {
        data = <<EOF
${TLS.Key}
EOF

        destination = "local/TLS/${NodeType}/${NodeName}.key"
      }
%{ endfor ~}

%{ endfor ~}
    }
  }
}