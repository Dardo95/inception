# USER DOCUMENTATION

## Overview

This document explains how to use and manage the Inception
infrastructure stack.

The stack provides:

-   A secure WordPress website accessible via HTTPS
-   A MariaDB database backend
-   An NGINX reverse proxy with TLS encryption
-   Persistent data storage using Docker named volumes

------------------------------------------------------------------------

## Starting the Project

From the root directory of the repository:

``` bash
make
```

This command will: - Build all Docker images - Create the Docker
network - Create the persistent volumes - Start all services

------------------------------------------------------------------------

## Stopping the Project

To stop all services:

``` bash
make down
```

To stop containers without removing them:

``` bash
make stop
```

------------------------------------------------------------------------

## Accessing the Website

Add the following line to your `/etc/hosts` file inside the Virtual
Machine:

    127.0.0.1 enogueir.42.fr

Then open your browser and go to:

    https://enogueir.42.fr

A self-signed certificate warning may appear. This is expected.

------------------------------------------------------------------------

## Accessing the WordPress Admin Panel

Go to:

    https://enogueir.42.fr/wp-admin

Log in using the administrator credentials defined in the secrets
folder.

------------------------------------------------------------------------

## Managing Credentials

All sensitive credentials are stored inside the `secrets/` directory:

-   db_root_password
-   db_password
-   wp_admin_password
-   wp_user_password

These files are not tracked by Git and must be created manually.

------------------------------------------------------------------------

## Checking Service Status

To check running containers:

``` bash
docker compose ps
```

To view logs:

``` bash
docker compose logs
```

To inspect volumes:

``` bash
docker volume ls
docker volume inspect <volume_name>
```

------------------------------------------------------------------------

## Data Persistence

All WordPress files and database data are stored in:

    /home/enogueir/data/

After a reboot of the Virtual Machine, simply run:

``` bash
make
```

All previous data will remain available.
