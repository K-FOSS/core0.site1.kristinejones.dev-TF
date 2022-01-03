<?php

return [
  'base_url' => 'https://show.kjmedia.stream', // no trailing slash
  'db' => [
    'connection' => 'sqlite',
    'dsn' => realpath(__DIR__).'/resources/database/xbackbone.db',
    'username' => null,
    'password' => null,
  ],
  'ldap' => array(
    'enabled' => true, // enable it
    'host' => 'ldap.ldap.authentik.service.dc1.kjdev', // set the ldap host
    'port' => 3389, // ldap port
    'base_domain' => 'dc=ldap,dc=kristianjones,dc=dev', // the base_dn string
    'user_domain' => 'ou=users', // the user dn string
    'rdn_attribute' => 'cn=', // the attribute to identify the user
    'service_account_dn' => 'cn=${LDAP.Credentials.Username},ou=users,dc=ldap,dc=kristianjones,dc=dev', // LDAP Service Account Full DN
    'service_account_password' => '${LDAP.Credentials.Password}',
  ),
  'storage' => [
    'driver' => 's3',
    'endpoint' => '${S3.Connection.Endpoint}',
    'key' => '${S3.Credentials.AccessKey}',
    'secret' => '${S3.Credentials.SecretKey}',
    'region' => 'us-east-1',
    'bucket' => '${S3.Bucket}',
    'use_path_style_endpoint' => true,
  ],
];