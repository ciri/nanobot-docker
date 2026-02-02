FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
      git \
      curl \
      ca-certificates \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN git clone https://github.com/HKUDS/nanobot.git \
 && pip install -e nanobot

VOLUME /root/.nanobot

ENTRYPOINT ["nanobot"]
CMD ["agent"]

