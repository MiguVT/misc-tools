#!/bin/bash
# hagezi-updater.sh - Script to update HaGeZi Enhanced Professional List for Technitium DNS (or adaptable for other DNS servers)

HAGEZI_DIR="/var/technitium/www"
TEMP_DIR="/tmp/hagezi-update"
COMBINED_FILE="$HAGEZI_DIR/hagezi-professional.txt"

mkdir -p $TEMP_DIR $HAGEZI_DIR

echo "# HaGeZi Enhanced Professional List - $(date)" > $COMBINED_FILE

# Base lists (Your current excellent setup)
echo "⬇️ Descargando Hagezi Core Lists..."
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro-onlydomains.txt" | grep -v '^#' >> $TEMP_DIR/all.txt
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.medium-onlydomains.txt" | grep -v '^#' >> $TEMP_DIR/all.txt
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds-adblock.txt" | grep -v '^#' | sed 's/||//g' | sed 's/\^//g' >> $TEMP_DIR/all.txt
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/popupads-onlydomains.txt" | grep -v '^#' >> $TEMP_DIR/all.txt

# Additional crucial enhancement lists
echo "🛡️ Añadiendo Hagezi Specialized Lists..."
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/hoster-onlydomains.txt" | grep -v '^#' >> $TEMP_DIR/all.txt
curl -s "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/dyndns-onlydomains.txt" | grep -v '^#' >> $TEMP_DIR/all.txt

# Optional: Add OISD Small list
echo "⚡ Añadiendo OISD Small..."
curl -s "https://small.oisd.nl/domainswild" | grep -v '^#' | grep -v '^!' >> $TEMP_DIR/all.txt

# Remove duplicates and combine
echo "🔄 Procesando y eliminando duplicados..."
cat $TEMP_DIR/all.txt | sort -u >> $COMBINED_FILE
rm -rf $TEMP_DIR

DOMAIN_COUNT=$(wc -l < $COMBINED_FILE)
echo "✅ Actualizado: $DOMAIN_COUNT dominios únicos"
echo "📂 Archivo: $COMBINED_FILE"
echo "📈 Recomendado para Technitium DNS"