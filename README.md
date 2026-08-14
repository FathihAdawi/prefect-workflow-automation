# Prefect workflow automation

This repository provides a simple Prefect 3 setup that runs a workflow with Docker Compose, a local Python virtual environment, and optional scheduling.

## What this project does

- Starts a Prefect server and PostgreSQL database with Docker Compose.
- Runs a worker that can execute Prefect deployments.
- Lets you deploy a flow from a Python entrypoint such as `flow.py`.
- Lets you attach a schedule so the deployment runs automatically.

## Prerequisites

- Docker Engine or Docker Desktop
- Docker Compose plugin
- Python 3.11+ (the container uses Python 3.13)
- Git

## 1. Clone the repository

```bash
git clone <your-repository-url>
cd prefect-workflow-automation
```

## 2. Start the Prefect server with Docker Compose

From the project root, start the database and Prefect UI/API:

```bash
docker compose build --no-cache
docker compose up -d
```

Verify that the services are running:

```bash
docker compose ps
```

Open the Prefect UI in your browser:

```text
http://localhost:4200
```

If you want to follow the logs:

```bash
docker compose logs -f prefect-server
```

## 3. Create a Python virtual environment

### Windows PowerShell

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### Linux or macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Set the Prefect API URL so your local Python environment talks to the Docker Compose server:

```bash
export PREFECT_API_URL=http://127.0.0.1:4200/api
```

On Windows PowerShell:

```powershell
$env:PREFECT_API_URL="http://127.0.0.1:4200/api"
```

## 4. Create a flow entrypoint

The repository includes a deployment example in `flow/deploy.py`, but you can also define your own entrypoint such as `flow.py`.

Example:

```python
from prefect import flow


@flow
def hello_flow():
    print("Hello from Prefect")


if __name__ == "__main__":
    hello_flow()
```

## 5. Deploy the flow

The easiest way in this repository is to adapt `flow/deploy.py` to point to your flow and then run it:

```bash
python flow/deploy.py
```

A minimal deployment script looks like this:

```python
from prefect import flow


@flow
def my_flow():
    print("Running my flow")


if __name__ == "__main__":
    my_flow.deploy(
        name="demo-deployment",
        work_pool_name="WORKER-1",
    )
```

The worker defined in `docker-compose.yaml` uses the pool name `WORKER-1`, so the deployment and worker should use the same pool name.

## 6. Start the worker

If you want to use the worker that is already defined in Docker Compose, start it with:

```bash
docker compose up -d worker-pool-1-local
```

If you prefer to run a local worker from your virtual environment instead, use:

```bash
prefect worker start --pool "WORKER-1" --name "local-worker"
```

## 7. Run the deployment manually

After the deployment is created, you can run it from the Prefect UI or from the CLI:

```bash
prefect deployment run 'demo-deployment/demo-deployment'
```

Replace the deployment name with your own deployment path if needed.

## 8. Create a schedule

Schedules are usually added from the Prefect UI after the deployment exists.

1. Open the Prefect UI.
2. Go to Deployments.
3. Open your deployment.
4. Add a schedule.
5. Use a cron expression such as:
   - `0 * * * *` for every hour
   - `*/15 * * * *` for every 15 minutes
   - `0 9 * * *` for 9:00 AM every day

You can also attach a schedule in Python when you deploy the flow, for example with a cron-based schedule object.

## 9. Useful commands

```bash
# Stop everything
docker compose down

# Rebuild containers after changes
docker compose up -d --build

# View worker logs
docker compose logs -f worker-pool-1-local
```

## Project structure

```text
prefect-workflow-automation/
├── Dockerfile
├── docker-compose.yaml
├── requirements.txt
├── flow/
│   └── deploy.py
└── README.md
```

## Troubleshooting

- If the UI is not available yet, wait a few seconds and check `docker compose ps`.
- If the worker cannot connect, make sure `PREFECT_API_URL` points to `http://127.0.0.1:4200/api`.
- If Docker complains about ports already being used, stop the conflicting process or change the port mapping in `docker-compose.yaml`.
- If PowerShell blocks activation of the virtual environment, run:

```powershell
Set-ExecutionPolicy -Scope Process RemoteSigned
```
