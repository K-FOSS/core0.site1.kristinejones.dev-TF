output "Connection" {
  value = {
    Hostname = local.Hostname
    Port = local.Port

    Endpoint = local.Endpoint
  }

  description = "S3 Bucket Name"
}


output "Bucket" {
  value = minio_bucket.Bucket.name

  description = "S3 Bucket Name"
}




output "Credentials" {
  value = {
    AccessKey = minio_user.BucketUser.access_key
    SecretKey = minio_user.BucketUser.secret_key
  }


  description = "S3 Access Credential"
}