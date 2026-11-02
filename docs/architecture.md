# Architecture de la solution

## Vue d'ensemble

La solution suit une chaîne décisionnelle en trois couches : les données partent des bases
opérationnelles des cliniques, sont intégrées et transformées par l'ETL, stockées dans le
Data Warehouse, puis restituées dans Power BI.

```mermaid
flowchart LR
    A1[(Base clinique 1)] --> E
    A2[(Base clinique 2)] --> E
    P[(source_liste<br/>table pilote)] -.connexions.-> E
    E["Couche 1 : Intégration<br/>SSIS (ETL)"] --> D[("Couche 2 : Stockage<br/>DW_Cliniques<br/>SQL Server")]
    D --> R["Couche 3 : Restitution<br/>Power BI (DAX)"]
```

L'ETL est le seul chemin d'alimentation du Data Warehouse : le DW ne contient que des données
déjà extraites, transformées et contrôlées par SSIS.

## Modèle dimensionnel (schéma en étoile)

```mermaid
erDiagram
    dim_nationalite ||--o{ fact_ca : "codnat + code_clinique"
    dim_medecin     ||--o{ fact_ca : "codmed + code_clinique"
    source_liste {
        varchar code_clinique PK
        varchar connection_string
    }
    dim_nationalite {
        varchar codnat PK
        varchar code_clinique PK
        varchar designation
        datetime date_maj
    }
    dim_medecin {
        varchar codmed PK
        varchar code_clinique PK
        varchar nom_medecin
        varchar specialite
        datetime date_maj
    }
    fact_ca {
        int id_fact PK
        varchar codnat FK
        varchar codmed FK
        varchar code_clinique
        date datope
        varchar famille_prestation
        varchar organisme
        varchar type_admission
        varchar occupation
        varchar centre
        decimal ca
        int nbr_admission
    }
```

Les clés des dimensions sont **composites** (clé métier + `code_clinique`) : un même code peut
exister dans les deux cliniques avec une signification différente.

## Choix de conception

| Besoin | Réponse |
|---|---|
| Ajouter une clinique sans modifier le code | Table pilote `source_liste` + connexion dynamique par expression |
| Pas de doublons à chaque exécution | Purge par clinique avant rechargement (idempotence) |
| Données cohérentes avec les dimensions | Lookups vers `dim_nationalite` et `dim_medecin` |
| Erreurs de correspondance sans arrêt du processus | Sortie « sans correspondance » vers un journal |
| Comparaison N / N-1 et périodes variables | Table de dates dédiée et mesures DAX |
| Relations multi-colonnes dans Power BI | Clés composites concaténées (`CleNat`, `CleMed`) |

## Stack technique

SQL Server, SQL Server Integration Services (Visual Studio), Power BI Desktop, DAX.
