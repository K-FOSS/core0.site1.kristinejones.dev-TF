job "vps1-ingress" {
  datacenters = ["dc1", "core0site1"]

  # This group will have a task providing the ingress gateway automatically
  # created by Nomad. The ingress gateway is based on the Envoy proxy being
  # managed by the docker driver.
  group "ingress-group" {
    count = 7

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      mode = "host"
    }

    service {
      name = "vps1-ingressgw1"
      port = "443"

      connect {
        gateway {

          # Consul gateway [envoy] proxy options.
          proxy {
            # The following options are automatically set by Nomad if not
            # explicitly configured when using bridge networking.
            #
            # envoy_gateway_no_default_bind = true
            # envoy_gateway_bind_addresses "uuid-api" {
            #   address = "0.0.0.0"
            #   port    = <associated listener.port>
            # }
            #
            # Additional options are documented at
            # https://www.nomadproject.io/docs/job-specification/gateway#proxy-parameters
          }

          # Consul Ingress Gateway Configuration Entry.
          ingress {
            # Nomad will automatically manage the Configuration Entry in Consul
            # given the parameters in the ingress block.
            #
            # Additional options are documented at
            # https://www.nomadproject.io/docs/job-specification/gateway#ingress-parameters
            listener {
              port     = 443
              protocol = "tcp"
              service {
                name = "ingressweb-cont"
              }
            }
          }
        }
      }
    }
  }
}