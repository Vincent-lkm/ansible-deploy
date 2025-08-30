#!/bin/bash

echo "💀 Kill ULTRA batch1 - Bypass .bashrc - $(date)"
echo "🎯 Serveurs cibles: group01 à group10 (batch1)"
echo ""

# Fonction kill ultra-robuste
kill_server_ultra() {
    local group_num=$1
    echo "💀 Kill ultra sur group${group_num}..."
    
    # Commande directe qui bypass le .bashrc en utilisant bash --noprofile --norc
    ssh -o ProxyJump=bastion@infra.linkuma.ovh:2200 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=20 \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=2 \
        -p 2222 root@apache.group${group_num}.svc.cluster.local \
        'bash --noprofile --norc -c "
        echo \"🔍 Kill sur \$(hostname)\"
        pkill -9 -f \"update.sh\" 2>/dev/null && echo \"✅ Processus tués\" || echo \"⚠️ Aucun processus\"
        find /mnt/www -name \"*.lock\" -type f 2>/dev/null | xargs -r rm -f 2>/dev/null
        echo \"✅ Terminé\"
        "' 2>&1 | sed "s/^/[group${group_num}] /" || echo "[group${group_num}] ❌ Erreur connexion"
}

# Kill séquentiel pour debug (plus stable)
echo "🚀 Kill séquentiel ultra-robuste..."
for i in {01..10}; do
    kill_server_ultra $i
    sleep 0.5  # Petite pause entre chaque serveur
done

echo ""
echo "✅ Kill ultra batch1 terminé - $(date)"
