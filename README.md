# Prefect Workflow Automation

A containerized ETL (Extract, Transform, Load) workflow automation project built with Prefect 3.x, designed for data processing pipelines that extract data from SQL Server databases and load it into PostgreSQL.

## Overview

This project implements an automated data pipeline that:
- Extracts data from a SQL Server `table` table
- Performs optional data transformations
- Loads the processed data into a PostgreSQL `L1_Table`

The workflow is orchestrated using Prefect, with containerized deployment using Docker and Docker Compose.

## Features

- **Containerized Deployment**: Full Docker setup with Prefect server and worker pools
- **Database Connectivity**: Support for SQL Server (via ODBC) and PostgreSQL
- **Modular Architecture**: Separated ETL tasks with Prefect's task-based workflow
- **Scalable**: Worker pools for distributed execution
- **Version Control**: Tagged versions for tasks and flows
- **Health Checks**: Built-in health monitoring for services

## Prerequisites

- Docker and Docker Compose
- Python 3.13
- Access to SQL Server and PostgreSQL databases
- Microsoft ODBC Driver 18 for SQL Server (automatically installed in container)

## Setup

This section provides detailed step-by-step instructions to set up the Prefect Workflow Automation project from scratch.

### Step 1: Install Prerequisites

#### Docker and Docker Compose
```bash
# Install Docker (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install docker.io docker-compose-plugin

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional, avoids using sudo)
sudo usermod -aG docker $USER
# Logout and login again for group changes to take effect

# Verify installation
docker --version
docker compose version
```

#### Python 3.13 (for local development)
```bash
# Install Python 3.13 (Ubuntu/Debian)
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.13 python3.13-venv

# Verify installation
python3.13 --version
```

### Step 2: Clone and Prepare the Project

```bash
# Clone the repository
git clone <repository-url>
cd prefect-workflow-automation

# Verify project structure
ls -la
# Expected output should show: Dockerfile, docker-compose.yaml, requirements.txt, flow/, etc.
```

### Step 3: Configure Environment

#### Database Preparation

**Source Database (SQL Server):**
- Ensure you have access to a SQL Server instance
- The source table `table` should exist and be accessible
- Note the connection details: server address, port, database name, credentials

**Target Database (PostgreSQL):**
- Prepare a PostgreSQL database for the target data
- The system will create the `L1_Table` table automatically, but ensure the database exists
- Note the connection details: host, port, database name, credentials

#### Environment Variables (Optional)

Create a `.env` file in the project root for sensitive configuration:
```bash
# .env file
PREFECT_API_DATABASE_PASSWORD=your_secure_password
SQL_SERVER_PASSWORD=your_sql_server_password
POSTGRES_PASSWORD=your_postgres_password
```

### Step 4: Configure Prefect Blocks

Before running the ETL flow, you need to create Prefect blocks for database connections.

#### Method 1: Using Prefect UI (Recommended)

1. Start the services:
   ```bash
   docker-compose up --build -d
   ```

2. Access Prefect UI at http://localhost:4200

3. Navigate to **Blocks** in the sidebar

4. Create SQLAlchemy Connector blocks:

   **For SQL Server (Source):**
   - Click **+** to create a new block
   - Select **SQLAlchemy Connector**
   - Name: `sql-block`
   - Connection String: `mssql+pyodbc://username:password@server/database?driver=ODBC+Driver+18+for+SQL+Server`

   **For PostgreSQL (Target):**
   - Click **+** to create a new block
   - Select **SQLAlchemy Connector**
   - Name: `postgre-block`
   - Connection String: `postgresql://username:password@host:port/database`

#### Method 2: Using Prefect CLI

```bash
# Start Prefect server locally first
prefect server start

# Create blocks via CLI
prefect block register --file flow/etl_level_l1_table.py

# Or create manually
prefect block create sqlalchemy-connector sql-block
prefect block create sqlalchemy-connector postgre-block
```

### Step 5: Build and Start Services

```bash
# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d

# View logs
docker-compose logs -f
```

### Step 6: Verify Setup

#### Check Service Health

```bash
# Check running containers
docker-compose ps

# Expected services:
# - postgres (healthy)
# - prefect-server (healthy)
# - worker-pool-1-prd-local (running)
```

#### Test Database Connections

```bash
# Access Prefect container
docker-compose exec prefect-server bash

# Test connections (inside container)
python -c "
from prefect_sqlalchemy import SqlAlchemyConnector
try:
    with SqlAlchemyConnector.load('sql-block') as conn:
        print('SQL Server connection: SUCCESS')
except Exception as e:
    print(f'SQL Server connection: FAILED - {e}')

try:
    with SqlAlchemyConnector.load('postgre-block') as conn:
        print('PostgreSQL connection: SUCCESS')
except Exception as e:
    print(f'PostgreSQL connection: FAILED - {e}')
"
```

#### Verify Prefect UI Access

- Open browser to http://localhost:4200
- You should see the Prefect dashboard
- Check that the work pool `TPG_POOLS_POW-PRD-LOCAL` is available

### Step 7: Deploy and Test the Flow

```bash
# Deploy the flow
prefect deploy

# Or run directly for testing
docker-compose exec worker-pool-1-prd-local python flow/etl_level_l1_table.py
```

