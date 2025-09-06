#!/bin/bash

# Script pour Jenkins - Exécution depuis 51.75.202.241
echo "🚀 DEPLOY REDIS.PHP - TIER1 (12 groupes) - $(date)"
echo "🎯 Lancement: php /mnt/www/update/redis.php sur tous les serveurs"
echo "📊 Script de gestion Redis WordPress"
echo ""

TOTAL_GROUPS=12
SUCCESS_COUNT=0
ERROR_COUNT=0

# Timestamp unique pour tous les déploiements
DEPLOY_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Fonction deploy ultra-robuste pour un serveur
deploy_server_ultra() {
    local group_num=$1
    local group_formatted=$(printf "%02d" $group_num)
    
    echo "🚀 Deploy group${group_formatted}..."
    
    # ProxyJump explicite + SSH Agent
    ssh -o ProxyJump=bastion@infra.linkuma.ovh:2200 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=20 \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=2 \
        -p 2222 root@apache.group${group_formatted}.svc.cluster.local \
        "bash --noprofile --norc -c '
        echo \"🚀 Deploy sur \$(hostname) (group${group_formatted})\"
        
        if [ -f /mnt/www/update/redis.php ]; then
            # Créer répertoire logs
            mkdir -p /mnt/www/update/log
            
            LOG_FILE=\"/mnt/www/update/log/redis-jenkins-tier1-${DEPLOY_TIMESTAMP}-group${group_formatted}.log\"
            echo \"📋 Log: \$LOG_FILE\"
            
            # Vérifier que PHP est disponible
            if ! command -v php &> /dev/null; then
                echo \"❌ PHP non installé\"
                exit 1
            fi
            
            # Lancer script redis.php  
            cd /mnt/www/update
            
            # Executer directement pas en background car rapide
            php redis.php > \"\$LOG_FILE\" 2>&1
            RESULT=\$?
            
            if [ \$RESULT -eq 0 ]; then
                echo \"✅ Script Redis exécuté avec succès\"
                echo \"📊 Résultat:\"
                tail -20 \"\$LOG_FILE\" 2>/dev/null || echo \"Pas de résultat\"
            else
                echo \"❌ Erreur lors de l'exécution Redis\"
                echo \"❌ Contenu du log:\"
                tail -20 \"\$LOG_FILE\" 2>/dev/null || echo \"Pas de log généré\"
                exit 1
            fi
        else
            echo \"❌ Script /mnt/www/update/redis.php introuvable\"
            ls -la /mnt/www/update/redis* 2>/dev/null || echo \"Aucun fichier redis trouvé\"
            exit 1
        fi
        
        echo \"✅ Script Redis terminé sur group${group_formatted}\"
        '" 2>&1 | sed "s/^/[group${group_formatted}] /" || echo "[group${group_formatted}] ❌ Erreur connexion"
    
    # Compter succès/échecs
    if echo "$?" | grep -q "0"; then
        ((SUCCESS_COUNT++))
    else
        ((ERROR_COUNT++))
    fi
}

echo "🚀 Lancement script Redis sur TIER1..."
echo "📡 12 serveurs à traiter"
echo "🕒 Timestamp deploy: $DEPLOY_TIMESTAMP"
echo ""

# Pour TIER1 : tous en une fois car seulement 12 serveurs
echo "📦 Lancement simultané des 12 serveurs TIER1"

for group_num in $(seq 1 $TOTAL_GROUPS); do
    deploy_server_ultra $group_num &
done

echo "⏳ Attente fin de tous les scripts..."
wait

echo ""
echo "📊 RÉSULTATS SCRIPT REDIS TIER1:"
echo "✅ Succès: $SUCCESS_COUNT/$TOTAL_GROUPS serveurs"
echo "❌ Échecs: $ERROR_COUNT/$TOTAL_GROUPS serveurs" 
echo "🕒 Fin exécution: $(date)"

if [ $SUCCESS_COUNT -gt $((TOTAL_GROUPS * 70 / 100)) ]; then
    echo ""
    echo "🎉 EXECUTION MAJORITAIRE - Plus de 70% des serveurs traités"
    echo "💾 Script Redis exécuté avec succès"
elif [ $SUCCESS_COUNT -gt $((TOTAL_GROUPS * 50 / 100)) ]; then
    echo ""
    echo "✅ EXECUTION PARTIELLE - Plus de 50% des serveurs traités"
else
    echo ""
    echo "⚠️  EXECUTION INCOMPLETE - Beaucoup d'échecs, vérifier connectivité"
fi

echo ""
echo "📋 Logs: /mnt/www/update/log/redis-jenkins-tier1-${DEPLOY_TIMESTAMP}-groupXX.log"