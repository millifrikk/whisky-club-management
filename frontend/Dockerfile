FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all source code
COPY . .

# Expose the port React runs on
EXPOSE 3000

# Start the React development server
CMD ["npm", "start"]