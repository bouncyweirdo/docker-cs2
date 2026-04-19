FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform AS steamcmd

RUN useradd -m -s /bin/bash -u 1000 steam

USER steam
WORKDIR /home/steam

# Install and bootstrap SteamCMD (creates linux64/steamclient.so)
RUN mkdir -p steamcmd && \
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C steamcmd && \
    steamcmd/steamcmd.sh +quit

RUN mkdir -p /home/steam/cs2

COPY --chown=steam:steam entrypoint.sh start.sh /home/steam/
RUN chmod +x /home/steam/entrypoint.sh /home/steam/start.sh

EXPOSE 27015/tcp 27015/udp 27020/udp

# Start as root so entrypoint can fix bind mount permissions, then drop to steam
USER root
CMD ["bash", "entrypoint.sh"]
