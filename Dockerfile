# Install dependencies
# Use a specific Prefect image with your preferred Python version
FROM prefecthq/prefect:3.5.0-python3.13

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg2 \
    apt-transport-https \
    unixodbc-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -sSl https://packages.microsoft.com/config/debian/12/prod.list -o /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

ENV APP_PATH=/opt/prefect
WORKDIR $APP_PATH

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .

