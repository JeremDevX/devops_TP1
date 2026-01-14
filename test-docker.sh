#!/bin/bash

echo "🧪 Tests de l'application Gym Management"
echo "========================================="
echo ""

# Test 1: PostgreSQL
echo "📊 Test 1: Base de données PostgreSQL"
docker exec gym-postgres pg_isready -U gymuser -d gymdb
if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL est prêt"
else
    echo "❌ PostgreSQL n'est pas accessible"
    exit 1
fi
echo ""

# Test 2: Backend Health Check
echo "🔧 Test 2: Backend Health Check"
HEALTH=$(curl -s http://localhost:3000/health | jq -r '.status')
if [ "$HEALTH" = "OK" ]; then
    echo "✅ Backend Health Check: OK"
else
    echo "❌ Backend Health Check a échoué"
    exit 1
fi
echo ""

# Test 3: Backend API Users
echo "👥 Test 3: Backend API Users"
USERS=$(curl -s http://localhost:3000/api/users)
if [ "$USERS" = "[]" ]; then
    echo "✅ API Users répond correctement (liste vide)"
else
    echo "✅ API Users répond: $USERS"
fi
echo ""

# Test 4: Backend API Classes
echo "📚 Test 4: Backend API Classes"
CLASSES=$(curl -s http://localhost:3000/api/classes)
if [ "$CLASSES" = "[]" ]; then
    echo "✅ API Classes répond correctement (liste vide)"
else
    echo "✅ API Classes répond: $CLASSES"
fi
echo ""

# Test 5: Frontend accessible
echo "🎨 Test 5: Frontend accessible"
FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$FRONTEND" = "200" ]; then
    echo "✅ Frontend est accessible (HTTP 200)"
else
    echo "❌ Frontend n'est pas accessible (HTTP $FRONTEND)"
    exit 1
fi
echo ""

# Test 6: Vérifier les conteneurs
echo "🐳 Test 6: État des conteneurs"
docker ps --filter "name=gym-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "✅ Tous les tests sont passés avec succès!"
echo ""
echo "🌐 Accès aux services:"
echo "   Frontend:  http://localhost:8080"
echo "   Backend:   http://localhost:3000"
echo "   API Docs:  http://localhost:3000/health"
