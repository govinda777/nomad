FROM node:18-alpine

# Install Docker CLI, Docker Compose, bash, and curl
RUN apk add --no-cache docker-cli docker-cli-compose bash curl

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

EXPOSE 8000

CMD ["npm", "start"]
