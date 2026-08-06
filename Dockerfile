FROM prefecthq/prefect:3.7.8-python3.13

WORKDIR /app

# Install prerequisites
RUN apt-get update && \
    apt-get install -y curl wget gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Register Microsoft GPG key and repository
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list


# Update package list and install ODBC driver
RUN apt-get update && \
    apt-get install -y curl wget gnupg && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev unixodbc libodbc2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Copy flow definitions
# COPY ./flows /app/flows

CMD ["prefect", "worker", "start", "--pool", "default", "--type", "process"]


