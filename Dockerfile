FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# system + node
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg git && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*


# clone
WORKDIR /opt/src
RUN git clone https://github.com/HKUDS/nanobot.git .

# build bridge once
WORKDIR /opt/src/bridge
RUN npm install && npm run build

# install python
WORKDIR /opt/src
RUN uv pip install --system --no-cache .

# vendor bridge into site-packages
RUN python - <<'PY'
import nanobot, pathlib, shutil
pkg = pathlib.Path(nanobot.__file__).parent
dst = pkg / "bridge"
src = pathlib.Path("/opt/src/bridge")
if dst.exists():
    shutil.rmtree(dst)
shutil.copytree(src, dst)
PY

# runtime
VOLUME /root/.nanobot

ENTRYPOINT ["sh", "-c", "\
if [ ! -f /root/.nanobot/bridge/dist/index.js ]; then \
  rm -rf /root/.nanobot/bridge; \
  mkdir -p /root/.nanobot; \
  cp -a /usr/local/lib/python3.12/site-packages/nanobot/bridge /root/.nanobot/bridge; \
fi; \
exec nanobot \"$@\" \
", "--"]

CMD ["status"]

