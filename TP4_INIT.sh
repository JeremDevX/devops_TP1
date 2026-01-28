#!/bin/bash

###############################################################################
# Script d'initialisation TP4
# 
# Ce script prépare l'environnement pour le déploiement automatique TP4.
# Il rend les scripts exécutables et valide la configuration.
#
# Utilisation:
#   ./TP4_INIT.sh
#
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 Initialisation TP4 - Déploiement automatique${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Step 1: Make scripts executable
echo -e "${BLUE}1️⃣  Rendre les scripts exécutables...${NC}"
chmod +x scripts/deploy.sh || echo -e "${RED}❌ Erreur: scripts/deploy.sh${NC}"
chmod +x test-idempotence.sh || echo -e "${RED}❌ Erreur: test-idempotence.sh${NC}"
chmod +x TP4_CHECKLIST.sh || echo -e "${RED}❌ Erreur: TP4_CHECKLIST.sh${NC}"
echo -e "${GREEN}✅ Scripts rendus exécutables${NC}\n"

# Step 2: Check if .env exists
echo -e "${BLUE}2️⃣  Vérifier la configuration (.env)...${NC}"
if [ -f ".env" ]; then
  echo -e "${GREEN}✅ Fichier .env présent${NC}"
else
  if [ -f ".env.example" ]; then
    echo -e "${YELLOW}⚠️  Fichier .env manquant${NC}"
    echo -e "${BLUE}   Créer .env depuis .env.example? (o/n)${NC}"
    read -r response
    if [ "$response" = "o" ] || [ "$response" = "O" ] || [ "$response" = "yes" ] || [ "$response" = "y" ]; then
      cp .env.example .env
      echo -e "${GREEN}✅ .env créé depuis .env.example${NC}"
      echo -e "   ⚠️  Vérifiez et modifiez les valeurs si nécessaire"
    fi
  else
    echo -e "${RED}❌ Ni .env ni .env.example ne sont présents${NC}"
    exit 1
  fi
fi
echo ""

# Step 3: Verify Docker
echo -e "${BLUE}3️⃣  Vérifier Docker...${NC}"
if command -v docker &> /dev/null; then
  DOCKER_VERSION=$(docker --version)
  echo -e "${GREEN}✅ $DOCKER_VERSION${NC}"
else
  echo -e "${RED}❌ Docker n'est pas installé${NC}"
  exit 1
fi
echo ""

# Step 4: Verify Docker Compose
echo -e "${BLUE}4️⃣  Vérifier Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
  DC_VERSION=$(docker-compose --version)
  echo -e "${GREEN}✅ $DC_VERSION${NC}"
elif command -v docker &> /dev/null && docker compose version &>/dev/null; then
  echo -e "${GREEN}✅ Docker Compose (intégré) disponible${NC}"
else
  echo -e "${RED}❌ Docker Compose n'est pas disponible${NC}"
  exit 1
fi
echo ""

# Step 5: Verify GitHub runner is configured
echo -e "${BLUE}5️⃣  Configuration GitHub...${NC}"
if grep -q "self-hosted" ".github/workflows/ci.yml"; then
  echo -e "${GREEN}✅ Runner self-hosted configuré dans le workflow${NC}"
else
  echo -e "${YELLOW}⚠️  Vérifiez que le self-hosted runner est bien configuré${NC}"
fi
echo -e "${YELLOW}📝 N'oubliez pas de configurer les secrets GitHub:${NC}"
echo -e "   • GHCR_TOKEN (PAT avec permission write:packages)"
echo -e "   • SONAR_TOKEN (optionnel, pour SonarCloud)"
echo ""

# Step 6: Run checklist
echo -e "${BLUE}6️⃣  Exécuter la validation complète...${NC}\n"
if bash TP4_CHECKLIST.sh; then
  echo -e "\n${GREEN}🎉 Initialisation TP4 réussie!${NC}\n"
  echo -e "${BLUE}Prochaines étapes:${NC}"
  echo -e "  1. Configurer les secrets GitHub (GHCR_TOKEN, SONAR_TOKEN)"
  echo -e "  2. Vérifier que le self-hosted runner est actif"
  echo -e "  3. Faire un push sur main ou develop pour déclencher le déploiement:"
  echo -e "     ${YELLOW}git push origin main${NC}"
  echo -e "  4. Vérifier les logs dans GitHub Actions"
  echo -e "  5. Tester l'idempotence en local:"
  echo -e "     ${YELLOW}./test-idempotence.sh${NC}"
  echo ""
  echo -e "${BLUE}Documentation:${NC}"
  echo -e "  📚 ${YELLOW}TP4_DEPLOYMENT.md${NC}    - Documentation complète"
  echo -e "  📋 ${YELLOW}TP4_SUMMARY.md${NC}       - Résumé des modifications"
  exit 0
else
  echo -e "\n${RED}❌ Initialisation TP4 échouée${NC}"
  echo -e "${BLUE}Veuillez corriger les erreurs signalées ci-dessus.${NC}"
  exit 1
fi
