#!/bin/bash
set -e
docker stop registry-s3 2>/dev/null || true
docker rm registry-s3 2>/dev/null || true

REGISTRY_DOMAIN="registry.domain.com"
AWS_REGION="ap-south-1"
S3_BUCKET="registry-bucket"
AWS_ACCESS_KEY="YOUR_AWS_ACCESS_KEY_ID"
AWS_SECRET_KEY="YOUR_AWS_SECRET_ACCESS_KEY"

mkdir -p /opt/registry/auth
docker run --rm httpd:2.4-alpine htpasswd -Bbn admin strongpassword > /opt/registry/auth/htpasswd

docker run -d \
  --name registry-s3 \
  --restart unless-stopped \
  --network care2joy-net \
  -v /opt/registry/auth:/auth \
  -e REGISTRY_STORAGE=s3 \
  -e REGISTRY_STORAGE_S3_REGION=${AWS_REGION} \
  -e REGISTRY_STORAGE_S3_BUCKET=${S3_BUCKET} \
  -e REGISTRY_STORAGE_S3_ACCESSKEY=${AWS_ACCESS_KEY} \
  -e REGISTRY_STORAGE_S3_SECRETKEY=${AWS_SECRET_KEY} \
  -e REGISTRY_STORAGE_S3_ROOTDIRECTORY=/registry \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Care2Joy Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.registry.rule=Host(\`${REGISTRY_DOMAIN}\`)" \
  -l "traefik.http.routers.registry.entrypoints=websecure" \
  -l "traefik.http.routers.registry.tls.certresolver=le" \
  -l "traefik.http.services.registry.loadbalancer.server.port=5000" \
  registry:2

echo "✅ Registry running at https://${REGISTRY_DOMAIN} (S3 backend)"
