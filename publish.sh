#!/bin/zsh
# Publie les pages légales NutriAI sur GitHub Pages (Masof1/nutriai-legal) après avoir
# rempli l'éditeur et l'email de contact. Lancé par Claude dès les réponses de Mathys.
# Usage : ./publish.sh "Nom de l'éditeur" "email@de.contact"
set -e
cd "$(dirname "$0")"
[ $# -eq 2 ] || { echo "usage : publish.sh \"Éditeur\" \"email\""; exit 1; }
DATE_FR=$(LC_ALL=fr_FR.UTF-8 date "+%-d %B %Y" 2>/dev/null || date "+%Y-%m-%d")
sed -i '' -e "s/{{EDITEUR}}/$1/g" -e "s/{{EMAIL}}/$2/g" -e "s/{{DATE}}/$DATE_FR/g" *.html
grep -l "{{" *.html && { echo "Il reste des {{placeholders}}"; exit 1; } || true
git add -A && git commit -q -m "Pages légales : éditeur et contact renseignés" || true
if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create Masof1/nutriai-legal --public --source=. --remote=origin --push --description "NutriAI — politique de confidentialité et support"
else
  git push -q -u origin HEAD
fi
BR=$(git branch --show-current)
gh api -X POST repos/Masof1/nutriai-legal/pages -f "source[branch]=$BR" -f "source[path]=/" >/dev/null 2>&1 || gh api -X PUT repos/Masof1/nutriai-legal/pages -f "source[branch]=$BR" -f "source[path]=/" >/dev/null
echo "Pages demandées — en ligne sous 1 à 2 min :"
echo "  https://masof1.github.io/nutriai-legal/confidentialite.html"
echo "  https://masof1.github.io/nutriai-legal/support.html"
