#!/bin/bash

echo "🚀 LANCEMENT LIVE_HEAD.SH - GROUP01_ONLY (INFRA2)"
echo "📊 Monitoring HTTP en cours..."
echo "=================================================="
echo ""

# Lancer le script sur group01_only
ansible -i inventory-infra2-groups group01_only -m shell -a "/mnt/www/update/live_head.sh" -u root

echo ""
echo "✅ MONITORING TERMINÉ - Données envoyées à Cloudflare"