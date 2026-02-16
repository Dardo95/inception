# DEVELOPER DOCUMENTATION

## Purpose

This document explains how to set up, build, manage, and understand the
Inception infrastructure from a developer perspective.

------------------------------------------------------------------------

## Prerequisites

Before starting, ensure the following are installed inside the Virtual
Machine:

-   Docker
-   Docker Compose plugin
-   Make
-   Git

The project must be executed inside a Linux Virtual Machine as required
by the subject.

------------------------------------------------------------------------

## Repository Structure

    inception/
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    ├── secrets/
    └── srcs/
        ├── docker-compose.yml
        ├── .env
        └── requirements/
            ├── mariadb/
            ├── wordpress/
            └── nginx/

All service configuration files are located inside the `srcs/`
directory, as required by the subject.

------------------------------------------------------------------------

## Environment Variables and Secrets

Environment variables are stored in:

    srcs/.env

Sensitive credentials are stored inside:

    secrets/

Secrets include: - db_root_password - db_password - wp_admin_password -
wp_user_password

Secrets are mounted inside containers using Docker secrets and are not
committed to Git.

------------------------------------------------------------------------

## Building and Launching the Project

From the root directory:

``` bash
make
```

This command runs:

``` bash
docker compose -f srcs/docker-compose.yml up -d --build
```

It builds all images from their Dockerfiles and starts the
infrastructure.

------------------------------------------------------------------------

## Managing Containers

Check container status:

``` bash
docker compose ps
```

View logs:

``` bash
docker compose logs
```

Stop containers:

``` bash
make down
```

Rebuild from scratch (including volumes):

``` bash
make fclean
make
```

------------------------------------------------------------------------

## Docker Network

A dedicated Docker bridge network is defined in `docker-compose.yml`.

It allows: - Communication between services using container names -
Isolation from the host network - Secure internal service discovery

------------------------------------------------------------------------

## Data Storage and Persistence

Two Docker named volumes are used:

-   WordPress database
-   WordPress website files

Both volumes are configured with `driver_opts` to store data in:

    /home/enogueir/data/

This ensures persistence across container restarts and Virtual Machine
reboots.

------------------------------------------------------------------------

## Service Details

### MariaDB

-   Initializes database on first startup
-   Uses a marker file to prevent reinitialization
-   Reads passwords from Docker secrets

### WordPress

-   Uses PHP-FPM
-   Automatically installs WordPress via WP-CLI
-   Connects to MariaDB through internal Docker network

### NGINX

-   Only public entrypoint
-   Listens exclusively on port 443
-   Enforces TLSv1.2 and TLSv1.3
-   Forwards PHP requests to WordPress via FastCGI

------------------------------------------------------------------------

## Configuration Modification

During evaluation, configuration changes may be requested (for example,
changing a port).

To apply changes:

1.  Modify the relevant configuration file.
2.  Rebuild the project:

``` bash
make re
```

3.  Verify that the service remains accessible.

------------------------------------------------------------------------

## Notes for Evaluation

-   No container uses `network: host` or `links`.
-   No infinite loops or hacky patches (such as `tail -f`) are used.
-   All containers are built from Debian.
-   No passwords are stored inside Dockerfiles.
-   The NGINX container is the only entrypoint via port 443.
