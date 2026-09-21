FROM silentmecha/palworld-server:latest

ENV AUTO_UPDATE=False

RUN bash steamcmd \
	+@ShutdownOnFailedCommand 1 \
        +force_install_dir "${STEAMAPPDIR}" \
        +login anonymous \
        +app_info_update 1 \
        +app_update "${STEAMAPP_ID}" \
        +quit
