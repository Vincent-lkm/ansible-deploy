#!/bin/bash

echo "🚀 DEPLOY LIVE_HEAD.SH - INFRA1 (75 groupes) - $(date)"
echo "🎯 Lancement: /mnt/www/update/live_head.sh sur tous les serveurs"
echo "📊 Monitoring HTTP de tous les sites WordPress"
echo ""

TOTAL_GROUPS=75
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
        
        if [ -f /mnt/www/update/live_head.sh ]; then
            # Créer répertoire logs
            mkdir -p /mnt/www/update/log
            
            LOG_FILE=\"/mnt/www/update/log/live_head-jenkins-infra1-${DEPLOY_TIMESTAMP}-group${group_formatted}.log\"
            echo \"📋 Log: \$LOG_FILE\"
            
            # Lancer script live_head.sh  
            chmod +x /mnt/www/update/live_head.sh
            cd /mnt/www/update
            
            # Exécuter directement (pas en background car c'est rapide)
            ./live_head.sh > \"\$LOG_FILE\" 2>&1
            RESULT=\$?
            
            if [ \$RESULT -eq 0 ]; then
                echo \"✅ Scan terminé avec succès\"
                echo \"📊 Résultat:\"
                tail -1 \"\$LOG_FILE\" 2>/dev/null || echo \"Pas de résultat\"
            else
                echo \"❌ Erreur lors du scan\"
                echo \"❌ Contenu du log:\"
                tail -10 \"\$LOG_FILE\" 2>/dev/null || echo \"Pas de log généré\"
                exit 1
            fi
        else
            echo \"❌ Script /mnt/www/update/live_head.sh introuvable\"
            ls -la /mnt/www/update/live_head* 2>/dev/null || echo \"Aucun fichier live_head trouvé\"
            exit 1
        fi
        
        echo \"✅ Scan terminé sur group${group_formatted}\"
        '" 2>&1 | sed "s/^/[group${group_formatted}] /" || echo "[group${group_formatted}] ❌ Erreur connexion"
    
    # Compter succès/échecs
    if echo "$?" | grep -q "0"; then
        ((SUCCESS_COUNT++))
    else
        ((ERROR_COUNT++))
    fi
}

echo "🚀 Lancement scan Live Head sur INFRA1..."
echo "📡 75 serveurs à scanner"
echo "🕒 Timestamp deploy: $DEPLOY_TIMESTAMP"
echo ""

# Deploy par batches pour éviter surcharge (10 serveurs en parallèle car c'est rapide)
BATCH_SIZE=10
current_batch=1

for start_group in $(seq 1 $BATCH_SIZE $TOTAL_GROUPS); do
    end_group=$((start_group + BATCH_SIZE - 1))
    if [ $end_group -gt $TOTAL_GROUPS ]; then
        end_group=$TOTAL_GROUPS
    fi
    
    echo "📦 BATCH $current_batch: group$(printf %02d $start_group) → group$(printf %02d $end_group)"
    
    # Lancer ce batch en parallèle
    for group_num in $(seq $start_group $end_group); do
        deploy_server_ultra $group_num &
    done
    
    echo "⏳ Attente fin batch $current_batch..."
    wait
    
    echo "📊 Batch $current_batch terminé"
    echo ""
    
    ((current_batch++))
    
    # Pause courte entre batches
    if [ $end_group -lt $TOTAL_GROUPS ]; then
        echo "😴 Pause 5s avant batch suivant..."
        sleep 5
    fi
done

echo ""
echo "📊 RÉSULTATS SCAN LIVE HEAD INFRA1:"
echo "✅ Succès: $SUCCESS_COUNT/$TOTAL_GROUPS serveurs"
echo "❌ Échecs: $ERROR_COUNT/$TOTAL_GROUPS serveurs" 
echo "🕒 Fin scan: $(date)"

if [ $SUCCESS_COUNT -gt $((TOTAL_GROUPS * 70 / 100)) ]; then
    echo ""
    echo "🎉 SCAN MAJORITAIRE - Plus de 70% des serveurs scannés"
    echo "💾 Données envoyées vers Cloudflare Worker"
elif [ $SUCCESS_COUNT -gt $((TOTAL_GROUPS * 50 / 100)) ]; then
    echo ""
    echo "✅ SCAN PARTIEL - Plus de 50% des serveurs scannés"
else
    echo ""
    echo "⚠️  SCAN INCOMPLET - Beaucoup d'échecs, vérifier connectivité"
fi

echo ""
echo "📋 Logs: /mnt/www/update/log/live_head-jenkins-infra1-${DEPLOY_TIMESTAMP}-groupXX.log"