# Secure Docker Registry Setup

This repository contains scripts to deploy a **secure private Docker Registry** behind **Traefik**,  
with support for the following cloud storage backends:

- 🟢 **Google Cloud Storage (GCS)**
- 🟠 **AWS S3**
- 🔵 **Azure Blob Storage**

All setups:
- Use HTTPS (Let's Encrypt certificates via Traefik)
- Use basic authentication (`admin / strongpassword`)
- Are accessible via domain: **registry.domain.com**
- Can be restricted to specific IPs (e.g., GCP VM, EC2, Azure-VM)

---

## 🧩 Prerequisites

- A running **Traefik** container (with Let’s Encrypt enabled)
- Docker network: `registry-net`
- Domain: `registry.domain.com` pointing to your VM public IP
- Firewall ports **80/443** open
- For each cloud backend:
  - GCS: Service Account JSON key with `storage.objectAdmin`
  - AWS: Access Key + Secret Key with `s3:PutObject`, `s3:GetObject`
  - Azure: Storage Account + Access Key

---

## 🟢 1️⃣ Google Cloud Storage (GCS)

### Configuration
- Bucket: `Gcloud storage bucket`
- Path: `/registry`
- Key: `/opt/registry/gcs-key.json`


### Run
```bash
chmod +x docker-run-registry-gcs.sh
sudo ./docker-run-registry-gcs.sh

🟠 2️⃣ AWS S3
Configuration

Bucket: docker-registry-bucket

Region: ap-south-1

Run
chmod +x docker-run-registry-s3.sh
sudo ./docker-run-registry-s3.sh

🔵 3️⃣ Azure Blob Storage
Configuration

Storage Account: registrystorage

Container: registry

Run
chmod +x docker-run-registry-azure.sh
sudo ./docker-run-registry-azure.sh


🧪 Verify Registry
docker login registry-uat.care2joy.com
docker tag nginx:latest registry-uat.care2joy.com/nginx
docker push registry-uat.care2joy.com/nginx


Then confirm blobs are stored in your respective cloud bucket/container.

🔐 IP Restriction (optional)

To restrict registry access to your VM only,
uncomment these labels in the scripts:

-l "traefik.http.routers.registry.middlewares=whitelist@docker" \
-l "traefik.http.middlewares.whitelist.ipwhitelist.sourcerange=$yourip