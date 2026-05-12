# Install dependencies
# Use a specific Prefect image with your preferred Python version
FROM prefecthq/prefect:3.5.0-python3.13

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unixodbc-dev \
    --no-install-recommends \
    && curl -sSL -O https://packages.microsoft.com/config/debian/$(. /etc/os-release && echo "$VERSION_ID" | cut -d '.' -f 1)/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install -y msodbcsql18 \
    && rm -rf /var/lib/apt/lists/*

ENV APP_PATH=/opt/prefect
WORKDIR $APP_PATH

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .

