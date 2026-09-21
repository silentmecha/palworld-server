FROM silentmecha/palworld-server:latest

ENV AUTO_UPDATE=False

RUN bash steamcmd \
	+force_install_dir "${STEAMAPPDIR}" \
	+login anonymous \
	+app_update "${STEAMAPP_ID}" validate \
	+quit