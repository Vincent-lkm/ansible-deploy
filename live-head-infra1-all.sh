#!/bin/bash

echo "🚀 Live Head INFRA1 ALL - $(date)"
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
            echo \"⚠️ Script non trouvé\"
        fi
        "' 2>&1 | sed "s/^/[group${group_num}] /" || echo "[group${group_num}] ❌ Erreur connexion"
}

# Export des variables nécessaires pour le parallélisme
export -f run_live_head

echo "🚀 Scan Live Head sur 74 serveurs INFRA1..."
echo "⏰ Début: $(date)"
echo ""

# Lancer en parallèle par batch de 5
echo "🔄 Exécution en parallèle (5 serveurs simultanément)..."

# Générer la liste des numéros avec padding
printf "%02d\n" {1..74} | xargs -P 5 -I {} bash -c 'run_live_head {}'

echo ""
echo "✅ Live Head INFRA1 ALL terminé - $(date)"
echo "📊 74 serveurs scannés"
echo "💾 Données envoyées vers Cloudflare"