### Step 8: Monitor and Troubleshoot

#### Common Setup Issues

1. **Port Conflicts:**
   ```bash
   # Check if ports are in use
   sudo netstat -tulpn | grep :4200
   # If needed, change ports in docker-compose.yaml
   ```

2. **Permission Issues:**
   ```bash
   # Ensure proper permissions on project directory
   sudo chown -R $USER:$USER .
   ```

3. **Database Connection Issues:**
   - Verify firewall settings
   - Check database server is running and accessible
   - Validate connection strings

#### Logs and Debugging

```bash
# View all service logs
docker-compose logs

# View specific service logs
docker-compose logs prefect-server
docker-compose logs worker-pool-1-prd-local

# Follow logs in real-time
docker-compose logs -f worker-pool-1-prd-local
```

### Step 9: Production Deployment Considerations

For production deployment:

1. **Security:**
   - Use environment variables for sensitive data
   - Configure proper network isolation
   - Set up SSL/TLS for database connections

2. **Scaling:**
   - Adjust worker pool size based on workload
   - Configure resource limits in docker-compose.yaml
   - Set up monitoring and alerting

3. **Backup:**
   - Regular database backups
   - Flow deployment backups
   - Configuration backups

## Project Structure

```
prefect-workflow-automation/
├── Dockerfile                    # Container build configuration
├── docker-compose.yaml          # Multi-service orchestration
├── requirements.txt             # Python dependencies
├── flow/                        # Prefect flows directory
│   ├── etl_level_l1_table.py  # Main ETL flow
│   ├── prefect.yaml             # Prefect deployment configuration
│   └── packages/                # Shared utilities
│       ├── __init__.py
│       └── sql_statements.py    # SQL query definitions
├── LICENSE                      # Project license
└── README.md                    # This file
```

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd prefect-workflow-automation
   ```

2. **Configure database connections:**
   - Update database connection strings in your Prefect blocks
   - Ensure SQL Server and PostgreSQL are accessible

3. **Build and start services:**
   ```bash
   docker-compose up --build
   ```

This will start:
- PostgreSQL database for Prefect metadata
- Prefect server on port 4200
- Worker pool for executing flows

## Usage

### Accessing Prefect UI

Once services are running, access the Prefect UI at: http://localhost:4200

### Running the ETL Flow

The main ETL flow can be triggered through the Prefect UI or via CLI:

```bash
# Deploy the flow
prefect deploy

# Or run directly (if configured)
prefect flow run main_l1_table
```

### Database Configuration

Create Prefect blocks for database connections:

1. **SQL Server Block** (`sql-block`):
   - Configure connection to source SQL Server database
   - Use SQLAlchemy connection string format

2. **PostgreSQL Block** (`postgre-block`):
   - Configure connection to target PostgreSQL database
   - Ensure the target table `L1_Table` exists or will be created

## Configuration

### Environment Variables

Key environment variables in `docker-compose.yaml`:

- `PREFECT_API_DATABASE_CONNECTION_URL`: PostgreSQL connection for Prefect metadata
- `PREFECT_API_URL`: API endpoint for Prefect server
- `PREFECT_SERVER_API_HOST`: Host binding for server

### Prefect Deployment

The `flow/prefect.yaml` contains deployment configuration:
- **Work Pool**: `TPG_POOLS_POW-PRD-LOCAL`
- **Entrypoint**: `etl_level_l1_table.py:main_l1_table`
- **Working Directory**: `/prefect-etl/prd/level1`

## ETL Process Details

### Extract Phase
- Connects to SQL Server using Prefect SQLAlchemy connector
- Executes query to retrieve all records from `table` table
- Returns data as pandas DataFrame

### Transform Phase
- Currently a pass-through (no transformations applied)
- Can be extended for data cleaning, type conversions, etc.

### Load Phase
- Deletes existing records from target `L1_Table`
- Inserts transformed data using pandas `to_sql` method
- Uses SQLAlchemy engine for database operations

## Development

### Local Development Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run Prefect locally:**
   ```bash
   prefect server start
   ```

3. **Execute flow locally:**
   ```bash
   python flow/etl_level_l1_table.py
   ```

### Modifying SQL Queries

Update queries in `flow/packages/sql_statements.py`:
- `get_data_table()`: Source data extraction query
- `del_data_table()`: Target table cleanup query

### Adding Transformations

Modify the `transform_data` task in `etl_level_l1_table.py` to implement data transformations.

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Verify database credentials and network connectivity
   - Check Prefect block configurations

2. **ODBC Driver Issues**:
   - Ensure Microsoft ODBC Driver 18 is properly installed
   - Check container logs for driver installation errors

3. **Worker Pool Issues**:
   - Verify work pool name matches between deployment and docker-compose
   - Check worker container logs

### Logs

View logs for specific services:
```bash
# Prefect server logs
docker-compose logs prefect-server

# Worker logs
docker-compose logs worker-pool-1-prd-local

# PostgreSQL logs
docker-compose logs postgres
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the terms specified in the LICENSE file.

## Version

Current version: v1.0.0

## Author

Created by: Fathih Adawi Ahmad
Created Date: 2026-04-06
