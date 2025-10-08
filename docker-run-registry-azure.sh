#!/bin/bash
set -e
docker stop registry-azure 2>/dev/null || true
docker rm registry-azure 2>/dev/null || true

REGISTRY_DOMAIN="registry.domain.com"
AZURE_STORAGE_ACCOUNT="registrystorage"
AZURE_STORAGE_KEY="YOUR_AZURE_STORAGE_KEY"
AZURE_CONTAINER="registry"

mkdir -p /opt/registry/auth
docker run --rm httpd:2.4-alpine htpasswd -Bbn admin strongpassword > /opt/registry/auth/htpasswd

docker run -d \
  --name registry-azure \
  --restart unless-stopped \
  --network care2joy-net \
  -v /opt/registry/auth:/auth \
  -e REGISTRY_STORAGE=azure \
  -e REGISTRY_STORAGE_AZURE_ACCOUNTNAME=${AZURE_STORAGE_ACCOUNT} \
  -e REGISTRY_STORAGE_AZURE_ACCOUNTKEY=${AZURE_STORAGE_KEY} \
  -e REGISTRY_STORAGE_AZURE_CONTAINER=${AZURE_CONTAINER} \
  -e REGISTRY_STORAGE_AZURE_REALM=https://core.windows.net \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.registry.rule=Host(\`${REGISTRY_DOMAIN}\`)" \
  -l "traefik.http.routers.registry.entrypoints=websecure" \
  -l "traefik.http.routers.registry.tls.certresolver=le" \
  -l "traefik.http.services.registry.loadbalancer.server.port=5000" \
  registry:2

echo "✅ Registry running at https://${REGISTRY_DOMAIN} (Azure Blob backend)"
