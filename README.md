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

Private services run on the LAN host with `compose.private.yaml` and `/etc/netbird-proxy/deployment.env`. Routing gateways require `/dev/net/tun` and use `compose.gateway.yaml` and a private copy of `gateway.env.example` at `/etc/netbird-gateway/gateway.env` with a root-owned mode `700` state directory, run `sudo docker compose --env-file /etc/netbird-gateway/gateway.env -f compose.gateway.yaml up -d`, then remove `NB_SETUP_KEY` after enrollment and recreate only the gateway

```sh
sudo docker compose --env-file /etc/netbird-proxy/deployment.env -f compose.private.yaml run --rm certificate
sudo docker compose --env-file /etc/netbird-proxy/deployment.env -f compose.private.yaml up -d proxy
sudo systemctl enable --now netbird-certificate.timer
ansible-playbook deploy/services.yaml
```

public apps use `app.slugsec.club`, vpn only apps use `app.internal.slugsec.club`, each public app needs an exact dns record and a matching sni passthrough rule in `deploy/traefik/public.yaml`

from `/opt/vpn`, run `sudo docker compose --env-file /etc/netbird/deployment.env -f compose.yaml -f compose.public.yaml up -d public-proxy`
