NAME        := inception
LOGIN       ?= $(shell whoami)

COMPOSE_YML := srcs/docker-compose.yml
COMPOSE     := docker compose -f $(COMPOSE_YML)

.DEFAULT_GOAL := help

help:
	@echo "Usage:"
	@echo "  make build                Build all services"
	@echo "  make build-<service>       Build one service"
	@echo "  make up                   Up all services"
	@echo "  make up-<service>          Up one service (Compose may start dependencies)"
	@echo "  make upb                  Up all services + build"
	@echo "  make upb-<service>         Up one service + build"
	@echo "  make upb-ftp         	   Up ftp + build without depends"
	@echo "  make down                 Down all services"
	@echo "  make down-<service>        Stop+rm one service"
	@echo "  make start | stop          Start/stop all"
	@echo "  make start-<service>       Start one service"
	@echo "  make stop-<service>        Stop one service"
	@echo "  make restart               Restart all"
	@echo "  make restart-<service>     Restart one service"
	@echo "  make logs                 Follow logs all"
	@echo "  make logs-<service>        Follow logs one service"
	@echo "  make ps | status           Show status"
	@echo "  make config                Validate/print resolved compose config"
	@echo "  make clean                 Down + remove images"
	@echo "  make fclean                Down + remove images + volumes"
	@echo "  make prune                 Prune unused images"
	@echo "Vars:"
	@echo "  LOGIN=$(LOGIN)"
	@echo "  COMPOSE_YML=$(COMPOSE_YML)"

# --- Validate ---
config:
	$(COMPOSE) config

# --- Build ---
build:
	$(COMPOSE) build

build-%:
	$(COMPOSE) build $*

# --- Up ---
up:
	$(COMPOSE) up -d

up-%:
	$(COMPOSE) up -d $*

upb:
	$(COMPOSE) up -d --build

upb-%:
	$(COMPOSE) up -d --build $*

upb-ftp:
	$(COMPOSE) build ftp
	$(COMPOSE) up -d --no-deps ftp

# --- Start / Stop / Restart ---
start:
	$(COMPOSE) start

start-%:
	$(COMPOSE) start $*

stop:
	$(COMPOSE) stop

stop-%:
	$(COMPOSE) stop $*

restart:
	$(COMPOSE) restart

restart-%:
	$(COMPOSE) restart $*

# --- Down ---
down:
	$(COMPOSE) down

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

status: ps

# --- Cleaning ---
clean:
	$(COMPOSE) down --remove-orphans --rmi all

fclean:
	$(COMPOSE) down --remove-orphans --rmi all --volumes

re: fclean upb

prune:
	docker image prune -a

.PHONY: help config build up upb down start stop restart logs ps status clean fclean re prune \
        build-% up-% upb-% upb-ftp down-% start-% stop-% restart-% logs-%
