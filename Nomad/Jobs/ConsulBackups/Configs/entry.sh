/usr/local/bin/consul-backinator backup -file "s3://${S3.Bucket}/backup-$(date +%m%d%Y.%s).bak?endpoint=${S3.Connection.Hostname}:${S3.Connection.Port}&pathstyle=true&secure=false" -addr consul.service.dc1.kjdev:8500 -key 'test'