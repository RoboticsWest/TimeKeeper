ARG TK_IMAGE=ghcr.io/roboticswest/timekeeper:latest
FROM ${TK_IMAGE} AS source
FROM nginx:stable-alpine
COPY --from=source /app/client/build/web /usr/share/nginx/html
COPY deploy/timekeeper/web/nginx.conf /etc/nginx/conf.d/default.conf
