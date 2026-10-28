# VPN

NetBird setup for SlugSec

```sh
sudo netbird up --management-url https://connect.vpn.slugsec.club --admin-url https://vpn.slugsec.club
netbird status
sudo netbird down
```

On the server, run from `/opt/vpn` with `NETBIRD_API_TOKEN` set for DNS changes

```sh
sudo systemctl status netbird
sudo docker compose --env-file /etc/netbird/deployment.env logs --tail 100

ansible-galaxy collection install -r deploy/requirements.yaml
ansible-playbook deploy/dns.yaml -e netbird_api_url=http://127.0.0.1:8081 --check
ansible-playbook deploy/dns.yaml -e netbird_api_url=http://127.0.0.1:8081
```

Private services run on the LAN host with `compose.private.yaml` and `/etc/netbird-proxy/deployment.env`

```sh
sudo docker compose --env-file /etc/netbird-proxy/deployment.env -f compose.private.yaml run --rm certificate
sudo docker compose --env-file /etc/netbird-proxy/deployment.env -f compose.private.yaml up -d proxy
sudo systemctl enable --now netbird-certificate.timer
ansible-playbook deploy/services.yaml
```
