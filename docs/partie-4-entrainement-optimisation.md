# Partie 4 — Entraînement & optimisation des modèles

Responsable : Membre 4 ([@maigadems](https://github.com/maigadems))

Notebook associé : [`notebooks/04_entrainement_optimisation.ipynb`](../notebooks/04_entrainement_optimisation.ipynb)

## 1. Objectif

Entraîner plusieurs modèles de classification pour prédire le churn, les comparer **sans fuite de données**, puis optimiser leurs hyperparamètres. L'évaluation finale sur le jeu de test (matrices de confusion, interprétation, recommandations) est le travail de la partie 5.

- **Métrique de décision** : F1-score de la classe churn, avec le Recall en seconde lecture, complétés par la ROC-AUC. L'accuracy n'est donnée qu'à titre indicatif : un modèle « toujours reste » obtient 73,5 %.
- **Règle d'or** : le jeu de test n'est **jamais utilisé** dans cette partie. Toutes les décisions reposent sur la validation croisée du train.

## 2. Données et validation

| Élément | Choix |
|---|---|
| Point de départ | `notebooks/outputs/telco_clean_features.csv` (données nettoyées avec nouvelles variables, **avant** encodage et mise à l'échelle) |
| Découpage | 80 % / 20 %, stratifié sur `Churn`, `random_state=42` : 5 634 clients en train, 1 409 en test. Vérifié identique à la partie 3 (mêmes clients) |
| Prétraitement | Reconstruit à l'identique de la partie 3 (58 variables, écart maximal de 0 avec `train_processed.csv` et `test_processed.csv`) sous forme d'une fonction `make_preprocessor()` |
| Validation | Validation croisée stratifiée à 5 plis sur le train (`shuffle=True`, `random_state=42`), 26,5 % de churn dans chaque pli |
| Fuite de données | Le prétraitement est placé **dans** le pipeline : il est ré-appris sur les 4 plis d'entraînement de chaque tour, sans voir le pli de validation |

**Pourquoi ne pas partir de `train_processed.csv` ?** L'imputation et la standardisation y ont déjà été apprises sur tout le train. En validation croisée, cela ferait fuiter une partie de l'information des plis de validation. Repartir des données avant encodage évite ce problème.

## 3. Démarche

1. **Modèle de référence** : classe majoritaire (« toujours reste »).
2. **Trois modèles avec paramètres par défaut** : régression logistique, arbre de décision, forêt aléatoire.
3. **Gestion du déséquilibre** : `class_weight="balanced"` et SMOTE (appliqué uniquement sur les plis d'entraînement).
4. **Optimisation des hyperparamètres** : grille pour la régression logistique et l'arbre, recherche aléatoire (25 tirages) pour la forêt, F1 comme critère.
5. **Tableau comparatif** de toutes les expériences et **sauvegarde** des trois modèles optimisés.

## 4. Résultats

Moyennes sur les 5 plis de validation (train uniquement), triées par F1.

| Expérience | Accuracy | Precision | Recall | F1 | ROC-AUC |
|---|---|---|---|---|---|
| **Régression logistique optimisée** | 0,759 | 0,530 | 0,791 | **0,635** | 0,849 |
| **Forêt aléatoire optimisée** | 0,755 | 0,525 | 0,801 | **0,634** | 0,847 |
| Régression logistique + `class_weight` | 0,752 | 0,521 | 0,792 | 0,628 | 0,848 |
| Régression logistique + SMOTE | 0,762 | 0,538 | 0,749 | 0,626 | 0,840 |
| **Arbre de décision optimisé** | 0,743 | 0,510 | 0,795 | **0,621** | 0,832 |
| Forêt aléatoire + `class_weight` | 0,780 | 0,576 | 0,647 | 0,610 | 0,830 |
| Régression logistique (défaut) | 0,808 | 0,673 | 0,536 | 0,596 | 0,849 |
| Forêt aléatoire + SMOTE | 0,786 | 0,600 | 0,585 | 0,592 | 0,825 |
| Forêt aléatoire (défaut) | 0,791 | 0,638 | 0,495 | 0,557 | 0,828 |
| Arbre de décision (défaut) | 0,728 | 0,489 | 0,512 | 0,500 | 0,660 |
| Arbre de décision + `class_weight` | 0,734 | 0,498 | 0,500 | 0,499 | 0,659 |
| Référence « toujours reste » | 0,735 | 0 | 0 | 0 | 0,500 |

Le tableau complet, avec les écarts-types, les paramètres de chaque expérience et la durée de calcul, est dans [`reports/tableau_comparatif_experiences.csv`](../reports/tableau_comparatif_experiences.csv).

## 5. Décisions prises et justifications

| Décision | Justification |
|---|---|
| **F1 de la classe churn** comme critère | Partie 1 : rater un client qui part coûte plus cher qu'une action de fidélisation inutile, donc le recall compte ; le F1 évite de gagner du recall en signalant tout le monde |
| **`class_weight="balanced"`** retenu plutôt que SMOTE | F1 équivalent (0,628 contre 0,626, écart inférieur à la variation entre plis), mais plus simple, plus rapide et sans données synthétiques |
| Prétraitement **dans** le pipeline de validation | Évite la fuite de données entre plis |
| Recherche aléatoire pour la forêt | Espace de réglages plus grand et essais plus coûteux ; la grille complète aurait été trop longue |
| Jeu de test non utilisé | Éviter un score optimiste ; l'évaluation honnête relève de la partie 5 |

### Hyperparamètres retenus

| Modèle | Réglages |
|---|---|
| Régression logistique | `C = 0,01`, `class_weight="balanced"`, `max_iter=1000` |
| Arbre de décision | `criterion="gini"`, `max_depth=10`, `min_samples_leaf=50`, `class_weight="balanced"` |
| Forêt aléatoire | `n_estimators=100`, `max_depth=6`, `min_samples_leaf=2`, `max_features="log2"`, `class_weight="balanced_subsample"` |

## 6. Ce que montrent les résultats

- **Tous les modèles battent la référence**, donc les variables contiennent de l'information sur le churn.
- **Le déséquilibre fait monter le recall** d'environ 0,50 à environ 0,79, au prix d'une baisse de la precision (0,673 → 0,530 pour la régression logistique) et de l'accuracy. C'est le compromis voulu par le projet.
- **Le ROC-AUC ne change presque pas** avec le rééquilibrage : il déplace le seuil de décision mais n'améliore pas le classement des clients.
- **L'arbre et la forêt par défaut sur-apprennent** : F1 de 0,997 sur le train contre 0,500 et 0,557 en validation. L'optimisation ramène l'écart train/validation à 0,03 et 0,02.
- **La régression logistique gagne très peu** à l'optimisation (+0,007) : elle ne sur-apprenait pas, et les valeurs de `C` testées donnent toutes un F1 entre 0,628 et 0,635.
- **Les trois modèles optimisés sont statistiquement indiscernables** : l'écart de F1 entre eux (≤ 0,014) est du même ordre que la variation d'un pli à l'autre (écart-type de 0,013 à 0,021). Les modèles semblent plafonner à F1 ≈ 0,63 avec les variables actuelles.

## 7. Points de vigilance

- **Scores légèrement optimistes** : la meilleure combinaison de réglages a été retenue sur les mêmes plis qui servent à la scorer.
- **SMOTE standard** agit après l'encodage : il interpole aussi les colonnes 0/1 du one-hot. La variante `SMOTENC` serait plus rigoureuse, mais `class_weight` fait aussi bien.
- **Un modèle sauvegardé ne se recharge qu'avec les mêmes versions** de scikit-learn (1.9.1) et imbalanced-learn (0.14.2), fixées dans `requirements.txt`.
- **Le notebook réécrit le CSV du tableau comparatif** à chaque exécution. Seule la colonne `temps_s` (durée de calcul) change : les métriques sont identiques d'une exécution à l'autre (graine fixée). Ne pas commiter ce fichier pour ce seul motif.
- **`.gitignore` modifié** : les règles `models/*.pkl` et `models/*.joblib` ont été retirées pour versionner les trois modèles, qui sont légers (4 Ko, 10 Ko, 400 Ko).

## 8. Livrables

| Fichier | Contenu |
|---|---|
| `notebooks/04_entrainement_optimisation.ipynb` | Démarche complète, justifications et résultats |
| `reports/tableau_comparatif_experiences.csv` | 12 expériences, avec paramètres |
| `models/logreg_optimisee.joblib` | Pipeline complet (prétraitement + régression logistique) |
| `models/arbre_optimise.joblib` | Pipeline complet (prétraitement + arbre) |
| `models/foret_optimisee.joblib` | Pipeline complet (prétraitement + forêt) |

Les pipelines sauvegardés acceptent directement des clients bruts (colonnes de `telco_clean_features.csv`, sans `customerID` ni `Churn`) :

```python
import joblib
modele = joblib.load("models/logreg_optimisee.joblib")
probas = modele.predict_proba(X_test)[:, 1]   # probabilité de churn
```

## 9. Reproduire les résultats

```bash
pip install -r requirements.txt
cd notebooks
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 04_entrainement_optimisation.ipynb
```

L'exécution complète prend plusieurs minutes, à cause des recherches d'hyperparamètres.

## 10. Points à traiter en partie 5

- Évaluer **une seule fois** les modèles retenus sur le jeu de test et comparer aux scores de validation : un écart important signalerait un problème.
- Analyser les **matrices de confusion** et les erreurs de prédiction.
- Examiner le **seuil de décision** (0,5 utilisé ici), à justifier par un coût métier.
- Choisir le modèle final : les trois étant au même niveau, la régression logistique est un choix naturel pour sa simplicité et son interprétabilité, à confirmer sur le test et à discuter en groupe.
- Vérifier si les modèles retrouvent les facteurs de risque de l'EDA (contrat mensuel, faible ancienneté, fibre optique, chèque électronique, absence de services de sécurité ou de support).

## 11. Checklist de livraison

- [x] Stratégie de validation définie et modèle de référence
- [x] Plusieurs modèles entraînés (régression logistique, arbre, forêt)
- [x] Déséquilibre des classes traité
- [x] Hyperparamètres optimisés
- [x] Paramètres et résultats de chaque expérience consignés
- [x] Tableau comparatif exporté
- [x] Modèles sauvegardés et rechargement vérifié
- [x] Notebook `04_entrainement_optimisation.ipynb` exécutable de haut en bas
- [ ] Pull Request ouverte vers `main`
