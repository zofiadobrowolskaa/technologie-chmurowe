FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json vite.config.js ./
RUN npm install

FROM node:18-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM nginx:alpine AS production

ARG BUILD_DATE
ARG VERSION=v2
ARG NODE_ENV=production

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.title="Frontend App"

ENV NODE_ENV=$NODE_ENV

# Give nginx user access to necessary directories including /run
RUN mkdir -p /tmp/nginx_cache /var/cache/nginx /var/run /var/log/nginx /run && \
    chown -R nginx:nginx /usr/share/nginx/html /tmp/nginx_cache /var/cache/nginx /var/run /var/log/nginx /run && \
    chmod -R 755 /usr/share/nginx/html /tmp/nginx_cache /var/cache/nginx /var/run /var/log/nginx /run && \
    rm -rf /usr/share/nginx/html/*

COPY --from=build --chown=nginx:nginx /app/dist /usr/share/nginx/html
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

USER nginx
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]