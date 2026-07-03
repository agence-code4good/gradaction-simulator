#!/usr/bin/env bash
#
# Réécrit l'historique git : supprime .git et recrée UN commit propre
# contenant uniquement la version CHIFFRÉE + la config (pas de node_modules,
# pas de src/ en clair). Puis push forcé vers origin/main.
#
# ⚠️ DESTRUCTIF ET IRRÉVERSIBLE. Le clair présent dans l'ancien historique
#    sera définitivement retiré de GitHub après le push forcé.
#
# Prérequis : avoir lancé `npm run build` pour chiffrer index.html.

set -euo pipefail
cd "$(dirname "$0")/.."

REMOTE_URL="git@github.com:agence-code4good/gradaction-simulator.git"
BRANCH="main"

# --- Garde-fou 1 : index.html doit être chiffré ---
if ! grep -q "staticrypt" index.html; then
  echo "❌ index.html n'est PAS chiffré. Lance d'abord : npm run build" >&2
  echo "   (Abandon pour éviter de figer la version en clair dans le nouvel historique.)" >&2
  exit 1
fi
echo "✅ index.html est chiffré."

# --- Garde-fou 2 : confirmation explicite ---
echo
echo "Cette opération va :"
echo "  • supprimer .git (tout l'historique local)"
echo "  • créer un unique commit propre"
echo "  • FORCER le push vers $REMOTE_URL ($BRANCH)"
echo
read -r -p "Taper exactement 'REECRIRE' pour continuer : " CONFIRM
[ "$CONFIRM" = "REECRIRE" ] || { echo "Abandon."; exit 1; }

# --- Réécriture ---
rm -rf .git
git init -b "$BRANCH"
git remote add origin "$REMOTE_URL"

# On ajoute uniquement les fichiers publiables. .gitignore exclut déjà
# node_modules/, src/, encrypted/, .staticrypt-build/ — mais on est explicite.
git add .gitignore index.html package.json package-lock.json .staticrypt.json
git commit -m "Simulateur pharmacien GradAction (page chiffrée StatiCrypt)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"

echo
echo "Historique local recréé :"
git log --oneline --stat

echo
echo "➡️  Dernière étape (push forcé) — à lancer manuellement pour rester maître du geste :"
echo "    git push --force origin $BRANCH"
