#!/bin/bash

echo "=== Demarrage infrastructure IaC ==="

echo "1. Terraform apply..."
cd ~/iac-project/terraform && terraform apply -auto-approve
sleep 15

echo "2. Playbooks Ansible..."
cd ~/iac-project
ansible-playbook ansible/playbooks/site.yml -i ansible/inventory/hosts.ini
ansible-playbook ansible/playbooks/zabbix.yml -i ansible/inventory/hosts.ini
ansible-playbook ansible/playbooks/security.yml -i ansible/inventory/hosts.ini

echo "3. Demarrage Fail2ban dans les conteneurs..."
for c in web-server app-server db-server; do
  docker exec -u root $c bash -c "rm -f /var/run/fail2ban/fail2ban.sock && service fail2ban start" || true
done

echo "4. Configuration metriques Fail2ban + Zabbix Agent..."

# web-server : recreer le script + config + redemarrer
docker exec -u root web-server bash -c "
  cat > /usr/local/bin/zabbix-fail2ban.sh << 'INNEREOF'
#!/bin/bash
case \$1 in
  banned_count)
    fail2ban-client status sshd 2>/dev/null | grep 'Currently banned' | awk '{print \\\$NF}'
    ;;
  total_failed)
    fail2ban-client status sshd 2>/dev/null | grep 'Total failed' | awk '{print \\\$NF}'
    ;;
  total_banned)
    fail2ban-client status sshd 2>/dev/null | grep 'Total banned' | awk '{print \\\$NF}'
    ;;
esac
INNEREOF
  chmod +x /usr/local/bin/zabbix-fail2ban.sh

  # Nettoyer et ajouter UserParameters
  grep -v 'fail2ban' /etc/zabbix/zabbix_agentd.conf > /tmp/z.conf
  echo 'UserParameter=fail2ban.banned,/usr/local/bin/zabbix-fail2ban.sh banned_count' >> /tmp/z.conf
  echo 'UserParameter=fail2ban.total_failed,/usr/local/bin/zabbix-fail2ban.sh total_failed' >> /tmp/z.conf
  echo 'UserParameter=fail2ban.total_banned,/usr/local/bin/zabbix-fail2ban.sh total_banned' >> /tmp/z.conf
  cp /tmp/z.conf /etc/zabbix/zabbix_agentd.conf

  # Permissions socket fail2ban
  chown root:zabbix /var/run/fail2ban/fail2ban.sock 2>/dev/null || true
  chmod 660 /var/run/fail2ban/fail2ban.sock 2>/dev/null || true

  # Redemarrer Zabbix Agent (forcer)
  pkill -9 zabbix_agentd 2>/dev/null || true
  sleep 1
  rm -f /run/zabbix/zabbix_agentd.pid 2>/dev/null || true
  zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf
  sleep 2
"

# app-server et db-server : juste redemarrer Zabbix Agent
for c in app-server db-server; do
  docker exec -u root $c bash -c "
    pkill -9 zabbix_agentd 2>/dev/null || true
    sleep 1
    rm -f /run/zabbix/zabbix_agentd.pid 2>/dev/null || true
    zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf
    sleep 1
  " || true
done

echo "5. Verification..."

echo "--- web-server ---"
docker exec zabbix-server zabbix_get -s 192.168.56.10 -p 10050 -k agent.ping && echo "  agent.ping: OK" || echo "  agent.ping: FAIL"
docker exec zabbix-server zabbix_get -s 192.168.56.10 -p 10050 -k fail2ban.banned && echo "  fail2ban.banned: OK" || echo "  fail2ban.banned: FAIL"

echo "--- app-server ---"
docker exec zabbix-server zabbix_get -s 192.168.56.11 -p 10050 -k agent.ping && echo "  agent.ping: OK" || echo "  agent.ping: FAIL"

echo "--- db-server ---"
docker exec zabbix-server zabbix_get -s 192.168.56.12 -p 10050 -k agent.ping && echo "  agent.ping: OK" || echo "  agent.ping: FAIL"

echo ""
echo "=== Infrastructure prete ! ==="
echo "Zabbix UI: http://localhost:8090 (Admin / zabbix)"
