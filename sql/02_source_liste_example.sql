/* ============================================================
   Table pilote : EXEMPLE avec des valeurs FICTIVES.
   Remplacer SERVEUR_EXEMPLE et les noms de bases par les votres.
   Ne jamais commiter de vraies chaines de connexion.
   Pour ajouter une clinique : inserer une ligne, sans toucher
   aux packages SSIS.
   ============================================================ */
USE DW_Cliniques;
GO

INSERT INTO source_liste (code_clinique, connection_string) VALUES
('CL1', 'Provider=MSOLEDBSQL;Data Source=SERVEUR_EXEMPLE;Initial Catalog=base_clinique_1;Integrated Security=SSPI;'),
('CL2', 'Provider=MSOLEDBSQL;Data Source=SERVEUR_EXEMPLE;Initial Catalog=base_clinique_2;Integrated Security=SSPI;');
GO
-- Adapter le provider (MSOLEDBSQL) a celui installe sur votre machine.
