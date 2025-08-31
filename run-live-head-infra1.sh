#!/bin/bash

echo "🚀 LIVE HEAD - INFRA1 ALL (74 groupes)"
echo "=================================================="
echo "⏰ Début: $(date)"
echo ""

# Fonction pour exécuter live_head.sh sur un groupe
run_live_head() {
    local group_num=$1
    echo "[group${group_num}] Lancement..."
    
    ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2200 root@infra.linkuma.ovh -W %h:%p" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=20 \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=2 \
        -o LogLevel=ERROR \
        -p 2222 \
        root@apache.group${group_num}.svc.cluster.local \
        'bash --noprofile --norc -c "/mnt/www/update/live_head.sh"' 2>&1 | sed "s/^/[group${group_num}] /" || echo "[group${group_num}] ❌ Erreur"
}

# Exécution sur tous les groupes
for i in {01..74}; do
    run_live_head $i
    sleep 0.2
done

echo ""
echo "✅ LIVE HEAD INFRA1 terminé - $(date)"
echo "📊 74 groupes traités"