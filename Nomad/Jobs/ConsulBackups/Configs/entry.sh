#!/bin/sh
DATE=""

echo "consul-backinator backup -file s3://${S3.Bucket}/backup-$(date +%m%d%Y.%s).bak?endpoint=${S3.Connection.Hostname}:${S3.Connection.Port}&secure=false"


consul-backinator backup -file s3://${S3.Bucket}/backup-$(date +%m%d%Y.%s).bak?endpoint=${S3.Connection.Hostname}:${S3.Connection.Port}&secure=false