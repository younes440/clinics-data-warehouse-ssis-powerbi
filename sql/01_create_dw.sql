/* ============================================================
   DW_Cliniques : creation de la base et des tables
   Schema en etoile : fact_ca au centre, dimensions Nationalite
   et Medecin, table pilote source_liste.
   ============================================================ */
CREATE DATABASE DW_Cliniques;
GO
USE DW_Cliniques;
GO

-- Table pilote : une ligne par clinique (source de donnees)
CREATE TABLE source_liste (
    code_clinique     VARCHAR(10)  PRIMARY KEY,
    connection_string VARCHAR(500) NOT NULL
);

-- Dimension Nationalite
CREATE TABLE dim_nationalite (
    codnat        VARCHAR(10) NOT NULL,
    code_clinique VARCHAR(10) NOT NULL,
    designation   VARCHAR(100),
    date_maj      DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (codnat, code_clinique)
);

-- Dimension Medecin
CREATE TABLE dim_medecin (
    codmed        VARCHAR(10) NOT NULL,
    code_clinique VARCHAR(10) NOT NULL,
    nom_medecin   VARCHAR(150),
    specialite    VARCHAR(150),
    date_maj      DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (codmed, code_clinique)
);

-- Table de faits : chiffre d'affaires et admissions
CREATE TABLE fact_ca (
    id_fact            INT IDENTITY(1,1) PRIMARY KEY,
    codnat             VARCHAR(10),
    codmed             VARCHAR(10),
    code_clinique      VARCHAR(10) NOT NULL,
    datope             DATE,
    famille_prestation VARCHAR(50),
    organisme          VARCHAR(50),
    type_admission     VARCHAR(50),
    occupation         VARCHAR(50),
    centre             VARCHAR(50),
    ca                 DECIMAL(18,2),
    nbr_admission      INT,
    CONSTRAINT FK_fact_nat FOREIGN KEY (codnat, code_clinique)
        REFERENCES dim_nationalite (codnat, code_clinique),
    CONSTRAINT FK_fact_med FOREIGN KEY (codmed, code_clinique)
        REFERENCES dim_medecin (codmed, code_clinique)
);
GO

-- Index utiles pour la purge par clinique et les analyses par date
CREATE INDEX IX_fact_ca_clinique ON fact_ca (code_clinique);
CREATE INDEX IX_fact_ca_datope   ON fact_ca (datope);
GO
