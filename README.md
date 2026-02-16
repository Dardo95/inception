*This project has been created as part of the 42 curriculum by
enogueir.*

# Inception

## Description

This project consists of setting up a small infrastructure using Docker
and Docker Compose inside a Virtual Machine.

The stack includes:

-   NGINX with TLSv1.2 / TLSv1.3 (only entrypoint on port 443)
-   WordPress with PHP-FPM (without NGINX)
-   MariaDB (without NGINX)
-   Two persistent Docker named volumes
-   One dedicated Docker network connecting all services

------------------------------------------------------------------------

## Project Architecture

### NGINX

-   Only entrypoint on port 443
-   Uses a self-signed TLS certificate (TLSv1.2 / TLSv1.3)
-   Forwards PHP requests to WordPress via FastCGI

### WordPress

-   Runs PHP-FPM
-   Automatically installs WordPress using WP-CLI
-   Connects to MariaDB via Docker network

### MariaDB

-   Initializes database on first startup
-   Creates required database and users
-   Uses Docker secrets for password management

------------------------------------------------------------------------

## Instructions

### Requirements

-   Linux Virtual Machine
-   Docker
-   Docker Compose plugin
-   Make

### Start the project

``` bash
make
```

### Stop the project

``` bash
make down
```

### Access

Add to `/etc/hosts`:

    127.0.0.1 enogueir.42.fr

Then open:

    https://enogueir.42.fr

------------------------------------------------------------------------

## Data Persistence

Two Docker named volumes are used:

-   WordPress database
-   WordPress website files

Both are stored in:

    /home/enogueir/data/

After a reboot of the virtual machine, running `make` restores the
infrastructure with all data intact.

------------------------------------------------------------------------

## Design Choices

### Virtual Machines vs Docker

Virtual Machines virtualize entire operating systems including the
kernel.\
Docker containers share the host kernel and isolate applications at the
process level, making them lighter and more efficient.

### Secrets vs Environment Variables

Environment variables are convenient but less secure.\
Docker secrets provide safer handling of sensitive credentials such as
passwords.

### Docker Network vs Host Network

Docker networks isolate containers and allow secure internal
communication between services.\
Using host network mode would break isolation and is forbidden in this
project.

### Docker Volumes vs Bind Mounts

Bind mounts directly map host paths into containers.\
Docker named volumes are managed by Docker and provide better
portability and abstraction.

------------------------------------------------------------------------

## AI Usage

AI was used as a productivity assistant for:

-   Reviewing Docker configuration
-   Structuring documentation
-   Clarifying best practices

All generated content was reviewed, tested, and fully understood before
inclusion in the project.

------------------------------------------------------------------------

## Resources

-   Docker official documentation
-   NGINX documentation
-   MariaDB documentation
-   WordPress and WP-CLI documentation
-   42 Inception subject
