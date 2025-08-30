#!/bin/bash

echo "💀 Kill ULTRA INFRA2 ALL - Bypass .bashrc - $(date)"
echo "🎯 Serveurs cibles: group01 à group72 (tous batches INFRA2)"
echo "📊 Total: 72 serveurs"
echo ""

# Fonction kill ultra-robuste - VERSION JENKINS FINALE
kill_server_ultra() {
    local group_num=$1
    echo "💀 Kill ultra sur group${group_num}..."
    
    # ProxyCommand avec -W pour redirection de port
    ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2200 root@infra2.linkuma.ovh -W %h:%p" \
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

# Kill séquentiel sur TOUS les serveurs INFRA2
echo "🚀 Kill séquentiel ultra-robuste sur 72 serveurs..."
echo "⏰ Début: $(date)"
echo ""

# Compteur de progression
total_servers=72
current=0

for i in {01..72}; do
    current=$((current + 1))
    echo "📊 Progression: $current/$total_servers"
    kill_server_ultra $i
    sleep 0.3
done

echo ""
echo "✅ Kill ultra INFRA2 ALL terminé - $(date)"
echo "📊 72 serveurs traités"
echo "💀 Tous les processus update.sh tués sur INFRA2"
