FROM node:20-alpine
WORKDIR /app

# 1. package.json kopieren und Abhängigkeiten installieren
COPY package*.json ./
RUN npm install --production

# 2. Quellcode kopieren
COPY . .

# 3. Port bekannt machen
EXPOSE 9090

# 4. Startkommando
CMD ["node", "server.js"]

