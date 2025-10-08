
---

## 🟢 `docker-run-registry-gcs.sh`

```bash
#!/bin/bash
set -e
docker stop registry-gcs 2>/dev/null || true
docker rm registry-gcs 2>/dev/null || true

REGISTRY_DOMAIN="registry.example.com"
GCS_BUCKET="registry-bucket"
GCS_KEY_PATH="/opt/registry/gcs-key.json"

mkdir -p /opt/registry/auth
docker run --rm httpd:2.4-alpine htpasswd -Bbn admin strongpassword > /opt/registry/auth/htpasswd

docker run -d \
  --name registry-gcs \
  --restart unless-stopped \
  --network care2joy-net \
  -v /opt/registry/auth:/auth \
  -v ${GCS_KEY_PATH}:/gcs/key.json:ro \
  -e REGISTRY_STORAGE=gcs \
  -e REGISTRY_STORAGE_GCS_BUCKET=${GCS_BUCKET} \
  -e REGISTRY_STORAGE_GCS_KEYFILE=/gcs/key.json \
  -e REGISTRY_STORAGE_GCS_ROOTDIRECTORY=/registry \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.registry.rule=Host(\`${REGISTRY_DOMAIN}\`)" \
  -l "traefik.http.routers.registry.entrypoints=websecure" \
  -l "traefik.http.routers.registry.tls.certresolver=le" \
  -l "traefik.http.services.registry.loadbalancer.server.port=5000" \
  registry:2

echo "✅ Registry running at https://${REGISTRY_DOMAIN} (GCS backend)"
