output "Database" {
  value = {
    Hostname = local.Hostname
    Port = local.Port

    Database = postgresql_database.Database.name

    Username = postgresql_role.User.name
    Password = postgresql_role.User.password
  }
}

#
# Connection Details
#

output "Hostname" {
  value = local.Hostname
}

output "Port" {
  value = local.Port
}