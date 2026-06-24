#!/bin/bash
# Démarrer les services
service nginx start 2>/dev/null || true
service postgresql start 2>/dev/null || true
service zabbix-agent start 2>/dev/null || true
service fail2ban start 2>/dev/null || true

# Garder le conteneur actif avec SSH
/usr/sbin/sshd -D
