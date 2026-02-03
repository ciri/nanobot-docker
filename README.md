# nanobot-docker

[![Docker](https://img.shields.io/badge/docker-ready-blue)](https://www.docker.com/)
[![Node](https://img.shields.io/badge/node-20%2B-brightgreen)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/python-3.12-blue)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

Dockerized Nanobot with **Channels support** (Node 20 + Python 3.12).

Based on the official Nanobot project:
[https://github.com/HKUDS/nanobot](https://github.com/HKUDS/nanobot)

This setup lets you run Nanobot fully inside Docker, including `channels login`, without installing Node or Python on the host.

Tested on Debian.

---

## Build/Install

```bash
git clone https://github.com/ciri/nanobot-docker.git 
cd nanobot-docker
docker build -t nanobot .
```

---

## First-time setup (onboard)

Create a local state directory:

```bash
mkdir -p .nanobot
```

Run onboarding:

```bash
docker run -it \
  -v $(pwd)/.nanobot:/root/.nanobot \
  nanobot onboard
```

This creates:

```
.nanobot/
├── config.json
├── workspace/
├── AGENTS.md
├── SOUL.md
├── USER.md
└── memory/
```

Edit `.nanobot/config.json` locally and add your API keys.

---

## Channels login 

Follow the instructions in the original repository. For Whatsapp:

```bash
docker run -it \
  -v $(pwd)/.nanobot:/root/.nanobot \
  nanobot channels login
```

This step requires Node >= 20, which is already included in the image.

For Telegram, if you have the config.json set-up with your bot's name/key, just run the gateway:

```bash
docker run -it \
  -v $(pwd)/.nanobot:/root/.nanobot \
  nanobot gateway
```

---

## Run agent

```bash
docker run -it \
  -v $(pwd)/.nanobot:/root/.nanobot \
  nanobot agent -m "Hello"
```

---

## Platform

* Tested on Debian 12 (bookworm)

* Kernel: Linux 6.1 (amd64)

* No local Node.js required

* No local Python required

* State is persisted via `./.nanobot`

---

## License

MIT
