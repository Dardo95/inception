NAME        := inception
LOGIN       ?= $(shell whoami)
DATA_DIR    := /home/$(LOGIN)/data
COMPOSE_YML := srcs/docker-compose.yml
COMPOSE     := docker compose -f $(COMPOSE_YML)

# Añade aquí subcarpetas que uses en /home/login/data (si mañana añades otro bind, lo metes aquí)
DATA_SUBDIRS := mariadb wordpress portainer

.DEFAULT_GOAL := help

help:
	@echo "Usage:"
	@echo "  make up                  Build+up all services"
	@echo "  make up-<service>         Build+up one service (e.g. up-portainer)"
	@echo "  make down                Down all services (keeps volumes by default)"
	@echo "  make down-<service>       Stop+rm one service (closest to down)"
	@echo "  make start | stop         Start/stop all"
	@echo "  make start-<service>      Start one service"
	@echo "  make stop-<service>       Stop one service"
	@echo "  make restart              Restart all"
	@echo "  make restart-<service>    Restart one service"
	@echo "  make logs                 Follow logs all"
	@echo "  make logs-<service>       Follow logs one service"
	@echo "  make ps                   Show status"
	@echo "  make build                Build all"
	@echo "  make build-<service>      Build one"
	@echo "  make clean                Down + remove images"
	@echo "  make fclean               Down + remove images + volumes"
	@echo "  make reset                fclean + delete $(DATA_DIR)"
	@echo "Vars:"
	@echo "  LOGIN=$(LOGIN)"
	@echo "  DATA_DIR=$(DATA_DIR)"

prepare:
	@mkdir -p $(DATA_DIR)
	@for d in $(DATA_SUBDIRS); do mkdir -p "$(DATA_DIR)/$$d"; done

# --- Up / Build ---
up: prepare
	$(COMPOSE) up -d --build

up-%: prepare
	$(COMPOSE) up -d --build $*

build:
	$(COMPOSE) build

build-%:
	$(COMPOSE) build $*

# --- Start / Stop / Restart ---
start: prepare
	$(COMPOSE) start

start-%: prepare
	$(COMPOSE) start $*

stop:
	$(COMPOSE) stop

stop-%:
	$(COMPOSE) stop $*

restart: prepare
	$(COMPOSE) restart

restart-%: prepare
	$(COMPOSE) restart $*

# --- Down ---
down:
	$(COMPOSE) down

# Compose no tiene "down" por servicio: hacemos stop + rm
down-%:
	$(COMPOSE) stop $* || true
	$(COMPOSE) rm -f $* || true

# --- Info ---
logs:
	$(COMPOSE) logs -f

logs-%:
	$(COMPOSE) logs -f $*

ps:
	$(COMPOSE) ps

# --- Cleaning ---
clean:
	$(COMPOSE) down --remove-orphans --rmi all

fclean:
	$(COMPOSE) down --remove-orphans --rmi all --volumes

reset: fclean
	@if [ "$(DATA_DIR)" = "/" ] || [ "$(DATA_DIR)" = "/home" ] || [ "$(DATA_DIR)" = "/home/$(LOGIN)" ]; then \
		echo "Refusing to delete unsafe DATA_DIR=$(DATA_DIR)"; exit 1; \
	fi
	sudo rm -rf "$(DATA_DIR)"

re: fclean up

prune:
	docker image prune -a

.PHONY: help prepare up down start stop restart logs ps build clean fclean reset re prune \
        up-% down-% start-% stop-% restart-% logs-% build-%
