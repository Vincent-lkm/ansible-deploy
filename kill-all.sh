#!/bin/bash

echo "💀💀💀 KILL ULTRA GLOBAL - TOUTES INFRASTRUCTURES - $(date) 💀💀💀"
echo "=================================================="
echo "🎯 Cibles: INFRA1 (74) + INFRA2 (72) + INFRA3 (68) + INFRA4 (66) + TIER1 (12)"
echo "📊 Total: 292 serveurs"
echo "=================================================="
echo ""

# Mode d'exécution (parallel ou sequential)
MODE="${1:-parallel}"

# Répertoire de travail
cd /opt/semaphore/repositories/linkuma-deploy

# Créer un dossier logs s'il n'existe pas
mkdir -p logs

# Fonction pour exécuter un kill et capturer le résultat
run_kill() {
    local infra=$1
    local script=$2
    echo "🚀 Lancement Kill $infra..."
    if [ -f "$script" ]; then
        $script > logs/kill-$infra.log 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ $infra terminé avec succès"
        else
            echo "⚠️ $infra terminé avec des erreurs"
        fi
    else
        echo "❌ Script $script non trouvé pour $infra"
    fi
}

# Début du traitement
START_TIME=$(date +%s)

if [ "$MODE" = "parallel" ]; then
    echo "🔥 MODE PARALLÈLE - Lancement simultané de tous les kills"
    echo "=================================================="
    
    # Lancer tous les kills en arrière-plan
    run_kill "INFRA1" "./kill-infra1.sh" &
    PID1=$!
    
    run_kill "INFRA2" "./kill-infra2.sh" &
    PID2=$!
    
    run_kill "INFRA3" "./kill-infra3.sh" &
    PID3=$!
    
    run_kill "INFRA4" "./kill-infra4.sh" &
    PID4=$!
    
    run_kill "TIER1" "./kill-tier1.sh" &
    PID5=$!
    
    echo ""
    echo "⏳ Attente de la fin de tous les processus..."
    echo ""
    
    # Attendre que tous les processus se terminent
    wait $PID1
    wait $PID2
    wait $PID3
    wait $PID4
    wait $PID5
    
else
    echo "📝 MODE SÉQUENTIEL - Lancement un par un"
    echo "=================================================="
    
    # Exécuter séquentiellement
    run_kill "INFRA1" "./kill-infra1.sh"
    echo ""
    
    run_kill "INFRA2" "./kill-infra2.sh"
    echo ""
    
    run_kill "INFRA3" "./kill-infra3.sh"
    echo ""
    
    run_kill "INFRA4" "./kill-infra4.sh"
    echo ""
    
    run_kill "TIER1" "./kill-tier1.sh"
fi

# Calcul du temps total
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "=================================================="
echo "📊 RÉSUMÉ DES OPÉRATIONS"
echo "=================================================="

# Afficher un résumé des logs
for infra in INFRA1 INFRA2 INFRA3 INFRA4 TIER1; do
    if [ -f "logs/kill-$infra.log" ]; then
        COMPLETED=$(grep -c "✅ Terminé" logs/kill-$infra.log 2>/dev/null || echo "0")
        ERRORS=$(grep -c "❌ Erreur connexion" logs/kill-$infra.log 2>/dev/null || echo "0")
        echo "📌 $infra: $COMPLETED succès, $ERRORS erreurs"
    fi
done

echo ""
echo "=================================================="
echo "✅✅✅ KILL GLOBAL TERMINÉ - $(date) ✅✅✅"
echo "⏱️ Durée totale: ${MINUTES}m ${SECONDS}s"
echo "💀 292 serveurs traités sur 5 infrastructures"
echo "=================================================="
