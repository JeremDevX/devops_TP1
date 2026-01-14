#!/bin/bash

set -e

# Load environment variables from .env if it exists
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | xargs)
  echo -e "${BLUE}✅ Environment variables loaded from .env${NC}"
else
  # Fallback: use default values for local deployment
  echo -e "${BLUE}⚠️  No .env file found, using default values${NC}"
  export POSTGRES_DB=${POSTGRES_DB:-gymdb}
  export POSTGRES_USER=${POSTGRES_USER:-gymuser}
  export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-gympass}
  export POSTGRES_PORT=${POSTGRES_PORT:-5432}
  export DATABASE_URL=${DATABASE_URL:-postgresql://gymuser:gympass@postgres:5432/gymdb}
  export NODE_ENV=${NODE_ENV:-production}
  export BACKEND_PORT=${BACKEND_PORT:-3000}
  export FRONTEND_PORT=${FRONTEND_PORT:-8080}
  export FRONTEND_URL=${FRONTEND_URL:-http://localhost:8080}
  export VITE_API_BASE_URL=${VITE_API_BASE_URL:-http://localhost:3000/api}
fi

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting deployment process...${NC}"

# Get variables
GITHUB_SHA="${1:-latest}"
REPOSITORY_OWNER="${2:-jeremdevx}"
OWNER=$(echo "$REPOSITORY_OWNER" | tr '[:upper:]' '[:lower:]')

echo -e "${BLUE}📦 Using commit SHA: ${GITHUB_SHA}${NC}"
echo -e "${BLUE}📦 Using repository owner: ${OWNER}${NC}"

# Step 1: Stop running containers (without destroying volumes)
echo -e "${BLUE}⏹️  Stopping running containers...${NC}"
docker compose down || echo "No containers running"

# Step 2: Pull latest images from registry
echo -e "${BLUE}📥 Pulling images from GHCR...${NC}"
docker pull ghcr.io/${OWNER}/cloudnative-backend:${GITHUB_SHA} || exit 1
docker pull ghcr.io/${OWNER}/cloudnative-frontend:${GITHUB_SHA} || exit 1
echo -e "${GREEN}✅ Images pulled successfully${NC}"

# Step 3: Tag images as latest (so docker-compose uses them)
echo -e "${BLUE}🏷️  Tagging images as latest...${NC}"
docker tag ghcr.io/${OWNER}/cloudnative-backend:${GITHUB_SHA} ghcr.io/${OWNER}/cloudnative-backend:latest || exit 1
docker tag ghcr.io/${OWNER}/cloudnative-frontend:${GITHUB_SHA} ghcr.io/${OWNER}/cloudnative-frontend:latest || exit 1
echo -e "${GREEN}✅ Images tagged${NC}"

# Step 4: Start the application
echo -e "${BLUE}🚀 Starting application with docker compose...${NC}"
docker compose up -d || exit 1
echo -e "${GREEN}✅ Application started${NC}"

# Step 5: Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 10

# Step 6: Verify deployment
echo -e "${BLUE}🔍 Verifying deployment...${NC}"
HEALTH=$(curl -s http://localhost:3000/health | jq -r '.status' 2>/dev/null || echo "FAILED")

if [ "$HEALTH" = "OK" ]; then
  echo -e "${GREEN}✅ Backend health check passed - Deployment successful!${NC}"
  exit 0
else
  echo -e "${RED}❌ Backend health check failed${NC}"
  docker compose logs
  exit 1
fi
