FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev \
    && npm cache clean --force

COPY . .

EXPOSE 3000

CMD ["npm", "start", "server.js"]
