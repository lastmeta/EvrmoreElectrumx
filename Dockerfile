# Dockerfile
FROM amd64/ubuntu:20.04 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DAEMON_URL=http://someuser:somepassword@evrmore
ENV BANDWIDTH_UNIT_COST=500
ENV CACHE_MB=500
ENV COST_SOFT_LIMIT=800000
ENV COST_HARD_LIMIT=1200000
ENV AIRDROP_CSV_FILE=/home/electrumx/airdropindexes.csv

# Install necessary packages
RUN apt-get update && \
    apt-get install -y git python3 python3-pip python3-venv cmake libleveldb-dev libssl-dev autoconf automake libtool pkg-config curl unzip && \
    apt-get clean

# Create directories
RUN mkdir -p /app /db /home/electrumx /var/lib/evrmore
RUN useradd -ms /bin/bash electrumx

WORKDIR /home/electrumx
COPY ./airdropindexes.csv /home/electrumx/airdropindexes.csv

# # Install Evrmore dependencies

ADD --chown=evrmore https://github.com/EvrmoreOrg/Evrmore/releases/download/v1.0.5/evrmore-1.0.5-b0320a173-x86_64-linux-gnu.tar.gz .
RUN tar -xzf *.tar.gz && rm *.tar.gz
# ENV PATH="/home/evrmore/evrmore:${PATH}"
RUN apt-get update && \
apt-get install -y --no-install-recommends \
python3-venv git cmake libleveldb-dev libssl-dev && \
apt-get clean
RUN mv evrmore-1.0.5-b0320a173 evrmore
# RUN autoreconf -i && ./autogen.sh && ./configure --disable-tests BDB_LIBS="-L/home/evrmore/build/db4/lib -ldb_cxx-4.8" BDB_CFLAGS="-I/home/evrmore/build/db4/include" --with-gui=no && make -j4

# Set up ElectrumX
WORKDIR /home/electrumx

# Install ElectrumX dependencies
ARG VERSION=1.12.1
ADD --chown=electrumx https://github.com/EvrmoreOrg/electrumx-evrmore/archive/refs/tags/v${VERSION}-evr.tar.gz .
RUN tar zxvf *.tar.gz && rm *.tar.gz
WORKDIR /home/electrumx/electrumx-evrmore-${VERSION}-evr
RUN pip install git+https://github.com/EvrmoreOrg/cpp-evrprogpow.git#egg=evrhash
RUN python3 -m pip install -r requirements.txt
RUN python3 setup.py install
WORKDIR /home/electrumx
# RUN rm -r electrumx-evrmore-${VERSION}-evr

# Set environment variables for ElectrumX
ENV SERVICES="ssl://:50002,tcp://:50001,rpc://:8000"
ENV COIN=Evrmore
ENV DB_DIRECTORY=/db
ENV ALLOW_ROOT=true
ENV MAX_SEND=10000000
ENV BANDWIDTH_UNIT_COST=5000
ENV CACHE_MB=1000
ENV EVENT_LOOP_POLICY=uvloop
ENV SSL_CERTFILE="${DB_DIRECTORY}/ssl_cert/server.crt"
ENV SSL_KEYFILE="${DB_DIRECTORY}/ssl_cert/server.key"
ENV DOCKER_HOST=unix:///var/run/docker.sock
# Expose ports
EXPOSE 8819 8820 8000 50001 50002

# Start the services
COPY ./start_services.sh /home/electrumx/start_services.sh
RUN chmod +x /home/electrumx/start_services.sh

COPY ./socket /home/electrumx/socket
RUN cd /home/electrumx/socket && ls
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.2.2"
ENV PATH="/root/.bun/bin:${PATH}"

ENTRYPOINT ["/home/electrumx/start_services.sh"]
