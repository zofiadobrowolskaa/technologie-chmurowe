# bazowy obraz dla workera
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

# uruchomienie procesu workera
CMD ["node", "index.js"]