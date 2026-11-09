# Prédiction du churn client — Projet Machine Learning

Projet de groupe (5 membres) : prédire quels clients risquent de résilier leur abonnement (*churn*) à partir de leurs caractéristiques et de leur historique.

## Répartition des responsabilités

| Membre | Responsabilité | Branche | Livrable |
|---|---|---|---|
| 1 — Massamba Fall Séne ([@Massamba0809](https://github.com/Massamba0809)) | Compréhension métier & collecte des données | `partie-1-comprehension-donnees` | Dataset choisi, description des variables, présentation du problème |
| 2 — [@sinendoye](https://github.com/sinendoye) | Analyse exploratoire (EDA) | `partie-2-eda` | Notebook EDA avec graphiques et interprétations |
| 3 — [@dinho325](https://github.com/dinho325) | Prétraitement & Feature Engineering | `partie-3-preprocessing` | Données préparées + pipeline reproductible |
| 4 — [@maigadems](https://github.com/maigadems) | Entraînement & optimisation | `partie-4-modeles` | Modèles entraînés + tableau comparatif |
| 5 — [@harounambaye](https://github.com/harounambaye) | Évaluation & interprétation | `partie-5-evaluation` | Bilan d'évaluation, interprétation, conclusion |

## Structure du dépôt

```
.
├── data/
│   ├── raw/          # données brutes (jamais modifiées)
│   └── processed/    # données préparées (partie 3)
├── docs/             # description du problème et des variables (partie 1)
├── notebooks/        # un notebook par partie
├── src/              # code réutilisable (pipeline, fonctions)
├── models/           # modèles sauvegardés (partie 4)
├── reports/          # figures et tableaux de résultats
├── requirements.txt
└── README.md
```

## Installation

```bash
git clone <url-du-depot>
cd <nom-du-depot>
python -m venv .venv
source .venv/bin/activate        # Windows : .venv\Scripts\activate
pip install -r requirements.txt
```

## Règles de collaboration

1. Chaque membre travaille **uniquement sur sa branche** (`partie-X-...`). Ne pas pousser directement sur `main`.
2. Commits fréquents, messages clairs (ex. `eda: distribution de tenure par churn`).
3. Quand un livrable est prêt, ouvrir une **Pull Request** vers `main` ; le groupe relit et valide avant de passer à l'étape suivante.
4. Avant de commencer, mettre sa branche à jour : `git pull origin main`.
5. Un notebook par partie, nommé `0X_nom.ipynb`, exécutable de haut en bas.
6. Chaque membre doit comprendre le pipeline complet et pouvoir présenter le projet.

## Ordre de travail

Partie 1 → 2 → 3 → 4 → 5. La partie 1 (dataset) est mergée en premier pour que tout le monde parte des mêmes données.
