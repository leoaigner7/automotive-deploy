FROM node:20-alpine
RUN apk add --no-cache bash curl
RUN apk update && apk add --no-cache docker-cli docker-compose
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8088

CMD ["node", "index.js"]
