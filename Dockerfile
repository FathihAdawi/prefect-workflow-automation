# Install dependencies
# Use a specific Prefect image with your preferred Python version
FROM prefecthq/prefect:3.5.0-python3.13

# Install system dependencies for Microsoft ODBC Driver
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg2 \
    apt-transport-https \
    unixodbc-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://microsoft.com | gpg --dearmor \
    && curl https://microsoft.com > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# ENV APP_HOME=/home/app/web
ENV APP_PATH=.
WORKDIR $APP_PATH

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .

