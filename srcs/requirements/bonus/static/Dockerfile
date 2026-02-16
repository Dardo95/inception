FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default /etc/nginx/sites-available/default
COPY tools/site/ /var/www/static/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
