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
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev unixodbc libodbc2 default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fix for SQL Server connection error 0x2746
# Handling old TLS/SSL issue while connecting to sql server 2014 or lower version
RUN sed -i 's/openssl_conf = openssl_init/openssl_conf = default_conf/g' /etc/ssl/openssl.cnf && \
    echo "[default_conf]" >> /etc/ssl/openssl.cnf && \
    echo "ssl_conf = ssl_sect" >> /etc/ssl/openssl.cnf && \
    echo "[ssl_sect]" >> /etc/ssl/openssl.cnf && \
    echo "system_default = system_default_sect" >> /etc/ssl/openssl.cnf && \
    echo "[system_default_sect]" >> /etc/ssl/openssl.cnf && \
    echo "MinProtocol = TLSv1" >> /etc/ssl/openssl.cnf && \
    echo "CipherString = DEFAULT@SECLEVEL=0" >> /etc/ssl/openssl.cnf

# (Optional) If you specifically need the raw Microsoft JDBC .jar file for a JVM app inside Prefect:
RUN mkdir -p /opt/microsoft/jdbc \
    && curl -L -o /opt/microsoft/jdbc/mssql-jdbc.jar \
    https://github.com

ENV CLASSPATH=$CLASSPATH:/opt/microsoft/jdbc/mssql-jdbc.jar

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Copy flow definitions
# COPY ./flows /app/flows

CMD ["prefect", "worker", "start", "--pool", "default", "--type", "process"]


