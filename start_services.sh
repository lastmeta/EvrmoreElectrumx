#!/bin/bash
# Start the evrmored service
/home/electrumx/evrmore/bin/evrmored -datadir=/var/lib/evrmore -printtoconsole -onlynet=ipv4 &

# Check for SSL certs and create them if they don't exist
if [ -d "$DB_DIRECTORY/ssl_cert/" ]; then
    echo "SSL certs exist."
else 
    mkdir -p "$DB_DIRECTORY/ssl_cert" && \
    cd "$DB_DIRECTORY/ssl_cert" && \
    openssl genrsa -out server.key 2048 && \
    openssl req -new -key server.key -out server.csr -subj "/C=AU" && \
    openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt
fi
# Start ElectrumX
electrumx_server &

# Start the socket service
cd /home/electrumx/socket && bun install && bun run start

# Wait for all background processes
wait