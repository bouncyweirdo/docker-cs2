#!/bin/bash

CONTAINER_NAME="cs2-server"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
    echo "Usage: ./cs2.sh <command> [args]"
    echo ""
    echo "Setup:"
    echo "  init              Create .env from .env.example"
    echo "  build             Build and restart (uses cache)"
    echo "  rebuild           Build from scratch (no cache)"
    echo "  update            Force CS2 game update (restarts server)"
    echo ""
    echo "Server:"
    echo "  start             Start the server"
    echo "  stop              Stop the server"
    echo "  restart           Restart the server"
    echo "  status            Show container status"
    echo "  logs              Show server logs (follow)"
    echo "  console           Attach to server console (detach: Ctrl+P, Ctrl+Q)"
    echo ""
    echo "Game:"
    echo "  map <mapname>     Change map (e.g. de_dust2, de_inferno, de_mirage)"
    echo "  restartmatch      Restart the current match"
    echo "  kick <player>     Kick a player"
    echo "  say <message>     Send a chat message"
    echo "  maxrounds <n>     Set max rounds"
    echo "  warmup <seconds>  Set warmup duration"
    echo "  endwarmup         End warmup immediately"
    echo "  freezetime <secs> Set buy time before round (default 10)"
    echo "  roundtime <min>   Set round time in minutes"
    echo "  buytime <secs>    Set buy time in seconds"
    echo "  pause             Pause the match"
    echo "  unpause           Unpause the match"
    echo "  bot_add           Add a bot"
    echo "  bot_kick          Kick all bots"
    echo "  cheats <0|1>      Enable/disable cheats"
    echo "  password <pw>     Set server password (empty to remove)"
    echo "  players           Show connected players"
    echo "  cmd <command>     Send any server command"
}

send_cmd() {
    docker exec -it "$CONTAINER_NAME" bash -c "echo '$1' > /proc/1/fd/0"
}

case "$1" in
    # Setup
    init)
        if [ -f .env ]; then
            echo ".env already exists. Remove it first if you want to reinitialize."
            exit 1
        fi
        cp .env.example .env
        echo "Created .env from .env.example. Edit it with your settings."
        ;;
    build)
        docker compose down
        docker compose build
        docker compose up -d
        ;;
    rebuild)
        docker compose down
        docker compose build --no-cache
        docker compose up -d
        ;;
    update)
        echo "Forcing CS2 game update..."
        rm -f ./data/cs2/.last_update
        docker compose restart
        ;;

    # Server
    start)
        [ ! -f .env ] && echo "Run './cs2.sh init' first to create .env" && exit 1
        docker compose up -d
        ;;
    stop)
        docker compose down
        ;;
    restart)
        docker compose restart
        ;;
    status)
        docker compose ps
        ;;
    logs)
        docker compose logs -f
        ;;
    console)
        echo "Attaching to server console. Detach with Ctrl+P, Ctrl+Q"
        docker attach "$CONTAINER_NAME"
        ;;

    # Game
    map)
        [ -z "$2" ] && echo "Usage: ./cs2.sh map <mapname>" && exit 1
        send_cmd "changelevel $2"
        echo "Changing map to $2"
        ;;
    restartmatch)
        send_cmd "mp_restartgame 1"
        echo "Restarting match"
        ;;
    kick)
        [ -z "$2" ] && echo "Usage: ./cs2.sh kick <player>" && exit 1
        send_cmd "kick $2"
        echo "Kicking $2"
        ;;
    say)
        shift
        [ -z "$1" ] && echo "Usage: ./cs2.sh say <message>" && exit 1
        send_cmd "say $*"
        ;;
    maxrounds)
        [ -z "$2" ] && echo "Usage: ./cs2.sh maxrounds <n>" && exit 1
        send_cmd "mp_maxrounds $2"
        echo "Max rounds set to $2"
        ;;
    warmup)
        [ -z "$2" ] && echo "Usage: ./cs2.sh warmup <seconds>" && exit 1
        send_cmd "mp_warmuptime $2"
        echo "Warmup time set to $2 seconds"
        ;;
    endwarmup)
        send_cmd "mp_warmup_end"
        echo "Ending warmup"
        ;;
    freezetime)
        [ -z "$2" ] && echo "Usage: ./cs2.sh freezetime <seconds>" && exit 1
        send_cmd "mp_freezetime $2"
        echo "Freeze time set to $2 seconds"
        ;;
    roundtime)
        [ -z "$2" ] && echo "Usage: ./cs2.sh roundtime <minutes>" && exit 1
        send_cmd "mp_roundtime $2"
        echo "Round time set to $2 minutes"
        ;;
    buytime)
        [ -z "$2" ] && echo "Usage: ./cs2.sh buytime <seconds>" && exit 1
        send_cmd "mp_buytime $2"
        echo "Buy time set to $2 seconds"
        ;;
    pause)
        send_cmd "mp_pause_match"
        echo "Match paused"
        ;;
    unpause)
        send_cmd "mp_unpause_match"
        echo "Match unpaused"
        ;;
    bot_add)
        send_cmd "bot_add"
        echo "Added a bot"
        ;;
    bot_kick)
        send_cmd "bot_kick"
        echo "Kicked all bots"
        ;;
    cheats)
        [ -z "$2" ] && echo "Usage: ./cs2.sh cheats <0|1>" && exit 1
        send_cmd "sv_cheats $2"
        echo "Cheats set to $2"
        ;;
    password)
        send_cmd "sv_password \"$2\""
        if [ -z "$2" ]; then
            echo "Server password removed"
        else
            echo "Server password set"
        fi
        ;;
    players)
        send_cmd "status"
        echo "Check server console/logs for player list"
        ;;
    cmd)
        shift
        [ -z "$1" ] && echo "Usage: ./cs2.sh cmd <command>" && exit 1
        send_cmd "$*"
        echo "Sent: $*"
        ;;

    *)
        usage
        ;;
esac
