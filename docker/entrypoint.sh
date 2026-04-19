#!/bin/bash

# Fix bind mount permissions so steam user can write
chown -R steam:steam /home/steam/cs2 2>/dev/null || true

# Run the server as steam user
exec su steam -s /bin/bash -c "/home/steam/start.sh"
