NAME        := inception
LOGIN       ?= $(shell whoami)

COMPOSE_YML := srcs/docker-compose.yml
ENV_FILE    := srcs/.env
COMPOSE     := docker compose -p inception -f $(COMPOSE_YML) --env-file $(ENV_FILE)

# Real IP of this machine (VM), used by vsftpd for FTP passive mode.
# Primary method needs iproute2 (`ip`, standard on Debian); falls back
# to `hostname -I` if that's not available.
HOST_IP     := $(shell ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($$i=="src") print $$(i+1)}')
ifeq ($(strip $(HOST_IP)),)
HOST_IP     := $(shell hostname -I 2>/dev/null | awk '{print $$1}')
endif

.DEFAULT_GOAL := upb

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

# --- Env setup ---
# Ensures .env exists and always has an up-to-date HOST_IP, so FTP
# passive mode works regardless of which machine this runs on.
env:
	@if [ ! -f $(ENV_FILE) ]; then \
		cp srcs/.env.example $(ENV_FILE); \
		echo "[env] Created $(ENV_FILE) from .env.example"; \
	fi
	@printf '%s\n' "$$(cat $(ENV_FILE))" > $(ENV_FILE).tmp && mv $(ENV_FILE).tmp $(ENV_FILE)
	@if [ -z "$(HOST_IP)" ]; then \
		echo "[env] ERROR: could not detect HOST_IP automatically." >&2; \
		exit 1; \
	fi
	@if grep -q '^HOST_IP=' $(ENV_FILE); then \
		sed -i "s/^HOST_IP=.*/HOST_IP=$(HOST_IP)/" $(ENV_FILE); \
	else \
		echo "HOST_IP=$(HOST_IP)" >> $(ENV_FILE); \
	fi
	@echo "[env] HOST_IP=$(HOST_IP)"

# --- Validate ---
config: env
	$(COMPOSE) config

# --- Build ---
build:
	$(COMPOSE) build

build-%:
	$(COMPOSE) build $*

# --- Up ---
up: env
	$(COMPOSE) up -d

up-%: env
	$(COMPOSE) up -d $*

upb: env
	$(COMPOSE) up -d --build

upb-%: env
	$(COMPOSE) up -d --build $*

upb-ftp: env
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

.PHONY: help env config build up upb down start stop restart logs ps status clean fclean re prune \
        build-% up-% upb-% upb-ftp down-% start-% stop-% restart-% logs-%