# Rapport Power BI

Le rapport se connecte au Data Warehouse `DW_Cliniques` en mode **Import**.
Les mesures DAX sont dans [`measures.dax`](measures.dax).

> Le fichier `.pbix` n'est versionné que s'il ne contient que des **données fictives**
> (`rapport_demo.pbix`). Voir [`../sql/04_demo_data_fictive.sql`](../sql/04_demo_data_fictive.sql).

## Construction pas à pas

1. **Connexion** : Obtenir les données > SQL Server, base `DW_Cliniques`, mode Import.
   Charger `fact_ca`, `dim_nationalite`, `dim_medecin`.
2. **Table de dates** : créer `Dim_Date` (voir `measures.dax`).
3. **Clés composites** : créer les colonnes `CleNat` et `CleMed`, puis les relations
   dans la vue Modèle (clé métier + code clinique).
4. **Mesures** : créer les mesures dans l'ordre du fichier `measures.dax`.
5. **Page principale** : slicer « Jusqu'au », 3 cartes KPI (CA journalier, mensuel, annuel),
   puis pour chaque granularité une matrice, une courbe N / N-1 et un anneau par famille de prestations.
6. **Navigation** : un signet par granularité (`BM_Journalier`, `BM_Mensuel`, `BM_Annuel`, `BM_Activite`)
   et quatre boutons avec une action de type Signet.
7. **Pages d'analyse par axe** : famille de prestations, organisme, nationalité, type d'admission,
   occupation, centre, consultation, et une page croisant type d'admission et spécialité du médecin.

## Tests

- Changer la date du slicer : KPI et tableaux se mettent à jour.
- Cliquer sur chaque bouton : seuls les visuels du groupe choisi s'affichent.
- Comparer quelques totaux avec une requête SQL de contrôle sur `fact_ca`.
