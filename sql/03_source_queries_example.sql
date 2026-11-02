/* ============================================================
   Requetes sources : MODELES GENERIQUES.
   Les noms de tables/colonnes du systeme source reel sont
   confidentiels et ont ete remplaces par des noms neutres.
   Chaque requete doit retourner EXACTEMENT les colonnes
   attendues par le package SSIS correspondant.
   ============================================================ */

-- 1) Dimension Nationalite  ->  PKG_Dim_Nationalite
--    Colonnes attendues : codnat, designation
SELECT DISTINCT
    p.nationality_code        AS codnat,
    n.label                   AS designation
FROM patient p
LEFT JOIN nationality n ON n.code = p.nationality_code
WHERE p.nationality_code IS NOT NULL;

-- 2) Dimension Medecin  ->  PKG_Dim_Medecin
--    Colonnes attendues : codmed, nom_medecin, specialite
SELECT DISTINCT
    d.doctor_code             AS codmed,
    d.doctor_name             AS nom_medecin,
    s.label                   AS specialite
FROM doctor d
INNER JOIN specialty s ON d.specialty_code = s.code
WHERE d.doctor_code IS NOT NULL;

-- 3) Table de faits  ->  PKG_Fact_CA
--    Colonnes attendues : codnat, codmed, datope, famille_prestation,
--    organisme, type_admission, occupation, centre, ca, nbr_admission
SELECT
    p.nationality_code        AS codnat,
    a.doctor_code             AS codmed,
    b.operation_date          AS datope,
    sv.service_family         AS famille_prestation,
    ins.insurer_code          AS organisme,
    a.admission_type          AS type_admission,
    a.occupation_code         AS occupation,
    loc.center_code           AS centre,
    SUM(b.amount * (1 - b.discount_rate))   AS ca,
    COUNT(DISTINCT b.admission_id)          AS nbr_admission
FROM billing_line b
LEFT JOIN admission a   ON a.admission_id  = b.admission_id
LEFT JOIN patient   p   ON p.patient_id    = a.patient_id
LEFT JOIN service   sv  ON sv.service_id   = b.service_id
LEFT JOIN insurer   ins ON ins.insurer_id  = a.insurer_id
LEFT JOIN location  loc ON loc.location_id = b.location_id
WHERE b.line_nature = 'C'
  AND YEAR(b.operation_date) = 2024      -- adapter la plage d'annees
GROUP BY p.nationality_code, a.doctor_code, b.operation_date,
         sv.service_family, ins.insurer_code, a.admission_type,
         a.occupation_code, loc.center_code;

-- Controle apres chargement (idempotence : meme resultat apres 2 executions)
-- SELECT code_clinique, COUNT(*) AS nb_lignes, SUM(ca) AS ca_total
-- FROM fact_ca GROUP BY code_clinique;
