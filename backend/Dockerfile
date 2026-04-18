FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

FROM deps AS test
RUN npm install
COPY . .

FROM node:18-alpine AS production
WORKDIR /app

ARG BUILD_DATE
ARG VERSION=v2
ARG NODE_ENV=production

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.title="Backend API v2"

ENV NODE_ENV=$NODE_ENV

RUN apk add --no-cache wget

RUN addgroup -g 1001 nodejs && adduser -S -u 1001 -G nodejs nodeuser

COPY --from=deps --chown=nodeuser:nodejs /app/node_modules ./node_modules
COPY --chown=nodeuser:nodejs server.js package.json ./

RUN mkdir -p /app/data /app/tmp && chown -R nodeuser:nodejs /app/data /app/tmp

USER nodeuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["npm", "start"]