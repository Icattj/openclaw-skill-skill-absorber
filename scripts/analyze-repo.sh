#!/usr/bin/env bash
# analyze-repo.sh — Quick repo analysis for skill absorption
# Usage: ./analyze-repo.sh <github-url>

set -euo pipefail

URL="${1:?Usage: analyze-repo.sh <github-url>}"

# Normalize URL
REPO=$(echo "$URL" | sed 's|https://github.com/||;s|/$||;s|\.git$||')
OWNER=$(echo "$REPO" | cut -d/ -f1)
NAME=$(echo "$REPO" | cut -d/ -f2)

echo "=== REPO ANALYSIS: $OWNER/$NAME ==="
echo ""

# 1. Basic info via GitHub API
echo "## Basic Info"
curl -sL "https://api.github.com/repos/$OWNER/$NAME" 2>/dev/null | \
  python3 -c "
import json,sys
try:
  d=json.load(sys.stdin)
  print(f'Name: {d.get(\"full_name\",\"?\")}'  )
  print(f'Description: {d.get(\"description\",\"?\")}'  )
  print(f'Stars: {d.get(\"stargazers_count\",0)}'  )
  print(f'Language: {d.get(\"language\",\"?\")}'  )
  print(f'License: {d.get(\"license\",{}).get(\"spdx_id\",\"?\")}'  )
  print(f'Last push: {d.get(\"pushed_at\",\"?\")}'  )
  print(f'Open issues: {d.get(\"open_issues_count\",0)}'  )
  print(f'Forks: {d.get(\"forks_count\",0)}'  )
  print(f'Topics: {\", \".join(d.get(\"topics\",[]))}'  )
except: print('API error — rate limited or repo not found')
" 2>/dev/null
echo ""

# 2. File structure (top-level)
echo "## File Structure (top-level)"
curl -sL "https://api.github.com/repos/$OWNER/$NAME/contents/" 2>/dev/null | \
  python3 -c "
import json,sys
try:
  items=json.load(sys.stdin)
  for i in sorted(items, key=lambda x: (x['type']!='dir', x['name'])):
    icon = '📁' if i['type']=='dir' else '📄'
    size = f' ({i[\"size\"]}B)' if i['type']=='file' and i.get('size',0)>0 else ''
    print(f'{icon} {i[\"name\"]}{size}')
except: print('Could not list files')
" 2>/dev/null
echo ""

# 3. Package info
echo "## Dependencies"
# Check package.json
PKG=$(curl -sL "https://raw.githubusercontent.com/$OWNER/$NAME/main/package.json" 2>/dev/null)
if echo "$PKG" | python3 -c "import json,sys;json.load(sys.stdin)" 2>/dev/null; then
  echo "Node.js project detected"
  echo "$PKG" | python3 -c "
import json,sys
d=json.load(sys.stdin)
deps=list(d.get('dependencies',{}).keys())
dev=list(d.get('devDependencies',{}).keys())
if deps: print(f'Dependencies: {\", \".join(deps[:20])}')
if dev: print(f'Dev deps: {\", \".join(dev[:10])}')
print(f'Scripts: {\", \".join(list(d.get(\"scripts\",{}).keys())[:10])}')
" 2>/dev/null
fi

# Check pyproject.toml / requirements.txt
REQ=$(curl -sL "https://raw.githubusercontent.com/$OWNER/$NAME/main/requirements.txt" 2>/dev/null)
if [ ${#REQ} -gt 5 ] && ! echo "$REQ" | grep -q "404"; then
  echo "Python project detected (requirements.txt)"
  echo "$REQ" | head -20
fi

PYPROJ=$(curl -sL "https://raw.githubusercontent.com/$OWNER/$NAME/main/pyproject.toml" 2>/dev/null)
if [ ${#PYPROJ} -gt 5 ] && ! echo "$PYPROJ" | grep -q "404"; then
  echo "Python project detected (pyproject.toml)"
  echo "$PYPROJ" | grep -E "^(name|version|dependencies)" | head -10
fi
echo ""

echo "=== END ANALYSIS ==="
