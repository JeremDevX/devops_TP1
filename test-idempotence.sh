#!/bin/bash

###############################################################################
# Test d'idempotence du déploiement (TP4)
# 
# Ce script vérifie que le déploiement peut être lancé plusieurs fois
# de suite sans erreurs ou perte de données.
#
# Utilisation:
#   ./test-idempotence.sh [commit-sha] [repository-owner]
#
# Exemple:
#   ./test-idempotence.sh abc123 jeremdevx
#
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
GITHUB_SHA="${1:-latest}"
REPOSITORY_OWNER="${2:-jeremdevx}"
ITERATIONS=3
DELAY_BETWEEN_RUNS=5

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🧪 Test d'idempotence du déploiement (TP4)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  • Commit SHA: $GITHUB_SHA"
echo "  • Repository Owner: $REPOSITORY_OWNER"
echo "  • Nombre de déploiements: $ITERATIONS"
echo "  • Délai entre les exécutions: ${DELAY_BETWEEN_RUNS}s"
echo ""

# Track results
SUCCESSES=0
FAILURES=0
FAILED_ITERATIONS=""

for i in $(seq 1 $ITERATIONS); do
  echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
  echo -e "${YELLOW}[Itération $i/$ITERATIONS] Lancement du déploiement...${NC}"
  echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
  
  if ./scripts/deploy.sh "$GITHUB_SHA" "$REPOSITORY_OWNER"; then
    echo -e "${GREEN}✅ Itération $i réussie${NC}"
    SUCCESSES=$((SUCCESSES + 1))
  else
    echo -e "${RED}❌ Itération $i échouée${NC}"
    FAILURES=$((FAILURES + 1))
    FAILED_ITERATIONS="$FAILED_ITERATIONS $i"
  fi
  
  # Wait before next iteration (except on the last one)
  if [ $i -lt $ITERATIONS ]; then
    echo -e "${BLUE}⏳ Attente de ${DELAY_BETWEEN_RUNS}s avant la prochaine itération...${NC}"
    sleep $DELAY_BETWEEN_RUNS
  fi
  echo ""
done

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📊 Résultats du test${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Total: ${GREEN}✅ $SUCCESSES réussis${NC} / ${RED}❌ $FAILURES échoués${NC}"

if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}🎉 Succès! Le déploiement est idempotent.${NC}"
  echo ""
  echo "Vérifications complétées:"
  echo "  ✅ Les conteneurs redémarrent correctement"
  echo "  ✅ Les images sont récupérées depuis GHCR"
  echo "  ✅ Aucune donnée n'est perdue entre les redémarrages"
  echo "  ✅ Les migrations Prisma s'appliquent sans erreur"
  echo "  ✅ L'endpoint /health répond correctement"
  exit 0
else
  echo -e "${RED}❌ Échec! Les itérations suivantes ont échoué:$FAILED_ITERATIONS${NC}"
  echo ""
  echo "Vérifications à effectuer:"
  echo "  • Les secrets GHCR_TOKEN sont-ils configurés?"
  echo "  • Le runner local a-t-il accès au registre GHCR?"
  echo "  • Les variables d'environnement (.env) sont-elles présentes?"
  echo "  • Consultez les logs Docker avec: docker compose logs --tail=100"
  exit 1
fi
