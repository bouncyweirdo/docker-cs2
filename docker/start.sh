#!/bin/bash

CS2_DIR="/home/steam/cs2"
CS2_BIN="$CS2_DIR/game/cs2.sh"
STEAMCMD_DIR="/home/steam/steamcmd"

# steamclient.so symlink
mkdir -p ~/.steam/sdk64
ln -sfT "$STEAMCMD_DIR/linux64/steamclient.so" ~/.steam/sdk64/steamclient.so

# Install or update CS2 (skip if updated within last 24h)
UPDATE_STAMP="$CS2_DIR/.last_update"
UPDATE_INTERVAL=$((24 * 3600))
NEEDS_UPDATE=true

if [ -f "$UPDATE_STAMP" ] && [ -f "$CS2_BIN" ]; then
    LAST_UPDATE=$(cat "$UPDATE_STAMP")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_UPDATE))
    if [ "$ELAPSED" -lt "$UPDATE_INTERVAL" ]; then
        HOURS_AGO=$(( ELAPSED / 3600 ))
        echo "CS2 was updated ${HOURS_AGO}h ago, next check in $(( (UPDATE_INTERVAL - ELAPSED) / 3600 ))h. Skipping update."
        NEEDS_UPDATE=false
    fi
fi

if [ "$NEEDS_UPDATE" = true ]; then
    echo "Installing/updating CS2..."
    MAX_ATTEMPTS=3
    attempt=0
    steamcmd_rc=1

    while [ "$steamcmd_rc" -ne 0 ] && [ "$attempt" -lt "$MAX_ATTEMPTS" ]; do
        attempt=$((attempt + 1))
        if [ "$attempt" -gt 1 ]; then
            echo "Retrying (attempt $attempt/$MAX_ATTEMPTS)..."
            rm -rf "$CS2_DIR/steamapps"
        fi
        "$STEAMCMD_DIR/steamcmd.sh" \
            +force_install_dir "$CS2_DIR" \
            +login anonymous \
            +app_update 730 validate \
            +quit
        steamcmd_rc=$?
    done

    if [ "$steamcmd_rc" -eq 0 ]; then
        date +%s > "$UPDATE_STAMP"
    fi
fi

# If the binary is missing, force install regardless of timestamp
if [ ! -f "$CS2_BIN" ]; then
    echo "CS2 binary not found. Clearing stale data and installing..."
    rm -rf "$CS2_DIR/steamapps"
    rm -f "$UPDATE_STAMP"
    "$STEAMCMD_DIR/steamcmd.sh" \
        +force_install_dir "$CS2_DIR" \
        +login anonymous \
        +app_update 730 validate \
        +quit
    date +%s > "$UPDATE_STAMP"
fi

if [ ! -f "$CS2_BIN" ]; then
    echo "ERROR: CS2 binary still not found at $CS2_BIN"
    exit 1
fi

# Generate server.cfg (applied after gamemode config, so settings stick)
SERVER_CFG="$CS2_DIR/game/csgo/cfg/server.cfg"
cat > "$SERVER_CFG" <<EOF
mp_maxrounds ${CS2_MAXROUNDS:-24}
mp_freezetime ${CS2_FREEZETIME:-15}
mp_buytime ${CS2_BUYTIME:-20}
mp_autoteambalance ${CS2_AUTOTEAMBALANCE:-1}
mp_friendlyfire ${CS2_FRIENDLYFIRE:-1}
mp_overtime_enable ${CS2_OVERTIME:-0}
EOF
echo "Generated server.cfg"

# Build launch arguments
SV_SETSTEAMACCOUNT_ARGS=""
if [ -n "$SRCDS_TOKEN" ]; then
    SV_SETSTEAMACCOUNT_ARGS="+sv_setsteamaccount $SRCDS_TOKEN"
fi

CS2_PW_ARGS=""
if [ -n "$CS2_PW" ]; then
    CS2_PW_ARGS="+sv_password $CS2_PW"
fi

CS2_RCON_ARGS=""
if [ -n "$CS2_RCONPW" ]; then
    CS2_RCON_ARGS="+rcon_password $CS2_RCONPW"
fi

# Start CS2 server
exec bash "$CS2_DIR/game/cs2.sh" -dedicated \
    -console \
    -usercon \
    -port "${CS2_PORT:-27015}" \
    -maxplayers "${CS2_MAXPLAYERS:-10}" \
    +game_type "${CS2_GAMETYPE:-0}" \
    +game_mode "${CS2_GAMEMODE:-1}" \
    +mapgroup "${CS2_MAPGROUP:-mg_active}" \
    +map "${CS2_STARTMAP:-de_dust2}" \
    +hostname "${CS2_SERVERNAME:-CS2 Server}" \
    ${SV_SETSTEAMACCOUNT_ARGS} \
    ${CS2_PW_ARGS} \
    ${CS2_RCON_ARGS} \
    +sv_cheats "${CS2_CHEATS:-0}" \
    +sv_lan "${CS2_LAN:-0}" \
    +servercfgfile "server.cfg" \
    "$@"
