# Partie 1 — Compréhension métier & collecte des données

Responsable : Massamba Fall Séne (Membre 1)

## 1. Le problème du churn

Le *churn* (attrition) désigne le départ d'un client qui résilie son abonnement ou cesse d'utiliser un service. Pour une entreprise de télécommunications, acquérir un nouveau client coûte nettement plus cher que fidéliser un client existant. Identifier à l'avance les clients à risque permet de déclencher des actions ciblées (offre commerciale, appel de fidélisation, changement de contrat).

## 2. Objectif du projet

Construire un modèle de classification binaire qui prédit si un client va quitter l'entreprise (`Churn = Yes`) ou rester (`Churn = No`), puis identifier les facteurs qui influencent le plus ce départ afin de formuler des recommandations métier.

- **Type de tâche** : classification supervisée binaire
- **Variable cible** : `Churn`
- **Métrique clé** : Recall et F1-score sur la classe « churn » (rater un client qui part coûte plus cher que lancer une action inutile), complétés par ROC-AUC

## 3. Dataset proposé

**Telco Customer Churn** (IBM Sample Data, disponible sur Kaggle).

- Environ 7 043 clients, 21 colonnes
- Un client par ligne
- Environ 26 % de clients churnés → classes **déséquilibrées**, point d'attention pour les parties 3, 4 et 5
- À faire : vérifier sur la page Kaggle la licence, la date de mise à jour et la documentation officielle, puis noter l'URL exacte ci-dessous

URL source : _à compléter_
Licence : _à compléter_

## 4. Description des variables

| Variable | Type | Description |
|---|---|---|
| customerID | Identifiant | Identifiant unique du client (à exclure du modèle) |
| gender | Catégorielle | Genre du client |
| SeniorCitizen | Binaire (0/1) | Client senior ou non |
| Partner | Catégorielle (Yes/No) | Vit en couple |
| Dependents | Catégorielle (Yes/No) | A des personnes à charge |
| tenure | Numérique | Nombre de mois depuis la souscription |
| PhoneService | Catégorielle (Yes/No) | Service téléphonique |
| MultipleLines | Catégorielle | Plusieurs lignes téléphoniques |
| InternetService | Catégorielle | Type d'accès internet (DSL, Fiber optic, No) |
| OnlineSecurity | Catégorielle | Option sécurité en ligne |
| OnlineBackup | Catégorielle | Option sauvegarde en ligne |
| DeviceProtection | Catégorielle | Protection des appareils |
| TechSupport | Catégorielle | Support technique |
| StreamingTV | Catégorielle | Streaming TV |
| StreamingMovies | Catégorielle | Streaming films |
| Contract | Catégorielle | Type de contrat (Month-to-month, One year, Two year) |
| PaperlessBilling | Catégorielle (Yes/No) | Facturation dématérialisée |
| PaymentMethod | Catégorielle | Mode de paiement |
| MonthlyCharges | Numérique | Montant facturé par mois |
| TotalCharges | Numérique (stocké en texte) | Montant total facturé |
| **Churn** | **Cible (Yes/No)** | **Le client a-t-il quitté l'entreprise ?** |

## 5. Points de vigilance à transmettre aux autres membres

- `TotalCharges` est lu comme texte (`object`) et contient quelques valeurs vides, concernant des clients avec `tenure = 0` : à traiter en partie 3.
- `customerID` ne doit pas servir de variable explicative.
- Classes déséquilibrées : ne pas se fier à l'accuracy seule.
- Plusieurs services (OnlineSecurity, StreamingTV…) ont une modalité « No internet service » : à encoder avec soin.

## 6. Checklist de livraison

- [ ] Dataset téléchargé dans `data/raw/`
- [ ] Source, licence et date notées dans ce document
- [ ] Dimensions et types vérifiés avec pandas (`shape`, `dtypes`)
- [ ] Présentation du problème prête pour l'oral
- [ ] Pull Request ouverte vers `main`
