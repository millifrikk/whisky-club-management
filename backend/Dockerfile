FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all source code
COPY . .

# Expose the port Express runs on
EXPOSE 3001

# Start the Express development server with nodemon
CMD ["npm", "run", "dev"]