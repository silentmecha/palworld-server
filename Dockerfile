FROM silentmecha/palworld-server:latest

ARG STEAM_LOGIN=anonymous

ENV AUTO_UPDATE=False

RUN steamcmd \
        +login "${STEAM_LOGIN}" \
        +app_info_update 1 \
        +quit

RUN steamcmd \
        +force_install_dir "${STEAMAPPDIR}" \
        +login "${STEAM_LOGIN}" \
        +app_update "${STEAMAPP_ID}" validate \
        +quit
