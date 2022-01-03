variable "Redis" {
  value = {
    Cache = {
      Password = random_password.NetboxRedisCachePassword.result
    }

    General = {
      Password = random_password.NetboxRedisPassword.result
    }
  }
}