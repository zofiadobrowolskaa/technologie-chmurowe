# pierwszy etap budowania aplikacji
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# drugi etap przygotowania srodowiska produkcyjnego
FROM node:18-alpine AS runner

WORKDIR /app

# kopiowanie plikow z poprzedniego etapu
COPY --from=builder /app/package*.json ./
# Zmiana z npm ci na npm install --omit=dev
RUN npm install --omit=dev

COPY --from=builder /app ./

# uruchomienie serwera
CMD ["node", "server.js"]