# CS2 dedicated server

A self-built Docker setup for running a Counter-Strike 2 dedicated server, built on Valve's official [Steam Runtime](https://gitlab.steamos.cloud/steamrt/sniper/platform) base image with SteamCMD.

## Prerequisites

- Docker and Docker Compose
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
| `CS2_MAXPLAYERS` | 10 | Max players |
| `CS2_GAMEMODE` | 1 | 0=casual, 1=competitive, 2=wingman, 3=deathmatch |
| `CS2_GAMETYPE` | 0 | Game type |
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
