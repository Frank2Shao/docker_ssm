# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.15.0
FROM node:${NODE_VERSION}-alpine

# Use production node environment when senshamart is complete
ENV NODE_ENV=development

WORKDIR /usr/src/app

# Copy package.json and package-lock.json before installing dependencies
COPY package.json package-lock.json ./

# Install Python, build tools, and distutils for node-gyp
#RUN apk add --no-cache python3 py3-pip py3-setuptools make g++

# Install dependencies including TypeScript and force SQLite3 to build from source
RUN npm ci

# Install TypeScript globally (optional, if not already in package.json)
#RUN npm install -g typescript

# Install envsubst (part of the gettext package) and other necessary utilities
RUN apk --no-cache add gettext vim jq

# Copy the rest of the application code
COPY . .

# Set ownership and permissions
RUN chown -R node:node /usr/src/app && \
    chmod -R 775 /usr/src/app

# Rebuild SQLite3 binary inside the container (to avoid architecture mismatches)
RUN npm rebuild sqlite3

# Switch to the node user
USER node

# Set the entrypoint
ENTRYPOINT ["/usr/src/app/build/broker/entrypoint.sh"]

