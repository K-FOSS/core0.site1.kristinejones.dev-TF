#
# Minio
#

variable "Minio" {
  type = object({
    AccessKey = string
    SecretKey = string

    AccessToken = string
  })
}