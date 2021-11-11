job "cortex" {
  datacenters = ["core0site1"]

  group "cortex-memcached" {
    count = 1

    network {
      mode = "cni/nomadcore1"

      port "memcached" { 
        to = 11211
      }
    }

    service {
      name = "cortex-memcached"
      port = "memcached"

      task = "memcached"
      address_mode = "alloc"

      tags = ["coredns.enabled"]
    }

    task "memcached" {
      driver = "docker"

      config {
        image = "memcached:1.6"
      }
    }
  }

  #
  # Cortex Distributor
  #
  group "cortex-distributor" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-distributor"
      port = "http"

      task = "cortex-distributor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-distributor"
      port = "grpc"

      task = "cortex-distributor"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-distributor"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-distributor"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-distributor" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "distributor"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Querier
  #
  group "cortex-querier" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-querier"
      port = "http"

      task = "cortex-querier"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-querier"
      port = "grpc"

      task = "cortex-querier"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-querier"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-querier"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-querier" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "querier"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Ingester
  #
  group "cortex-ingester" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-ingester"
      port = "http"

      task = "cortex-ingester"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-ingester"
      port = "grpc"

      task = "cortex-ingester"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-ingester"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-ingester"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-ingester" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "ingester"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Query Frontend
  #
  #
  # Cortex Ingester
  #
  group "cortex-query-frontend" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-query-frontend"
      port = "http"

      task = "cortex-query-frontend"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-query-frontend"
      port = "grpc"

      task = "cortex-query-frontend"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-query-frontend"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-query-frontend"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-query-frontend" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "query-frontend"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Store Gateway
  #
  group "cortex-store-gateway" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-store-gateway"
      port = "http"

      task = "cortex-store-gateway"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-store-gateway"
      port = "grpc"

      task = "cortex-store-gateway"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-store-gateway"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-store-gateway"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-store-gateway" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"



      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "store-gateway"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Configs
  #
  group "cortex-configs" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-configs"
      port = "http"

      task = "cortex-configs"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-configs"
      port = "grpc"

      task = "cortex-configs"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-configs"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-configs"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-configs" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"

      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "configs"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Alert Manager
  #
  group "cortex-alertmanager" {
    count = 3

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      port "alertmanagerha" {
        to = 9094
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    task "wait-for-configs" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "exec"
      config {
        command = "sh"
        args = ["-c", "while ! nc -z http.cortex-configs.service.dc1.kjdev 8080; do sleep 1; done"]
      }
    }

    service {
      name = "cortex-alertmanager"
      port = "http"

      task = "cortex-alertmanager"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-alertmanager"
      port = "grpc"

      task = "cortex-alertmanager"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-alertmanager"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-alertmanager"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    service {
      name = "cortex-alertmanager"
      
      port = "alertmanagerha"
      address_mode = "alloc"

      task = "cortex-alertmanager"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "ha", "$${NOMAD_ALLOC_INDEX}.ha"]
    }

    task "cortex-alertmanager" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"

      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256

        logging {
          type = "loki"
          config {
            loki-url = "http://http.ingress-webproxy.service.dc1.kjdev:8080/loki/api/v1/push"

            loki-external-labels = "job=cortex,service=alert-manager"
          }
        }
      }

      meta {
        TARGET = "alertmanager"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.AlertManager.Config}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/AlertManager.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }

  #
  # Cortex Query Scheduler
  #
  group "cortex-query-scheduler" {
    count = 2

    spread {
      attribute = "$${node.unique.id}"
      weight = 100
    }

    network {
      mode = "cni/nomadcore1"

      port "http" {
        to = 8080
      }

      port "grpc" {
        to = 8085
      }

      port "gossip" {
        to = 8090
      }

      dns {
        servers = [
          "10.1.1.53",
          "172.16.0.1"
        ]
      }
    }

    service {
      name = "cortex-query-scheduler"
      port = "http"

      task = "cortex-query-scheduler"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "http"]

      #
      # Liveness check
      #
      check {
        port = "http"
        address_mode = "alloc"

        type = "http"

        path = "/ready"
        interval = "15s"
        timeout  = "3s"

        check_restart {
          limit = 10
          grace = "10m"
        }
      }
    }

    service {
      name = "cortex-query-scheduler"
      port = "grpc"

      task = "cortex-query-scheduler"
      address_mode = "alloc"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "grpc", "$${NOMAD_ALLOC_INDEX}.grpc"]
    }

    service {
      name = "cortex-query-scheduler"
      
      port = "gossip"
      address_mode = "alloc"

      task = "cortex-query-scheduler"

      tags = ["$${NOMAD_ALLOC_INDEX}", "coredns.enabled", "gossip", "$${NOMAD_ALLOC_INDEX}.gossip"]
    }

    task "cortex-query-scheduler" {
      driver = "docker"

      restart {
        attempts = 5
        delay = "120s"
        mode = "delay"
      }

      kill_timeout = "120s"

      config {
        image = "cortexproject/cortex:${Cortex.Version}"

        args = ["-config.file=/local/Cortex.yaml"]

        memory_hard_limit = 256
      }

      meta {
        TARGET = "query-scheduler"

        REPLICAS = "3"
      }

      resources {
        cpu = 128
        memory = 256
        memory_max = 256
      }

      template {
        data = <<EOF
${Cortex.YAMLConfig}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "local/Cortex.yaml"
      }

      template {
        data = <<EOF
${Cortex.Database.Password}
EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "secrets/DB_PASS"
      }
    }
  }
}