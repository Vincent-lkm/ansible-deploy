#!/bin/bash

echo "💀⚡ KILL ULTRA RAPIDE - TOUTES INFRASTRUCTURES EN PARALLÈLE - $(date) ⚡💀"
echo "================================================================"
echo "🎯 292 serveurs (INFRA1:74 + INFRA2:72 + INFRA3:68 + INFRA4:66 + TIER1:12)"
echo "⚡ MODE: Ultra-rapide avec connexions parallèles"
echo "================================================================"
echo ""

# Fonction kill pour chaque infra
kill_server() {
    local proxy=$1
    local group_num=$2
    local infra_name=$3
    
    ssh -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2200 root@${proxy}.linkuma.ovh -W %h:%p" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=10 \
        -o LogLevel=ERROR \
        -p 2222 \
        root@apache.group${group_num}.svc.cluster.local \
        "bash --noprofile --norc -c \"
        pkill -9 -f 'update.sh' 2>/dev/null
        find /mnt/www -name '*.lock' -type f 2>/dev/null | xargs -r rm -f 2>/dev/null
        echo 'OK'
        \"" 2>&1 | grep -q "OK" && echo "✅ [$infra_name] group${group_num}" || echo "❌ [$infra_name] group${group_num}" &
}

# Début
START_TIME=$(date +%s)
echo "🚀 Lancement de 292 connexions parallèles..."
echo ""

# INFRA1 (74 serveurs)
for i in {01..74}; do
    kill_server "infra" "$i" "INFRA1"
done

# INFRA2 (72 serveurs)
for i in {01..72}; do
    kill_server "infra2" "$i" "INFRA2"
done

# INFRA3 (68 serveurs)
for i in {01..68}; do
    kill_server "infra3" "$i" "INFRA3"
done

# INFRA4 (66 serveurs)
for i in {01..66}; do
    kill_server "infra4" "$i" "INFRA4"
done

# TIER1 (12 serveurs)
for i in {01..12}; do
    kill_server "tier1" "$i" "TIER1"
done

echo "⏳ Attente de la fin de toutes les connexions..."
wait

# Calcul du temps
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "================================================================"
echo "✅⚡ KILL ULTRA RAPIDE TERMINÉ - $(date) ⚡✅"
echo "⏱️ Durée totale: ${DURATION} secondes"
echo "💀 292 serveurs traités simultanément"
echo "================================================================"
