#!/usr/bin/env bash
# Deploy automatizado do app Estuda Palhoça (Windows/MSYS-safe).
# Uso: bash deploy.sh "mensagem do commit"
# Faz: bump de versao (version.json + APP_VER), git add/commit/push, aguarda Pages, verifica version.json servido.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

MSG="${1:-atualizacao automatica do app}"
TODAY="$(date +%Y-%m-%d)"

# --- le versao atual via python (evita erro de grep no Windows) ---
VER=$(python -c "import json;print(json.load(open('version.json',encoding='utf-8'))['version'])")
NUM=$(python -c "import re;print(re.search(r'[0-9]+', '''$VER''').group())")
NEXT=$((NUM+1))
NEWVER="v${NEXT}"

# --- atualiza version.json ---
python -c "
import json
d=json.load(open('version.json',encoding='utf-8'))
d['version']='$NEWVER'
d['updated']='$TODAY'
json.dump(d,open('version.json','w',encoding='utf-8'),ensure_ascii=False,indent=2)
open('version.json','a',encoding='utf-8').write('\n')
"

# --- atualiza APP_VER no index.html ---
python -c "
import re
s=open('index.html',encoding='utf-8').read()
s=re.sub(r\"const APP_VER='v[0-9]*';\",\"const APP_VER='$NEWVER';\",s,count=1)
open('index.html','w',encoding='utf-8').write(s)
"

echo "Versao: $VER -> $NEWVER"

git add -A
git commit -q -m "$NEWVER: $MSG"
git push -q origin master
echo "Push OK. Aguardando GitHub Pages..."

# aguarda until version.json servido == nova versao (max 180s)
for i in $(seq 1 36); do
  sleep 5
  SERVED=$(curl -sS "https://leonardolauriquer.github.io/estuda-palhoca/version.json" 2>/dev/null | python -c "import sys,json;print(json.load(sys.stdin)['version'])" 2>/dev/null || true)
  if [ "$SERVED" = "$NEWVER" ]; then
    echo "Deploy confirmado: servidor em $NEWVER (HTTP 200)."
    echo "Link: https://leonardolauriquer.github.io/estuda-palhoca/"
    exit 0
  fi
done
echo "AVISO: push feito mas version.json servido ainda e '$SERVED' (esperado $NEWVER). Verifique em alguns segundos com curl."
