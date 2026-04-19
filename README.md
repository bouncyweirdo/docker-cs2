# CS2 dedicated server

A self-built Docker setup for running a Counter-Strike 2 dedicated server, built on Valve's official [Steam Runtime](https://gitlab.steamos.cloud/steamrt/sniper/platform) base image with SteamCMD.

## Table of contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Commands](#commands)
- [Connecting to the server](#connecting-to-the-server)
- [RCON (remote administration)](#rcon-remote-administration)
- [Project structure](#project-structure)
- [Ports](#ports)

## Prerequisites

- Docker Engine 20.10+ with Compose plugin (`docker compose`)
- A Steam Game Server Login Token (GSLT) from https://steamcommunity.com/dev/managegameservers (app ID 730)

## Quick start

```bash
# 1. Create your config
./cs2.sh init
# Edit .env with your SRCDS_TOKEN and other settings

# 2. Build the image (first build downloads ~35GB)
./cs2.sh build

# 3. Start the server
./cs2.sh start
```

## Configuration

Copy `.env.example` to `.env` and edit it. Key settings:

| Variable | Default | Description |
|---|---|---|
| `SRCDS_TOKEN` | | **Required.** Your GSLT token |
| `CS2_SERVERNAME` | My CS2 Server | Server name |
| `CS2_PORT` | 27015 | Server port |
| `CS2_PW` | | Server password (empty = no password) |
| `CS2_RCONPW` | | RCON password (empty = RCON disabled) |
| `CS2_MAXPLAYERS` | 10 | Max players |
| `CS2_GAMETYPE` | 0 | 0=standard (casual/competitive/wingman), 1=deathmatch |
| `CS2_GAMEMODE` | 1 | When gametype=0: 0=casual, 1=competitive, 2=wingman. When gametype=1: 2=deathmatch |
| `CS2_STARTMAP` | de_dust2 | Starting map |
| `CS2_MAPGROUP` | mg_active | Map group |
| `CS2_FREEZETIME` | 15 | Buy time before round (seconds) |
| `CS2_LAN` | 0 | LAN mode |
| `CS2_CHEATS` | 0 | Allow cheats |
| `CS2_UPDATE` | 1 | Auto-update CS2 on container start |

## Commands

All commands are run through `./cs2.sh`:

### Setup

```bash
./cs2.sh init           # create .env from .env.example
./cs2.sh build          # build the Docker image
./cs2.sh rebuild        # force rebuild (no cache)
```

### Server

```bash
./cs2.sh start          # start the server
./cs2.sh stop           # stop the server
./cs2.sh restart        # restart the server
./cs2.sh status         # show container status
./cs2.sh logs           # follow server logs
./cs2.sh console        # attach to server console (detach: Ctrl+P, Ctrl+Q)
```

### Game

```bash
./cs2.sh map de_inferno         # change map
./cs2.sh restartmatch           # restart the match
./cs2.sh kick playerName        # kick a player
./cs2.sh say "hello everyone"   # send chat message
./cs2.sh maxrounds 30           # set max rounds
./cs2.sh warmup 60              # set warmup duration
./cs2.sh freezetime 10          # set buy time before round
./cs2.sh cmd mp_autoteambalance 1   # send any server command
```

## Connecting to the server

### Public server (no password)

1. Open CS2 → **Play** → **Community Server Browser**
2. Click **Favorites** → **Add a Server**
3. Enter `YOUR_SERVER_IP:27015`
4. Click **Connect**

Or use the console: `connect YOUR_SERVER_IP:27015`

### Password-protected server

If `CS2_PW` is set in `.env`, players need to provide the password when connecting:

- **Console:** `connect YOUR_SERVER_IP:27015; password yourpassword`
- **Browser:** click Connect and enter the password when prompted

## RCON (remote administration)

RCON lets trusted players run server commands from the in-game console without SSH access. Set `CS2_RCONPW` in `.env` to enable it.

**Player side** — open the CS2 console (`~`) and type:

```
rcon_password yourpassword
rcon changelevel de_inferno
rcon mp_restartgame 1
rcon mp_maxrounds 30
```

Once authenticated, any command prefixed with `rcon` runs on the server. The password persists until you disconnect.

**Common RCON commands:**

| Command | Description |
|---|---|
| `rcon changelevel de_mirage` | Change map |
| `rcon mp_restartgame 1` | Restart match |
| `rcon mp_maxrounds 30` | Set max rounds |
| `rcon mp_warmup_start` | Start warmup |
| `rcon mp_warmup_end` | End warmup |
| `rcon kick playername` | Kick a player |
| `rcon say "message"` | Server chat message |
| `rcon status` | Show connected players |
| `rcon mp_pause_match` | Pause match |
| `rcon mp_unpause_match` | Unpause match |

## Project structure

```
docker-cs2/
├── docker/
│   ├── Dockerfile          # builds the CS2 server image
│   └── entrypoint.sh       # server startup script
├── docker-compose.yml
├── cs2.sh                  # management script
├── .env.example            # config template
└── .env                    # your local config (not committed)
```

## Ports

| Port | Protocol | Description |
|---|---|---|
| 27015 | TCP/UDP | Game server |
| 27020 | UDP | Steam query |
