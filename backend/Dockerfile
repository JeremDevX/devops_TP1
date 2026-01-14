# Build stage
FROM node:alpine AS builder

WORKDIR /app

# Copier les fichiers package
COPY package*.json ./

# Installer toutes les dépendances (y compris devDependencies pour Prisma)
RUN npm ci

# Copier le code source et le schéma Prisma
COPY . .

# Générer le client Prisma
RUN npx prisma generate

# Production stage
FROM node:alpine

# Installer OpenSSL pour Prisma
RUN apk add --no-cache openssl

WORKDIR /app

# Copier les fichiers package
COPY package*.json ./

# Installer uniquement les dépendances de production
RUN npm ci --only=production

# Copier le code source depuis le builder
COPY --from=builder /app/src ./src
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/seed ./seed
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000
ENV DATABASE_URL=""

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["npm", "start"]
