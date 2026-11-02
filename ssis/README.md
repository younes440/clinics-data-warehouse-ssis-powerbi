# Processus ETL (SSIS)

Projet Visual Studio : `ETL_DW_Cliniques` (Integration Services Project).

> **Avant de commiter tes fichiers `.dtsx`** : dans chaque package et dans le projet, mets
> `ProtectionLevel = DontSaveSensitive`, et vérifie qu'aucune chaîne de connexion réelle
> (nom de serveur, nom de base) ne reste dans le XML. Remplace-les par des valeurs fictives.

## Packages

| Package | Rôle | Table cible |
|---|---|---|
| `PKG_Dim_Nationalite` | Alimente la dimension Nationalité (SCD) | `dim_nationalite` |
| `PKG_Dim_Medecin` | Alimente la dimension Médecin (SCD) | `dim_medecin` |
| `PKG_Fact_CA` | Purge puis recharge la table de faits | `fact_ca` |
| `PKG_Master` (optionnel) | Enchaîne les 3 packages dans l'ordre | n/a |

Ordre d'exécution : `Dim_Nationalite` → `Dim_Medecin` → `Fact_CA`
(les dimensions doivent exister avant les faits à cause des clés étrangères).

## Principe commun aux 3 packages

1. **Variables** : `source_list` (Object), `connection_string` (String, valeur par défaut non vide),
   `code_clinique` (String).
2. **Get Source List** (Execute SQL Task) : `SELECT connection_string, code_clinique FROM source_liste;`
   avec résultat complet stocké dans `source_list`.
3. **Foreach Loop Container** (Foreach ADO Enumerator) : parcourt les cliniques et alimente
   `connection_string` et `code_clinique`.
4. **Connection manager dynamique `CM_Source`** (niveau package) : sa propriété `ConnectionString`
   est pilotée par l'expression `@[User::connection_string]`.
5. **Connection manager `CM_DW`** (niveau projet) : fixe, vers `DW_Cliniques`.
6. `DelayValidation = True` sur le Foreach Loop et sur le Data Flow Task, pour éviter les erreurs
   de validation avec la connexion dynamique.

Ajouter une clinique = ajouter une ligne dans `source_liste`, sans modifier les packages.

## Data Flow des dimensions

`OLE DB Source` → `Derived Column` (`code_clinique`, cast explicite
`(DT_STR,10,1252)@[User::code_clinique]`) → `Slowly Changing Dimension`.

- Business keys : clé métier + `code_clinique`.
- Attributs modifiables en **type 1** (la valeur est écrasée par la plus récente).
- Si tu as besoin de conserver l'historique des modifications, passe les attributs concernés en
  **type 2** (colonnes de validité à ajouter dans la dimension).

## Data Flow de la table de faits

Dans le Foreach Loop :

1. **Purge Fact** (Execute SQL Task) : `DELETE FROM fact_ca WHERE code_clinique = ?`
   (paramètre = `User::code_clinique`). Garantit l'**idempotence** : relancer le package
   ne crée aucun doublon.
2. **Data Flow Task** :
   `OLE DB Source` → `Derived Column` → `Data Conversion` →
   `Lookup dim_nationalite` → `Lookup dim_medecin` → `OLE DB Destination (fact_ca)`.
   - Les Lookups utilisent « Redirect rows to no match output ».
   - Les sorties « sans correspondance » sont écrites dans des fichiers plats (journal d'erreurs),
     ce qui évite d'arrêter tout le traitement pour quelques clés orphelines.

## Checklist de validation

- [ ] Les 3 packages s'exécutent sans erreur, individuellement puis via `PKG_Master`
- [ ] Les dimensions contiennent les lignes des deux cliniques
- [ ] `fact_ca` est peuplée (date et axes d'analyse compris)
- [ ] Deux exécutions successives donnent exactement les mêmes totaux (test d'idempotence)
