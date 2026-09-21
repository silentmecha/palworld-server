[![Docker Pulls](https://img.shields.io/docker/pulls/silentmecha/palworld-server.svg)](https://hub.docker.com/r/silentmecha/palworld-server)
[![Image Size](https://img.shields.io/docker/image-size/silentmecha/palworld-server/latest.svg)](https://hub.docker.com/r/silentmecha/palworld-server)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-success?logo=buy-me-a-coffee\&logoColor=white)](https://www.buymeacoffee.com/silent001)

# silentmecha/palworld-server

This repository contains the files needed to build and run a Docker image for a Palworld dedicated server. This image is built on the `silentmecha/steamcmd` base image and uses the official Palworld dedicated server available through SteamCMD.

> **Warning:** The latest version on Docker Hub may be out of date. Please check the GitHub repository for the most recent updates.

## Usage

This stack uses an image from [atmoz](https://github.com/atmoz). To see more on the image used visit their GitHub https://github.com/atmoz/sftp.

For more info on environment variables and what they do see [Environment Variables](#environment-variables).

### Available Tags

* `base`: Contains only the environment setup, excluding the game files.
* `latest`: Includes the game files needed for the server.

### Simplest Method

The simplest usage for this is using the `docker-compose` method to pull the `latest` image and run it.

```console
git clone https://github.com/silentmecha/palworld-server.git palworld-server
cd palworld-server
cp .env.example .env
nano .env
docker-compose pull
docker-compose up -d
```

### Building Locally

If you prefer to build everything locally, you can start by building the `base` image and then the `latest` image.

```console
git clone https://github.com/silentmecha/palworld-server.git palworld-server
cd palworld-server
cp .env.example .env
nano .env
docker build -f base.Dockerfile -t silentmecha/palworld-server:base -t silentmecha/palworld-server:latest .
docker build -f Dockerfile -t silentmecha/palworld-server:latest .
docker-compose up -d
```

### Updating

Updating is now as simple as running a build on the `Dockerfile` or using `docker-compose build`. This will update the image without downloading all the game files again.

```console
docker-compose build
docker-compose up -d
```

Your save data is stored separately from the game server files, so updating the image will not remove your saved data.

### Environment Variables

| Variable Name      | Default Value   | Description                                                        |
| ------------------ | --------------- | ------------------------------------------------------------------ |
| SERVER_NAME        | Palworld Docker | Name of your server as seen in the server browser (accepts spaces) |
| SERVER_DESCRIPTION |                 | Description of your server                                         |
| SERVER_PASSWORD    |                 | Password to enter your server                                      |
| ADMIN_PASSWORD     | ChangeMe        | Admin access password                                              |
| MAX_PLAYERS        | 32              | Maximum number of players                                          |
| PORT               | 8211            | Port used to connect to the server                                 |
| RESTAPI_ENABLED    | True            | Enable REST API access                                             |
| RESTAPI_PORT       | 8212            | Port for REST API connections                                      |
| RCON_ENABLED       | False           | Enable RCON access                                                 |
| RCON_PORT          | 25575           | Port for RCON connections                                          |
| PUBLIC_LOBBY       | True            | Enable the server to appear in the community server list           |
| PALBOX_EXPORT      | True            | Allow players to export Pals to the Global Palbox                  |
| PALBOX_IMPORT      | True            | Allow players to import Pals from the Global Palbox                |
| SHOW_PLAYER_LIST   | True            | Show the player list on the server                                 |
| ADDITIONAL_ARGS    |                 | Additional arguments passed to the server                          |
| SFT_USER           | foo             | Username for SFTP access to edit save data                         |
| SFT_PASS           | pass            | Password for SFTP access                                           |
| SFT_PORT           | 2522            | Port for SFTP access (should not be 22)                            |

For more info on the usage of SFTP see [here](https://github.com/atmoz/sftp). If you do not want to use a plain text password see [encrypted-password](https://github.com/atmoz/sftp#encrypted-password).

### Server Description

`SERVER_DESCRIPTION` supports multiline descriptions.

Use literal `\n` characters where you want a line break.

**The value must be enclosed in single quotes in `.env`.**

For example:

```dotenv
SERVER_DESCRIPTION='This is a Palworld server.\n\nThis is the second paragraph.\nThis is another line.'
```

Do not use double quotes for multiline descriptions:

```dotenv
SERVER_DESCRIPTION="This is a Palworld server.\n\nThis is the second paragraph."
```

Single quotes ensure Docker Compose preserves the literal `\n` characters. Palworld then interprets them as line breaks when displaying the server description.


### Ports

Currently the following ports are used.

| Port         | Type | Default |
| ------------ | ---- | ------- |
| PORT         | UDP  | 8211    |
| RESTAPI_PORT | TCP  | 8212    |
| RCON_PORT    | TCP  | 25575   |
| SFT_PORT     | TCP  | 2522    |

The `RESTAPI_PORT` and `RCON_PORT` mappings are commented out in `docker-compose.yml` by default. This prevents the REST API and RCON from being exposed outside of the Docker container.

If you wish to access either the REST API or RCON externally, uncomment the corresponding port mapping in `docker-compose.yml`.

The `PORT` and `SFT_PORT` mappings are enabled by default. `PORT` needs to be forwarded through your router for players to connect to the server. `SFT_PORT` only needs to be forwarded through your router if you wish to remotely edit the save data.

## Additional Arguments

`ADDITIONAL_ARGS` can be used to pass additional Palworld startup arguments to `PalServer.sh`.

For example:

```dotenv
ADDITIONAL_ARGS="-enable-gamedata-api"
```

Multiple arguments can also be specified:

```dotenv
ADDITIONAL_ARGS="-enable-gamedata-api -logformat=text"
```

This allows additional Palworld functionality to be enabled without requiring a dedicated environment variable for every available startup argument.


## Notes

### REST API

The REST API is enabled by default and is used internally by the image for graceful server shutdown.

The REST API is not exposed outside of the Docker container by default. If you wish to access the REST API externally, uncomment the `RESTAPI_PORT` mapping in `docker-compose.yml`.

### RCON

RCON support is included for compatibility with existing tools and configurations.

> **NB:** Palworld RCON is deprecated by Pocketpair and is scheduled to stop functioning in an upcoming update. The REST API is recommended for new deployments.

The RCON port is not exposed outside of the Docker container by default. If you need external RCON access, uncomment the `RCON_PORT` mapping in `docker-compose.yml`.

## License

This project is licensed under the [MIT License](LICENSE).

If you enjoy this project and would like to support my work, consider [buying me a coffee](https://www.buymeacoffee.com/silent001). Your support is greatly appreciated!