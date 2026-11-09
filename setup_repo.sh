#!/usr/bin/env bash
# Script d'initialisation du dépôt du projet churn.
# À lancer depuis la racine du dossier churn-prediction-ml (structure déjà créée).
#
# Prérequis : git installé, GitHub CLI (gh) installé et connecté (gh auth login).
# Sans gh : voir les étapes manuelles à la fin.

set -e

REPO="churn-prediction-ml"   # nom du dépôt, modifiable

# Pseudos GitHub des 4 collègues (partie 2, 3, 4, 5)
COLLABS=("sinendoye" "dinho325" "maigadems" "harounambaye")

# 1. Structure des dossiers
mkdir -p data/raw data/processed docs notebooks src models reports
touch data/raw/.gitkeep data/processed/.gitkeep models/.gitkeep reports/.gitkeep src/.gitkeep notebooks/.gitkeep

# 2. Premier commit sur main
git init -b main
git add .
git commit -m "init: structure du projet, README et description de la partie 1"

# 3. Création du dépôt sur GitHub (privé) et push
gh repo create "$REPO" --private --source=. --remote=origin --push

# 4. Création et push d'une branche par membre
for b in partie-1-comprehension-donnees partie-2-eda partie-3-preprocessing partie-4-modeles partie-5-evaluation; do
  git branch "$b"
  git push origin "$b"
done

# 5. Invitation des collaborateurs (accès en écriture)
OWNER=$(gh api user --jq .login)
for u in "${COLLABS[@]}"; do
  gh api -X PUT "repos/$OWNER/$REPO/collaborators/$u" -f permission=push
done

# 6. Te placer sur ta branche
git checkout partie-1-comprehension-donnees

echo "Terminé. Dépôt : https://github.com/$OWNER/$REPO"

# --- Étapes manuelles si gh n'est pas disponible ---
# 1. Créer le dépôt sur github.com (New repository, sans README).
# 2. git remote add origin https://github.com/Massamba0809/churn-prediction-ml.git
# 3. git push -u origin main, puis git push origin <chaque-branche>
# 4. Settings > Collaborators > Add people, pour chacun des 4 collègues.
