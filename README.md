# VPN

NetBird uses `vpn.slugsec.club` for browser sign in and `connect.vpn.slugsec.club` for VPN connections
Install Docker Compose, OpenSSL, envsubst and Ansible, place this checkout at `/opt/vpn` and set the ACME contact in `/etc/netbird/deployment.env`
Complete private owner setup before routing traffic, use `kanidm system oauth2 show-basic-secret netbird` for the connector and set `server.auth.localAuthDisabled: true` after testing SSO
Merge the `vpn.slugsec.club` entries from `deploy/cloudflared.yaml` before the host Tunnel catchall. DNS domains are declared in `deploy/dns.yaml`, set `NETBIRD_API_TOKEN` privately before applying

```sh
sudo -i
set -eu
cd /opt/vpn
umask 077
install -d -m 0700 /etc/netbird /var/lib/netbird/data /var/lib/netbird/acme
test -e /etc/netbird/deployment.env || cp .env.example /etc/netbird/deployment.env
test -e /etc/netbird/dashboard.env || cp deploy/dashboard.env.example /etc/netbird/dashboard.env
vi /etc/netbird/deployment.env
NETBIRD_RELAY_SECRET="$(openssl rand -base64 32)"
NETBIRD_COOKIE_KEY="$(openssl rand -base64 32)"
NETBIRD_STORE_KEY="$(openssl rand -base64 32)"
export NETBIRD_RELAY_SECRET NETBIRD_COOKIE_KEY NETBIRD_STORE_KEY
test -s /etc/netbird/config.yaml || envsubst '${NETBIRD_RELAY_SECRET} ${NETBIRD_COOKIE_KEY} ${NETBIRD_STORE_KEY}' < deploy/config.yaml.template > /etc/netbird/config.yaml
test -e /var/lib/netbird/acme/acme.json || install -m 0600 /dev/null /var/lib/netbird/acme/acme.json
install -m 0644 deploy/netbird.service /etc/systemd/system/netbird.service
systemctl daemon-reload
systemctl enable --now netbird
ansible-galaxy collection install -r deploy/requirements.yaml
ansible-playbook deploy/dns.yaml --check
ansible-playbook deploy/dns.yaml
```
