#!/bin/bash

cd "${STEAMAPPDIR}"

# NOTE: Without the wait the script exits before giving the server time to properly stop
function clean_up() {
    if [ -n "${serverPID}" ] && kill -0 "${serverPID}" 2>/dev/null; then

        if [ "${RESTAPI_ENABLED,,}" = "true" ] && \
           curl -s --fail \
           -u "admin:${ADMIN_PASSWORD}" \
           "http://127.0.0.1:${RESTAPI_PORT}/v1/api/info" \
           >/dev/null 2>&1; then

            for seconds in 5 4 3 2 1; do
                curl -s \
                    -u "admin:${ADMIN_PASSWORD}" \
                    -H "Content-Type: application/json" \
                    -X POST \
                    "http://127.0.0.1:${RESTAPI_PORT}/v1/api/announce" \
                    --data "{\"message\":\"Server shutting down in ${seconds} second(s)!\"}" \
                    >/dev/null 2>&1
                sleep 1
            done

            curl -s \
                -u "admin:${ADMIN_PASSWORD}" \
                -X POST \
                "http://127.0.0.1:${RESTAPI_PORT}/v1/api/save" \
                >/dev/null 2>&1

            curl -s \
                -u "admin:${ADMIN_PASSWORD}" \
                -H "Content-Type: application/json" \
                -X POST \
                "http://127.0.0.1:${RESTAPI_PORT}/v1/api/shutdown" \
                --data '{"waittime":5,"message":"Server shutting down."}' \
                >/dev/null 2>&1

            sleep 10

            # Force shutdown through the REST API if the server is still running.
            if kill -0 "${serverPID}" 2>/dev/null; then
                curl -s \
                    -u "admin:${ADMIN_PASSWORD}" \
                    -X POST \
                    "http://127.0.0.1:${RESTAPI_PORT}/v1/api/stop" \
                    >/dev/null 2>&1
            fi
        fi

        # Force shutdown if the server is still running.
        if kill -0 "${serverPID}" 2>/dev/null; then
            kill -SIGINT "${serverPID}"
        fi

        wait "${serverPID}"
    fi
}

# Setup trap
trap "clean_up" SIGINT SIGTERM

# Create the active configuration if it does not exist.
if [ ! -f "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" ]; then
    mkdir -p "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer"

    cp "${STEAMAPPDIR}/DefaultPalWorldSettings.ini" \
       "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
fi

# Update string configuration.
# Replace user supplied values with environment variable placeholders.
sed -i \
    -e 's|ServerName="[^"]*"|ServerName="${SERVER_NAME}"|' \
    -e 's|ServerDescription="[^"]*"|ServerDescription="${SERVER_DESCRIPTION}"|' \
    -e 's|ServerPassword="[^"]*"|ServerPassword="${SERVER_PASSWORD}"|' \
    -e 's|AdminPassword="[^"]*"|AdminPassword="${ADMIN_PASSWORD}"|' \
    "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"

# Substitute environment variables into the configuration.
envsubst '${SERVER_NAME} ${SERVER_DESCRIPTION} ${SERVER_PASSWORD} ${ADMIN_PASSWORD}' \
    < "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini" \
    > "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini.tmp"

mv \
    "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini.tmp" \
    "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"

# Update server configuration.
sed -i \
    -e "s|ServerPlayerMaxNum=[^,)]*|ServerPlayerMaxNum=${MAX_PLAYERS}|" \
    -e "s|RESTAPIEnabled=[^,)]*|RESTAPIEnabled=${RESTAPI_ENABLED}|" \
    -e "s|RESTAPIPort=[^,)]*|RESTAPIPort=${RESTAPI_PORT}|" \
    -e "s|RCONEnabled=[^,)]*|RCONEnabled=${RCON_ENABLED}|" \
    -e "s|RCONPort=[^,)]*|RCONPort=${RCON_PORT}|" \
    -e "s|bAllowGlobalPalboxExport=[^,)]*|bAllowGlobalPalboxExport=${PALBOX_EXPORT}|" \
    -e "s|bAllowGlobalPalboxImport=[^,)]*|bAllowGlobalPalboxImport=${PALBOX_IMPORT}|" \
    -e "s|bShowPlayerList=[^,)]*|bShowPlayerList=${SHOW_PLAYER_LIST}|" \
    "${STEAMAPPDIR}/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"

# Build launch arguments.
launch_args=(
    "-port=${PORT}"
    "-players=${MAX_PLAYERS}"
)

if [ "${PUBLIC_LOBBY,,}" = "true" ]; then
    launch_args+=("-publiclobby")
fi

if [ -n "${ADDITIONAL_ARGS}" ]; then
    read -r -a additional_args <<< "${ADDITIONAL_ARGS}"
    launch_args+=("${additional_args[@]}")
fi

# Launch Palworld
./PalServer.sh "${launch_args[@]}" &
serverPID=$!

wait "${serverPID}"

exit 0