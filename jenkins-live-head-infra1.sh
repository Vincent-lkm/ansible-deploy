#!/bin/bash

# Script pour Jenkins - Live Head INFRA1
echo "📦 Mise à jour du repository..."
cd /opt/semaphore/repositories/linkuma-deploy
git pull

echo ""
echo "🚀 Lancement du scan Live Head INFRA1..."

# Vérifier que le script existe
if [ -f "./live-head-infra1-sequential.sh" ]; then
    chmod +x ./live-head-infra1-sequential.sh
    ./live-head-infra1-sequential.sh
else
    echo "❌ Erreur: Script live-head-infra1-sequential.sh non trouvé"
    echo "📂 Contenu du répertoire:"
    ls -la | grep live-head
    exit 1
fi