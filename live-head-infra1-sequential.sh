#!/bin/bash

echo "🚀 Live Head INFRA1 SEQUENTIAL - $(date)"
echo "🎯 Serveurs cibles: group01 à group74 (tous batches INFRA1)"
echo "📊 Total: 74 serveurs"
echo ""

# Fonction pour exécuter live_head.sh - VERSION JENKINS
run_live_head() {
    local group_num=$1
    echo "📡 Scan sur group${group_num}..."
    
    # ProxyCommand avec -W pour redirection de port (comme dans Kill All Updates - INFRA1 VALIDE)
    ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2200 root@infra.linkuma.ovh -W %h:%p" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=20 \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=2 \
        -o LogLevel=ERROR \
        -p 2222 \
        root@apache.group${group_num}.svc.cluster.local \
        'bash --noprofile --norc -c "
        echo \"🔍 Scan sur \$(hostname)\"
        if [ -f /mnt/www/update/live_head.sh ]; then
            result=\$(/mnt/www/update/live_head.sh 2>/dev/null)
            echo \"✅ \$result\"
        else
            echo \"⚠️ Script non trouvé sur group'${group_num}'\"
        fi
        "' 2>&1 | sed "s/^/[group${group_num}] /" || echo "[group${group_num}] ❌ Erreur connexion"
}

echo "🚀 Scan séquentiel sur 74 serveurs..."
echo "⏰ Début: $(date)"
echo ""

# Compteur de progression
total_servers=74
current=0
success=0
failed=0

for i in {01..74}; do
    current=$((current + 1))
    echo "📊 Progression: $current/$total_servers"
    
    output=$(run_live_head $i)
    echo "$output"
    
    # Compter succès/échecs
    if echo "$output" | grep -q "✅"; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    
    # Petite pause pour éviter de surcharger
    sleep 0.5
done

echo ""
echo "✅ Live Head INFRA1 SEQUENTIAL terminé - $(date)"
echo "📊 Résultats:"
echo "   - Succès: $success serveurs"
echo "   - Échecs: $failed serveurs"
echo "   - Total: $total_servers serveurs"
echo "💾 Données envoyées vers Cloudflare"