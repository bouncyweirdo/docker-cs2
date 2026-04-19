FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform AS steamcmd

RUN useradd -m -s /bin/bash -u 1000 steam

USER steam
WORKDIR /home/steam

# Install and bootstrap SteamCMD (creates linux64/steamclient.so)
RUN mkdir -p steamcmd && \
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C steamcmd && \
    steamcmd/steamcmd.sh +quit

# CS2 app dir (chmod 0777 so bind mounts work regardless of host UID)
RUN mkdir -p /home/steam/cs2 && chmod 0777 /home/steam/cs2

COPY --chown=steam:steam entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

EXPOSE 27015/tcp 27015/udp 27020/udp

USER steam
CMD ["bash", "entrypoint.sh"]
