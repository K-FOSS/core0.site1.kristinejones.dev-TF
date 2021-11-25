# Memcached Service Module

This Nomad Module template created a memcached.CONSUL_SERVICE memcache server for the requested Consul Service.


## Variables/Inputs
| Input Var                  | Required                      | Description                  |
| -------------------------- | ----------------------------- | ---------------------------- |
| Service                    | Yes                           | Object                       |
| Service.Name               | Yes                           | Friendly name of the service |
| Service.Consul.ServiceName | Name/ID of the Consul service |
