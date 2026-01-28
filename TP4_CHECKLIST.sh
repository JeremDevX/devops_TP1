#!/bin/bash

###############################################################################
# Checklist de vérification TP4 - Déploiement automatique
# 
# Ce script vérifie que tous les prérequis et configurations pour TP4
# sont correctement en place.
#
# Utilisation:
#   ./TP4_CHECKLIST.sh
#
###############################################################################

set +e  # Ne pas s'arrêter si une commande échoue

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

print_header() {
  echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
}

check_ok() {
  echo -e "${GREEN}✅ $1${NC}"
  CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

check_fail() {
  echo -e "${RED}❌ $1${NC}"
  CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

check_warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
  WARNINGS=$((WARNINGS + 1))
}

# ============================================================================
# VÉRIFICATIONS
# ============================================================================

print_header "1️⃣  Vérification des fichiers essentiels"

if [ -f ".github/workflows/ci.yml" ]; then
  check_ok "Fichier workflow CI trouvé: .github/workflows/ci.yml"
  
  if grep -q "deploy:" ".github/workflows/ci.yml"; then
    check_ok "Job 'deploy' présent dans le workflow"
    
    if grep -q "refs/heads/main.*refs/heads/develop" ".github/workflows/ci.yml"; then
      check_ok "Conditions de branche configurées (main/develop)"
    else
      check_warn "Conditions de branche: vérifiez si main/develop sont bien configurées"
    fi
  else
    check_fail "Job 'deploy' manquant du workflow CI"
  fi
else
  check_fail "Fichier workflow CI non trouvé: .github/workflows/ci.yml"
fi

if [ -f "scripts/deploy.sh" ]; then
  check_ok "Script de déploiement trouvé: scripts/deploy.sh"
  
  if [ -x "scripts/deploy.sh" ]; then
    check_ok "Script deploy.sh est exécutable"
  else
    check_warn "Script deploy.sh n'est pas exécutable (chmod +x recommandé)"
  fi
  
  if grep -q "docker compose down" "scripts/deploy.sh"; then
    check_ok "Script contient 'docker compose down'"
  else
    check_fail "Script ne contient pas 'docker compose down'"
  fi
  
  if grep -q "docker pull" "scripts/deploy.sh"; then
    check_ok "Script contient 'docker pull' pour récupérer les images"
  else
    check_fail "Script ne contient pas 'docker pull'"
  fi
  
  if grep -q "docker compose up" "scripts/deploy.sh"; then
    check_ok "Script contient 'docker compose up' pour démarrer"
  else
    check_fail "Script ne contient pas 'docker compose up'"
  fi
  
  if grep -q "health" "scripts/deploy.sh"; then
    check_ok "Script contient un health check"
  else
    check_warn "Script ne contient pas de health check (recommandé)"
  fi
else
  check_fail "Script de déploiement non trouvé: scripts/deploy.sh"
fi

if [ -f "test-idempotence.sh" ]; then
  check_ok "Script de test d'idempotence trouvé: test-idempotence.sh"
else
  check_warn "Script de test d'idempotence non trouvé (optionnel): test-idempotence.sh"
fi

if [ -f "docker-compose.yml" ]; then
  check_ok "Fichier docker-compose.yml trouvé"
  
  if grep -q "BACKEND_IMAGE" "docker-compose.yml"; then
    check_ok "docker-compose.yml utilise BACKEND_IMAGE (images GHCR supportées)"
  else
    check_warn "docker-compose.yml ne supporte pas les variables d'images GHCR"
  fi
  
  if grep -q "volumes:" "docker-compose.yml"; then
    check_ok "Docker-compose a un volume pour PostgreSQL (données persistantes)"
  else
    check_fail "Volume PostgreSQL manquant (risque de perte de données)"
  fi
else
  check_fail "Fichier docker-compose.yml non trouvé"
fi

print_header "2️⃣  Vérification du README"

if [ -f "README.md" ]; then
  check_ok "Fichier README.md trouvé"
  
  if grep -q "Déploiement local automatisé" "README.md"; then
    check_ok "Section 'Déploiement local automatisé' présente dans README"
  else
    check_fail "Section 'Déploiement local automatisé' manquante dans README"
  fi
  
  if grep -q "main.*develop" "README.md"; then
    check_ok "Branches actives (main/develop) documentées dans README"
  else
    check_warn "Branches actives non clairement documentées dans README"
  fi
  
  if grep -q "idempotent" "README.md"; then
    check_ok "Idempotence documentée dans README"
  else
    check_warn "Idempotence non documentée dans README"
  fi
else
  check_fail "Fichier README.md non trouvé"
fi

print_header "3️⃣  Vérification de la configuration Docker"

if command -v docker &> /dev/null; then
  check_ok "Docker est installé"
  
  DOCKER_VERSION=$(docker --version)
  check_ok "Version: $DOCKER_VERSION"
else
  check_fail "Docker n'est pas installé"
fi

if command -v docker-compose &> /dev/null; then
  check_ok "Docker Compose est installé"
  
  DC_VERSION=$(docker-compose --version)
  check_ok "Version: $DC_VERSION"
elif command -v docker &> /dev/null && docker compose version &>/dev/null; then
  check_ok "Docker Compose (intégré) est disponible"
else
  check_fail "Docker Compose n'est pas installé ou pas accessible"
fi

print_header "4️⃣  Vérification de l'environnement"

if [ -f ".env" ]; then
  check_ok "Fichier .env trouvé"
  
  if grep -q "POSTGRES_USER" ".env"; then
    check_ok "Variable POSTGRES_USER configurée dans .env"
  else
    check_warn "Variable POSTGRES_USER manquante dans .env"
  fi
  
  if grep -q "DATABASE_URL" ".env"; then
    check_ok "Variable DATABASE_URL configurée dans .env"
  else
    check_warn "Variable DATABASE_URL manquante dans .env"
  fi
else
  check_warn "Fichier .env non trouvé (requis pour le déploiement)"
  
  if [ -f ".env.example" ]; then
    check_ok "Fichier .env.example trouvé"
    echo -e "    Pour créer .env: ${BLUE}cp .env.example .env${NC}"
  fi
fi

print_header "5️⃣  Vérification GitHub Actions (Runner)"

if [ -d ".github/runners" ] || [ -d "$HOME/.github-runner" ] || grep -q "self-hosted" ".github/workflows/ci.yml"; then
  check_ok "Configuration self-hosted runner détectée"
else
  check_warn "Vérifiez que le self-hosted runner est bien configuré dans GitHub"
fi

print_header "6️⃣  Vérification de la documentation"

if [ -f "TP4_DEPLOYMENT.md" ]; then
  check_ok "Documentation TP4 trouvée: TP4_DEPLOYMENT.md"
else
  check_warn "Documentation TP4 non trouvée: TP4_DEPLOYMENT.md"
fi

print_header "7️⃣  Vérification git"

if git rev-parse --git-dir > /dev/null 2>&1; then
  check_ok "Dépôt Git trouvé"
  
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  check_ok "Branche courante: $CURRENT_BRANCH"
  
  if [ -f ".gitignore" ]; then
    if grep -q "\.env" ".gitignore"; then
      check_ok ".env est dans .gitignore (sécurité)"
    else
      check_warn ".env n'est pas dans .gitignore (risque de sécurité!)"
    fi
  fi
else
  check_fail "Dépôt Git non trouvé"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================

print_header "📊 Résumé"

TOTAL=$((CHECKS_PASSED + CHECKS_FAILED + WARNINGS))

echo -e "Total: ${GREEN}✅ $CHECKS_PASSED réussi(s)${NC} | ${RED}❌ $CHECKS_FAILED échoué(s)${NC} | ${YELLOW}⚠️  $WARNINGS avertissement(s)${NC}\n"

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 Tous les prérequis pour TP4 sont en place!${NC}\n"
  
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Cependant, $WARNINGS avertissement(s) requièrent attention.${NC}\n"
  fi
  
  echo -e "Vous pouvez maintenant :"
  echo -e "  1. Faire un push sur ${BLUE}main${NC} ou ${BLUE}develop${NC} pour déclencher le déploiement"
  echo -e "  2. Vérifier les logs du déploiement dans GitHub Actions"
  echo -e "  3. Tester le déploiement manuel avec: ${BLUE}./scripts/deploy.sh <SHA> <owner>${NC}"
  echo -e "  4. Vérifier l'idempotence avec: ${BLUE}./test-idempotence.sh${NC}"
  exit 0
else
  echo -e "${RED}❌ $CHECKS_FAILED prérequis manquent ou sont mal configurés.${NC}\n"
  echo -e "Veuillez corriger les éléments marqués en rouge avant de continuer.\n"
  exit 1
fi
