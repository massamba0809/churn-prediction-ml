# Partie 5 — Évaluation & interprétation

Responsable : Membre 5 ([@harounambaye](https://github.com/harounambaye))

Notebook associé : [`notebooks/05_evaluation_interpretation.ipynb`](../notebooks/05_evaluation_interpretation.ipynb)

## 1. Objectif et règles suivies

Évaluer les trois modèles optimisés de la partie 4 sur le jeu de test, choisir le seuil de décision, interpréter le modèle final, puis conclure avec des recommandations métier.

- **Le test est utilisé une seule fois** pour mesurer les modèles. Aucun hyperparamètre n'est modifié après l'avoir vu.
- **Le modèle final a été désigné avant le test** (régression logistique, voir partie 4, section 10), sur la validation croisée et la simplicité. Le test sert à confirmer ce choix.
- **Le seuil de décision est choisi sur le train** (prédictions *out-of-fold*, 5 plis), jamais sur le test.
- Même découpage que les parties 3 et 4 : 1 409 clients de test (26,5 % de churn, soit 374 clients qui partent), vérifié par identifiants.

## 2. Résultats sur le jeu de test (seuil 0,5)

| Modèle | Accuracy | Precision | Recall | F1 | ROC-AUC | PR-AUC |
|---|---|---|---|---|---|---|
| **Régression logistique** | 0,750 | 0,519 | 0,800 | **0,630** | **0,846** | 0,659 |
| Forêt aléatoire | 0,752 | 0,522 | 0,781 | 0,626 | 0,842 | 0,658 |
| Arbre de décision | 0,745 | 0,513 | 0,808 | 0,627 | 0,829 | 0,632 |

### Validation croisée contre test : pas de mauvaise surprise

| Modèle | F1 validation | F1 test | ROC-AUC validation | ROC-AUC test |
|---|---|---|---|---|
| Régression logistique | 0,635 | 0,629 | 0,849 | 0,846 |
| Forêt aléatoire | 0,634 | 0,626 | 0,847 | 0,842 |
| Arbre de décision | 0,621 | 0,627 | 0,832 | 0,829 |

Les écarts (de −0,008 à +0,006 sur le F1) sont inférieurs à l'écart-type entre plis de la partie 4 (0,013 à 0,021). Les scores de test ne sont pas meilleurs que ceux de validation, et la pente est cohérente : pas de signe de fuite de données ni de sur-apprentissage de la sélection.

### Les trois modèles sont indiscernables

Intervalles de confiance à 95 % par bootstrap (1 000 rééchantillonnages du test) :

| Modèle | F1 | ROC-AUC |
|---|---|---|
| Régression logistique | 0,629 [0,592 ; 0,663] | 0,846 [0,824 ; 0,867] |
| Forêt aléatoire | 0,626 [0,588 ; 0,660] | 0,842 [0,819 ; 0,863] |
| Arbre de décision | 0,627 [0,590 ; 0,662] | 0,829 [0,804 ; 0,852] |

Les intervalles se chevauchent presque entièrement. Avec seulement 374 churners dans le test, aucune différence entre modèles n'est significative. Le seul léger retard est celui de l'arbre en ROC-AUC. Figures : [matrices de confusion](../reports/figures/eval_matrices_confusion.png), [courbes ROC et précision-rappel](../reports/figures/eval_roc_pr.png).

## 3. Seuil de décision

Le seuil 0,5 est un défaut, pas un optimum. On le choisit en minimisant un coût moyen :

- faux négatif (client qui part, non détecté) : coût `C_FN` ;
- faux positif (client fidèle contacté pour rien) : coût `C_FP`.

Seul le rapport `C_FN / C_FP` compte. **Les coûts réels ne sont pas dans les données.** Hypothèse retenue : **rapport de 5** (une action de fidélisation coûte environ cinq fois moins que la perte du client). Cette valeur est à remplacer par celle de l'entreprise.

### Sensibilité du seuil optimal au rapport de coûts (train, out-of-fold)

| Modèle | 1 | 2 | 3 | **5** | 8 | 10 | 15 |
|---|---|---|---|---|---|---|---|
| Régression logistique | 0,72 | 0,59 | 0,48 | **0,37** | 0,24 | 0,19 | 0,19 |

Plus un départ coûte cher par rapport à un contact inutile, plus le seuil baisse. Le tableau complet des trois modèles est dans [`reports/evaluation_sensibilite_seuil.csv`](../reports/evaluation_sensibilite_seuil.csv). Courbe : [coût en fonction du seuil](../reports/figures/eval_cout_seuil.png).

### Effet sur le test (régression logistique)

| Règle | Precision | Recall | F1 | Churners ratés (FN) | Fausses alertes (FP) | Coût moyen |
|---|---|---|---|---|---|---|
| Seuil 0,5 | 0,519 | 0,800 | 0,630 | 75 | 277 | 0,463 |
| **Seuil 0,37** | 0,457 | **0,888** | 0,604 | **42** | 394 | **0,429** |

À 0,37 on rate 33 churners de moins (42 au lieu de 75) au prix de 117 contacts inutiles en plus, et le coût baisse d'environ 7 %. Le F1 baisse, ce qui est attendu : il pondère précision et recall à égalité, alors que le coût métier ne le fait pas.

Repères sur le test, avec le même rapport de 5 : ne rien faire coûte 1,327 par client (on rate les 374 churners), contacter tout le monde coûte 0,735. Le modèle à 0,37 (0,429) fait nettement mieux que les deux.

Pour la forêt, le gain est de même sens (0,481 → 0,441). Pour l'arbre il est négligeable (0,459 → 0,456).

## 4. Choix du modèle final : régression logistique

| Critère | Régression logistique | Forêt aléatoire | Arbre |
|---|---|---|---|
| Performance | équivalente | équivalente | ROC-AUC un peu plus bas |
| Interprétabilité | coefficients lisibles | importances globales | règles lisibles, instables |
| Taille | 4 Ko | 400 Ko | 10 Ko |
| Vitesse | très rapide | plus lente | rapide |

Le test confirme que rien ne justifie un modèle plus complexe : la forêt n'apporte aucun gain mesurable.

**Calibration** ([figure](../reports/figures/eval_calibration.png)) : les trois modèles surestiment le risque (courbes sous la diagonale, par exemple une probabilité prédite d'environ 0,75 pour une fréquence observée d'environ 0,55). C'est la conséquence de `class_weight="balanced"`. Les scores servent à **classer** les clients et à appliquer un seuil, mais ne sont **pas des probabilités réelles** : ne pas annoncer « 75 % de risque » sans recalibration.

## 5. Analyse des erreurs (régression logistique, seuil 0,37)

Sur le test : 332 churners détectés (VP), 42 ratés (FN), 394 fausses alertes (FP), 641 clients fidèles correctement écartés (VN).

| Groupe | Effectif | Ancienneté moy. (mois) | Contrat mensuel | Fibre | Chèque électronique |
|---|---|---|---|---|---|
| Détectés (VP) | 332 | 13,8 | 95 % | 72 % | 59 % |
| **Ratés (FN)** | 42 | **37,8** | **36 %** | 33 % | 21 % |
| Fausses alertes (FP) | 394 | 21,4 | 88 % | 59 % | 47 % |
| Fidèles écartés (VN) | 641 | 47,4 | 15 % | 20 % | 13 % |

- **Les churners ratés ressemblent à des clients stables** : contrat plus long, ancienneté élevée, peu de profil à risque. Ils partent pour des raisons absentes des données (concurrence, déménagement, insatisfaction). C'est une limite des données, qu'un meilleur modèle ne corrigerait pas facilement.
- **Les fausses alertes ressemblent à des churners** (contrat mensuel à 88 %, fibre, chèque électronique) : ce sont des clients au profil risqué qui restent. Le modèle ne peut pas les distinguer des partants avec les variables disponibles.

## 6. Interprétation

Figures : [coefficients](../reports/figures/eval_coefficients_logreg.png), [importance par permutation](../reports/figures/eval_importance_permutation.png).

### Ce que le modèle associe à un risque plus élevé

| Variable | Coefficient |
|---|---|
| Facturation dématérialisée | +0,252 |
| Internet fibre optique | +0,226 |
| Paiement par chèque électronique | +0,205 |
| Dépense mensuelle moyenne / mensualité | +0,180 / +0,179 |
| Contrat mensuel | +0,172 |
| Pas de sécurité en ligne | +0,170 |
| Fibre et contrat mensuel combinés | +0,169 |

### Ce qui réduit le risque

| Variable | Coefficient |
|---|---|
| Durée du contrat (mois) | −0,421 |
| Log du total facturé (proxy d'ancienneté cumulée) | −0,306 |
| Pas de lignes multiples | −0,178 |
| Contrat de deux ans | −0,178 |
| Internet DSL | −0,157 |
| Ancienneté (groupe, mois) | −0,151 / −0,140 |
| A des personnes à charge | −0,142 |

### Importance par permutation (baisse de ROC-AUC sur le test)

Les variables qui font le plus baisser la performance quand on les mélange : durée du contrat (0,014 en moyenne sur régression logistique et forêt), **type de contrat** (0,013), **total facturé en log** (0,011), groupe d'ancienneté, ancienneté, type d'internet, sécurité en ligne. La régression logistique s'appuie surtout sur la durée du contrat et le total facturé, la forêt sur le type de contrat et l'ancienneté.

**Prudence.** Plusieurs variables sont fortement corrélées (ancienneté, total facturé, dépense moyenne, mensualité) : la régularisation répartit leur effet, et un coefficient isolé peut tromper. Par exemple, la facturation dématérialisée arrive en tête des coefficients, mais n'apparaît pas parmi les variables importantes à la permutation : son effet est probablement faible, voire partagé avec d'autres variables. Ce sont des **associations, pas des causes** : on ne peut pas affirmer que changer le mode de paiement réduirait le départ.

### Retrouve-t-on les facteurs de risque de l'EDA ?

Taux de churn observé sur le test (moyenne 26,5 %) :

| Facteur | Part des clients | Taux de churn |
|---|---|---|
| Contrat mensuel | 54,9 % | 42,6 % |
| Contrat de deux ans | 23,8 % | 2,7 % |
| Fibre optique | 43,5 % | 41,1 % |
| Chèque électronique | 33,6 % | 43,5 % |
| Pas de sécurité en ligne | 49,8 % | 41,1 % |
| Pas de support technique | 49,8 % | 41,2 % |
| Ancienneté de 0 à 6 mois | 22,1 % | 55,6 % |

Les cinq facteurs de l'EDA (contrat mensuel, faible ancienneté, fibre, chèque électronique, absence de sécurité et de support) sont **tous retrouvés** par le modèle avec le bon signe, et chacun correspond à un taux de churn observé de 41 à 56 % contre 26,5 % en moyenne. Le contrat de deux ans est le profil le plus fidèle (2,7 %).

## 7. Recommandations métier

À valider avec l'entreprise, car ce sont des associations observées et non des effets causaux prouvés.

1. **Cibler les contrats mensuels récents** : c'est là que se concentrent les départs (contrat mensuel : 42,6 % de churn ; 0 à 6 mois : 55,6 %). Un appel ou une offre dans les premiers mois est le levier le plus rentable.
2. **Proposer des contrats longs** (un an, deux ans) avec une remise : le contrat de deux ans associe un churn de 2,7 %. Tester l'effet réel par un essai contrôlé.
3. **Pousser les services de sécurité et de support** aux clients qui n'en ont pas : leur absence est associée à 41 % de churn.
4. **Examiner l'offre fibre optique** : 41 % de churn pour la fibre contre un risque plus faible en DSL ; vérifier prix, qualité ou concurrence.
5. **Encourager le prélèvement automatique** plutôt que le chèque électronique (43,5 % de churn), au moins comme indicateur de risque.
6. **Utiliser le modèle comme outil de priorisation** : classer les clients par score et contacter ceux au-dessus du seuil, dont la valeur dépend du budget de l'équipe et du rapport de coûts réel.

## 8. Limites

- **Rapport de coûts hypothétique (5)** : le seuil et le gain affichés en dépendent. Le tableau de sensibilité permet de refaire le choix avec les vrais coûts.
- **Aucune notion de succès de l'action** : on suppose qu'un client contacté est sauvé. En réalité une partie part quand même, ce qui change le seuil optimal.
- **Probabilités non calibrées** (voir section 4).
- **F1 plafonné à environ 0,63** : les données ne contiennent pas les raisons du départ (prix des concurrents, qualité du réseau, réclamations, usage réel). Les churners ratés sont des clients au profil stable.
- **Un seul jeu de test de 1 409 clients** : les intervalles de confiance sont larges (± 0,035 sur le F1).
- **Dataset d'exemple IBM** de 2018, sans dimension temporelle : on ne peut pas vérifier que le modèle tient dans le temps, ni détecter une dérive des données.
- **Interprétation par association** : pas de lien causal démontré.

## 9. Livrables

| Fichier | Contenu |
|---|---|
| `notebooks/05_evaluation_interpretation.ipynb` | Évaluation, seuil, erreurs, interprétation |
| `reports/evaluation_test_seuil_05.csv` | Métriques de test des trois modèles au seuil 0,5 |
| `reports/evaluation_test_seuil_cout.csv` | Comparaison seuil 0,5 et seuil de coût |
| `reports/evaluation_sensibilite_seuil.csv` | Seuil optimal selon le rapport de coûts |
| `reports/evaluation_coefficients_logreg.csv` | Coefficients de la régression logistique |
| `reports/evaluation_seuil_final.csv` | Seuil retenu (0,37) et hypothèse de coût |
| `reports/figures/eval_*.png` | Matrices de confusion, ROC/PR, coût, calibration, coefficients, permutation |

## 10. Reproduire les résultats

```bash
pip install -r requirements.txt
cd notebooks
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=-1 05_evaluation_interpretation.ipynb
```

L'exécution prend environ une minute. Le notebook lit `models/*.joblib` : il faut les mêmes versions de scikit-learn (1.9.1) et imbalanced-learn (0.14.2).

## 11. Checklist de livraison

- [x] Évaluation unique sur le jeu de test, comparée à la validation croisée
- [x] Matrices de confusion, ROC, précision-rappel
- [x] Seuil de décision justifié par un coût, avec analyse de sensibilité
- [x] Modèle final choisi et justifié
- [x] Analyse des erreurs
- [x] Interprétation et comparaison avec les facteurs de l'EDA
- [x] Recommandations métier et limites
- [x] Notebook `05_evaluation_interpretation.ipynb` exécutable de haut en bas
- [ ] Pull Request ouverte vers `main`
