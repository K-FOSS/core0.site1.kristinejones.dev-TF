#
# Redis
#
output "Redis" {
  value = {
    Password = random_password.RedisPassword.result
  }
}