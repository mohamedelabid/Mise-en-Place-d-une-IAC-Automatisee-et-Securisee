output "conteneurs" {
  value = {
    web    = "192.168.56.10 (SSH:2210, HTTP:8080)"
    app    = "192.168.56.11 (SSH:2211, App:3000)"
    db     = "192.168.56.12 (SSH:2212, PG:5432)"
    zabbix = "192.168.56.20 (Web:8090)"
  }
}
