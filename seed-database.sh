#!/bin/bash

echo "🌱 Seed de la base de données avec des données de test"
echo "======================================================="
echo ""

echo "📥 Exécution du script de seed..."
docker exec gym-backend npm run seed

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Seed terminé avec succès!"
    echo ""
    echo "🔍 Vérification des données..."
    echo ""
    echo "👥 Utilisateurs:"
    curl -s http://localhost:3000/api/users | jq '.[] | {firstname, lastname, email, role}'
    echo ""
    echo "📚 Cours:"
    curl -s http://localhost:3000/api/classes | jq '.[] | {name, description, capacity}'
else
    echo ""
    echo "❌ Le seed a échoué"
    exit 1
fi
