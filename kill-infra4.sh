#!/bin/bash

echo "💀 Kill ULTRA INFRA4 ALL - Bypass .bashrc - $(date)"
echo "🎯 Serveurs cibles: group01 à group66 (tous batches INFRA4)"
echo "📊 Total: 66 serveurs"
echo ""

# Fonction kill ultra-robuste - VERSION JENKINS
kill_server_ultra() {
    local group_num=$1
    echo "💀 Kill ultra sur group${group_num}..."
    
    # ProxyCommand avec -W pour redirection de port
    ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2200 root@infra4.linkuma.ovh -W %h:%p" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=20 \
        -o ServerAliveInterval=10 \
        -o ServerAliveCountMax=2 \
        -o LogLevel=ERROR \
        -p 2222 \
        root@apache.group${group_num}.svc.cluster.local \
        'bash --noprofile --norc -c "
        echo \"🔍 Kill sur \$(hostname)\"
        pkill -9 -f \"update.sh\" 2>/dev/null && echo \"✅ Processus tués\" || echo \"⚠️ Aucun processus\"
        find /mnt/www -name \"*.lock\" -type f 2>/dev/null | xargs -r rm -f 2>/dev/null
        echo \"✅ Terminé\"
        "' 2>&1 | sed "s/^/[group${group_num}] /" || echo "[group${group_num}] ❌ Erreur connexion"
}

# Kill séquentiel sur TOUS les serveurs INFRA4
echo "🚀 Kill séquentiel ultra-robuste sur 66 serveurs..."
echo "⏰ Début: $(date)"
echo ""

# Compteur de progression
total_servers=66
current=0

for i in {01..66}; do
    current=$((current + 1))
    echo "📊 Progression: $current/$total_servers"
    kill_server_ultra $i
    sleep 0.3
done

echo ""
echo "✅ Kill ultra INFRA4 ALL terminé - $(date)"
echo "📊 66 serveurs traités"
echo "💀 Tous les processus update.sh tués sur INFRA4"
