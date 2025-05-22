# n8n Project

This project sets up an environment for running n8n, a workflow automation tool, along with supporting services using Docker Compose.

## Services

### 1. Traefik
- **Purpose**: Acts as a reverse proxy and load balancer.
- **Features**:
  - Automatic HTTPS with Let's Encrypt.
  - Configurable API dashboard (disabled by default for security).

### 2. n8n
- **Purpose**: Workflow automation tool.
- **Features**:
  - Accessible via a secure HTTPS endpoint.
  - Configured to use PostgreSQL as the database.

### 3. MinIO
- **Purpose**: Object storage service compatible with Amazon S3.
- **Features**:
  - API and web console available via HTTPS.

### 4. PostgreSQL
- **Purpose**: Database for n8n.
- **Features**:
  - Persistent data storage.
  - Health checks to ensure availability.

### 5. pgAdmin
- **Purpose**: Database management tool for PostgreSQL.
- **Features**:
  - Web-based interface accessible via HTTPS.

## Volumes
The following named volumes are used to persist data:
- `n8n_data`: Stores n8n configuration and workflows.
- `traefik_data`: Stores Traefik's Let's Encrypt data.
- `minio_data`: Stores MinIO data.
- `postgres_data`: Stores PostgreSQL data.
- `pgadmin_data`: Stores pgAdmin configuration.

## Networks
- **internal_network**: Ensures secure communication between services.

## Setup Instructions
1. Create a `.env` file with the required environment variables:
   ```env
   DOMAIN_NAME=example.com
   SUBDOMAIN=n8n
   SSL_EMAIL=your-email@example.com
   POSTGRES_DB=n8n
   POSTGRES_USER=n8n_user
   POSTGRES_PASSWORD=secure_password
   PGADMIN_DEFAULT_EMAIL=admin@example.com
   PGADMIN_DEFAULT_PASSWORD=secure_password
   MINIO_ROOT_USER=minio_user
   MINIO_ROOT_PASSWORD=secure_password
   GENERIC_TIMEZONE=UTC
   ```
2. Start the services:
   ```bash
   docker-compose up -d
   ```
3. Access the services:
   - n8n: `https://n8n.example.com`
   - MinIO API: `https://minio.example.com`
   - MinIO Console: `https://minio-console.example.com`
   - pgAdmin: `https://pgadmin.example.com`

## Notes
- Ensure that the `.env` file is properly configured before starting the services.
- For production, consider securing the Traefik dashboard and pinning specific versions of the images.