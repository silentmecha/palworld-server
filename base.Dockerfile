FROM silentmecha/steamcmd:latest

LABEL maintainer="silent@silentmecha.co.za"

ENV STEAMAPP_ID=2394010
ENV STEAMAPP=Palworld
ENV STEAMAPPDIR="${HOME}/${STEAMAPP}-dedicated"
# Global save-data location is inherited from the steamcmd base image.
# Save data is now stored in: ${HOME}/save-data
ENV STEAM_BACKUPDIR="${STEAM_SAVEDIR}/backup"
ENV AUTO_UPDATE=True
ENV STEAM_LOGIN=anonymous

USER root

COPY ./src/entry.sh ${HOME}/entry.sh

RUN set -x \
    && mkdir -p \
        "${STEAMAPPDIR}/Pal" \
        "${STEAM_SAVEDIR}/Saved" \
    && ln -s "${STEAM_SAVEDIR}/Saved" "${STEAMAPPDIR}/Pal/Saved" \
    && chmod 755 "${HOME}/entry.sh" \
    && chown -R "${USER}:${USER}" \
        "${HOME}/entry.sh" \
        "${STEAMAPPDIR}" \
        "${STEAM_SAVEDIR}"

ENV SERVER_NAME="Palworld Docker" \
    SERVER_DESCRIPTION="" \
    SERVER_PASSWORD="" \
    ADMIN_PASSWORD="ChangeMe" \
    MAX_PLAYERS=32 \
    PORT=8211 \
    RESTAPI_ENABLED=True \
    RESTAPI_PORT=8212 \
    RCON_ENABLED=False \
    RCON_PORT=25575 \
    PUBLIC_LOBBY=True \
    PALBOX_EXPORT=True \
    PALBOX_IMPORT=True \
    SHOW_PLAYER_LIST=True \
    ADDITIONAL_ARGS=

# Switch to user
USER ${USER}

WORKDIR ${HOME}

EXPOSE ${PORT}/udp \
       ${RESTAPI_PORT}/tcp \
       ${RCON_PORT}/tcp

CMD ["bash", "entry.sh"]