#!/usr/bin/env bash
# Deploy automatizado do app Estuda Palhoça.
# Uso: ./deploy.sh "mensagem do commit"
# Faz: bump de versao (version.json + APP_VER), git add/commit/push, aguarda Pages, verifica version.json servido.
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

MSG="${1:-atualizacao automatica do app}"
TODAY="$(date +%Y-%m-%d)"

# --- le versao atual ---
VER=$(grep -o '"version":"v[0-9]*"' version.json | grep -o 'v[0-9]*')
NUM=$(echo "$VER" | grep -o '[0-9]*')
NEXT=$((NUM+1))
NEWVER="v${NEXT}"

# --- atualiza version.json ---
python3 - "$NEWVER" "$TODAY" <<'PY'
import sys,json
v,t=sys.argv[1],sys.argv[2]
d=json.load(open('version.json',encoding='utf-8'))
d['version']=v
d['updated']=t
json.dump(d,open('version.json','w',encoding='utf-8'),ensure_ascii=False,indent=2)
open('version.json','a',encoding='utf-8').write('\n')  # github pages gosta de newline
PY

# --- atualiza APP_VER no index.html ---
python3 - "$NEWVER" <<'PY'
import sys,re
v=sys.argv[1]
s=open('index.html',encoding='utf-8').read()
s=re.sub(r"const APP_VER='v[0-9]*';","const APP_VER='%s';"%v,s,count=1)
open('index.html','w',encoding='utf-8').write(s)
PY

echo "Versao: $VER -> $NEWVER"

git add -A
git commit -q -m "$NEWVER: $MSG"
git push -q origin master
echo "Push OK. Aguardando GitHub Pages..."

# aguarda until version.json servido == nova versao (max 120s)
for i in $(seq 1 24); do
  sleep 5
  SERVED=$(curl -sS "https://leonardolauriquer.github.io/estuda-palhoca/version.json" 2>/dev/null | grep -o '"version":"v[0-9]*"' | grep -o 'v[0-9]*' || true)
  if [ "$SERVED" = "$NEWVER" ]; then
    echo "Deploy confirmado: servidor em $NEWVER (HTTP 200)."
    echo "Link: https://leonardolauriquer.github.io/estuda-palhoca/"
    exit 0
  fi
done
echo "AVISO: push feito mas version.json servido ainda e '$SERVED' (esperado $NEWVER). Verifique em alguns segundos."
