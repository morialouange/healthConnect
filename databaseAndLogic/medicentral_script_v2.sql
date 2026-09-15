-- ============================================================
--  MediCentral — Système de Centralisation des Dossiers Médicaux
--  Script SQL v2.0 — aligné sur les 25 logiques métier
--  Université Polytechnique de Gitega — BAC3 Génie Logiciel
--  Technologies : Jakarta EE | GlassFish 7 | MySQL 8+
-- ============================================================
--
--  AJUSTEMENTS v2.0 :
--  [A1]  utilisateurs : ajout colonne profil_complete (L12/L13)
--  [A2]  rendez_vous  : ajout colonne priorite (L16)
--  [A3]  services     : categorie devient ENUM fermé (L24)
--  [A4]  TABLE notifications         manquante → ajoutée (L17)
--  [A5]  TABLE conges_medecin        manquante → ajoutée (L19)
--  [A6]  TABLE historique_modifications manquante → ajoutée (L18)
--  [A7]  SUPER_ADMIN : utilisateur dédié ajouté en données
--  [A8]  Données profil_complete     cohérentes avec L12
--  [A9]  Données priorite RDV        cohérentes avec L16
--  [A10] Données notifications       exemples L17
--  [A11] Données conges_medecin      exemples L19
--  [A12] Données historique_modif    exemples L18
--  [A13] INDEX de performance        sur FK et colonnes filtrées
--  [A14] VUE supplémentaire          vue_medecins_detail (L23)
--  [A15] VUE supplémentaire          vue_stats_etablissement (L08)
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS historique_modifications;
DROP TABLE IF EXISTS acces_dossier;
DROP TABLE IF EXISTS referenements;
DROP TABLE IF EXISTS lignes_prescription;
DROP TABLE IF EXISTS ordonances;
DROP TABLE IF EXISTS consultations;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS conges_medecin;
DROP TABLE IF EXISTS rendez_vous;
DROP TABLE IF EXISTS creneau_disponible;
DROP TABLE IF EXISTS disponibilite_semaine;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS etabli_utilisateurs;
DROP TABLE IF EXISTS medecins;
DROP TABLE IF EXISTS dossier_medicals;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS utilisateurs;
DROP TABLE IF EXISTS etablissement_santes;
DROP VIEW IF EXISTS vue_rdv_par_hopital;
DROP VIEW IF EXISTS vue_dossier_complet;
DROP VIEW IF EXISTS vue_medecins_par_hopital;
DROP VIEW IF EXISTS vue_medecins_detail;
DROP VIEW IF EXISTS vue_stats_etablissement;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- GROUPE 1 : TABLES GLOBALES (visibles par tous les hôpitaux)
-- ============================================================

-- Hôpitaux du réseau — gérés uniquement par le SUPER_ADMIN
CREATE TABLE etablissement_santes (
    id_etablissement    BIGINT PRIMARY KEY AUTO_INCREMENT,
    nom                 VARCHAR(150) NOT NULL,
    adresse             VARCHAR(255) NOT NULL,
    type_etablissement  VARCHAR(100) NOT NULL,
    email               VARCHAR(150) UNIQUE,
    telephone           VARCHAR(20),
    actif               BOOLEAN NOT NULL DEFAULT TRUE,
    date_inscription    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Utilisateurs — chaque utilisateur appartient à UN hôpital
-- [A1] Ajout : profil_complete pour la logique L12/L13
--              false au moment de la création
--              true après complétion du profil (1er login)
CREATE TABLE utilisateurs (
    id_utilisateur      BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement    BIGINT NULL,         -- NULL pour PATIENT (pas rattaché à un établissement)
    full_name           VARCHAR(150) NOT NULL,
    email               VARCHAR(150) NOT NULL UNIQUE,
    password_hash       VARCHAR(255) NOT NULL,
    role                ENUM('SUPER_ADMIN','ADMIN','MEDECIN','PATIENT') NOT NULL,
    actif               BOOLEAN NOT NULL DEFAULT TRUE,
    profil_complete     BOOLEAN NOT NULL DEFAULT FALSE,   -- [A1] L12/L13
    date_creation       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    derniere_connexion  DATETIME,
    CONSTRAINT fk_util_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
);

-- Patients — UN seul profil pour tout le réseau (GLOBAL)
-- Pas d'id_etablissement — le patient appartient au réseau, pas à un hôpital
CREATE TABLE patients (
    id_patient          BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur      BIGINT NOT NULL UNIQUE,
    numero_patient      VARCHAR(30) NOT NULL UNIQUE,  -- PAT-AAAA-NNNNN (L01)
    date_naissance      DATE NOT NULL,
    sexe                ENUM('M','F') NOT NULL,
    telephone           VARCHAR(20),
    groupe_sanguin      VARCHAR(10),
    allergies           TEXT,                          -- utilisé par L04
    adresse             VARCHAR(255),
    CONSTRAINT fk_patient_util FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateurs(id_utilisateur)
);

-- Dossier médical central — UN seul dossier par patient pour toute sa vie
-- GLOBAL : aucun filtre id_etablissement (L05, L10, L11)
CREATE TABLE dossier_medicals (
    id_dossier          BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_patient          BIGINT NOT NULL UNIQUE,
    numero_unique       VARCHAR(30) NOT NULL UNIQUE,  -- DOS-AAAA-NNNNN (L01)
    antecedents         TEXT,
    niveau_confidentialite VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    date_creation       DATE NOT NULL DEFAULT (CURRENT_DATE),
    date_mise_jour      DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_dossier_patient FOREIGN KEY (id_patient)
        REFERENCES patients(id_patient)
);

-- ============================================================
-- GROUPE 2 : TABLES PRIVÉES (isolation stricte par hôpital)
-- ============================================================

-- Médecins — informations professionnelles
-- Créé par ADMIN à la 1ère connexion du médecin (L12)
-- Modifiable par l'ADMIN (L23) et par le médecin lui-même (L25)
CREATE TABLE medecins (
    id_medecin          BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur      BIGINT NOT NULL UNIQUE,
    id_service          BIGINT NULL,                -- service de rattachement (optionnel à la création)
    specialite          VARCHAR(100),
    experience          VARCHAR(100),               -- ex: "10 ans"
    numero_ordre        VARCHAR(50) UNIQUE,         -- ex: OM-2026-001
    CONSTRAINT fk_medecin_util FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateurs(id_utilisateur),
    CONSTRAINT fk_medecin_service FOREIGN KEY (id_service)
        REFERENCES services(id_service)
);

-- Affectation médecin-hôpital
-- Un médecin peut être affecté à plusieurs hôpitaux (consultant)
-- ISOLATION : chaque ligne est privée à un hôpital
CREATE TABLE etabli_utilisateurs (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    date_affectation    DATE NOT NULL DEFAULT (CURRENT_DATE),
    role_dans_hopital   VARCHAR(100),
    actif               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_eu_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_eu_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement),
    CONSTRAINT uq_medecin_etab UNIQUE (id_medecin, id_etablissement)
);

-- Services — PRIVÉ par hôpital (L24)
-- [A3] categorie : ENUM fermé pour cohérence avec L24
--      Valeurs : URGENCE | CONSULTATION | CHIRURGIE | MATERNITE |
--                PEDIATRIE | RADIOLOGIE | LABORATOIRE | AUTRE
CREATE TABLE services (
    id_service          BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_etablissement    BIGINT NOT NULL,
    nom                 VARCHAR(100) NOT NULL,
    categorie           ENUM(
                            'URGENCE',
                            'CONSULTATION',
                            'CHIRURGIE',
                            'MATERNITE',
                            'PEDIATRIE',
                            'RADIOLOGIE',
                            'LABORATOIRE',
                            'AUTRE'
                        ) NOT NULL DEFAULT 'CONSULTATION',   -- [A3]
    actif               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_service_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
);

-- Disponibilités hebdomadaires des médecins (L14)
-- ISOLATION : id_medecin + id_etablissement + date_debut_semaine UNIQUE
CREATE TABLE disponibilite_semaine (
    id_disponibilite    BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    date_debut_semaine  DATE NOT NULL,
    date_fin_semaine    DATE NOT NULL,
    duree_creneau_min   INT NOT NULL,               -- 15, 30 ou 60 minutes
    actif               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_dispo_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_dispo_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement),
    CONSTRAINT uq_dispo_semaine UNIQUE (id_medecin, id_etablissement, date_debut_semaine)
);

-- Créneaux générés automatiquement depuis disponibilite_semaine (L14)
-- disponible=false quand réservé, redevient true si RDV annulé (L21)
CREATE TABLE creneau_disponible (
    id_creneau          BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_disponibilite    BIGINT NOT NULL,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    date_creneau        DATE NOT NULL,
    heure_debut         TIME NOT NULL,
    heure_fin           TIME NOT NULL,
    disponible          BOOLEAN NOT NULL DEFAULT TRUE,
    id_rendez_vous      BIGINT UNIQUE,              -- NULL si libre
    CONSTRAINT fk_creneau_dispo FOREIGN KEY (id_disponibilite)
        REFERENCES disponibilite_semaine(id_disponibilite),
    CONSTRAINT fk_creneau_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_creneau_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
    -- fk_creneau_rendez ajoutée après création de rendez_vous (ALTER TABLE ci-dessous)
);

-- Plages horaires par jour pour une semaine déclarée (L14)
-- Chaque jour travaillé peut avoir ses propres heures début/fin
CREATE TABLE jour_travail (
    id_jour_travail   BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_disponibilite  BIGINT NOT NULL,
    jour_semaine      VARCHAR(10) NOT NULL,     -- MONDAY, TUESDAY, ...
    heure_debut       TIME NOT NULL,
    heure_fin         TIME NOT NULL,
    CONSTRAINT fk_jour_dispo FOREIGN KEY (id_disponibilite)
        REFERENCES disponibilite_semaine(id_disponibilite),
    CONSTRAINT uq_jour_dispo UNIQUE (id_disponibilite, jour_semaine)
);

-- Rendez-vous — PRIVÉ par hôpital (L02, L16, L20)
-- [A2] Ajout colonne priorite : NORMAL | URGENT | CRITIQUE (L16)
--      Patient crée toujours en NORMAL — médecin peut changer
CREATE TABLE rendez_vous (
    id_rendez           BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_patient          BIGINT NOT NULL,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    id_service          BIGINT,
    id_creneau          BIGINT UNIQUE,
    motif               VARCHAR(255) NOT NULL,
    date_rendez         DATETIME NOT NULL,
    statut              ENUM(
                            'RDV_DEMANDE',
                            'RDV_CONFIRME',
                            'RDV_ANNULE',
                            'TERMINE'
                        ) NOT NULL DEFAULT 'RDV_DEMANDE',
    priorite            ENUM(
                            'NORMAL',
                            'URGENT',
                            'CRITIQUE'
                        ) NOT NULL DEFAULT 'NORMAL',         -- [A2] L16
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rdv_patient FOREIGN KEY (id_patient)
        REFERENCES patients(id_patient),
    CONSTRAINT fk_rdv_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_rdv_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement),
    CONSTRAINT fk_rdv_service FOREIGN KEY (id_service)
        REFERENCES services(id_service),
    CONSTRAINT fk_rdv_creneau FOREIGN KEY (id_creneau)
        REFERENCES creneau_disponible(id_creneau)
);

-- FK circulaire creneau → rendez_vous ajoutée après les deux tables
ALTER TABLE creneau_disponible
    ADD CONSTRAINT fk_creneau_rendez FOREIGN KEY (id_rendez_vous)
        REFERENCES rendez_vous(id_rendez);

-- [A5] Congés médecin — manquant dans le script original (L19)
-- Statuts : EN_ATTENTE → APPROUVE | REFUSE
-- Si APPROUVE → DisponibiliteService.bloquerCreneauxConge()
CREATE TABLE conges_medecin (
    id_conge            BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    date_debut          DATE NOT NULL,
    date_fin            DATE NOT NULL,
    motif               VARCHAR(255) NOT NULL,
    statut              ENUM(
                            'EN_ATTENTE',
                            'APPROUVE',
                            'REFUSE'
                        ) NOT NULL DEFAULT 'EN_ATTENTE',     -- [A5] L19
    CONSTRAINT fk_conge_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_conge_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement),
    CONSTRAINT chk_conge_dates CHECK (date_fin >= date_debut)
);

-- [A4] Notifications internes — manquant dans le script original (L17)
-- Créées automatiquement par NotificationService
-- à chaque changement de statut RDV, référencement, congé
CREATE TABLE notifications (
    id_notif            BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur      BIGINT NOT NULL,
    message             TEXT NOT NULL,
    lue                 BOOLEAN NOT NULL DEFAULT FALSE,      -- [A4] L17
    date_creation       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type_notif          ENUM(
                            'RDV_NOUVEAU',
                            'RDV_CONFIRME',
                            'RDV_ANNULE',
                            'RDV_TERMINE',
                            'REFERENCEMENT',
                            'CONGE',
                            'CONGE_APPROUVE',
                            'CONGE_REFUSE',
                            'SYSTEM'
                        ) NOT NULL DEFAULT 'SYSTEM',
    CONSTRAINT fk_notif_util FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateurs(id_utilisateur)
);

-- ============================================================
-- GROUPE 3 : TABLES MIXTES
-- (acte privé par hôpital + versé dans le dossier global)
-- ============================================================

-- Consultations — TABLE CLÉ (L02, L05)
-- id_etablissement → acte PRIVÉ de l'hôpital
-- id_dossier       → versé dans le dossier GLOBAL du patient
CREATE TABLE consultations (
    id_consultation     BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_rendez           BIGINT,
    id_dossier          BIGINT NOT NULL,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    notes               TEXT,
    diagnostic          TEXT,
    statut              ENUM(
                            'EN_COURS',
                            'CLOTUREE',
                            'VERSEE_AU_DOSSIER'
                        ) NOT NULL DEFAULT 'EN_COURS',
    date_consultation   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consult_rendez FOREIGN KEY (id_rendez)
        REFERENCES rendez_vous(id_rendez),
    CONSTRAINT fk_consult_dossier FOREIGN KEY (id_dossier)
        REFERENCES dossier_medicals(id_dossier),
    CONSTRAINT fk_consult_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_consult_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
);

-- Ordonnances — liées à une consultation (L04)
-- NOTE: UNIQUE sur id_consultation → 1 ordonnance par consultation
--       Si plusieurs médicaments → lignes_prescription (plusieurs lignes)
CREATE TABLE ordonances (
    id_ordonance        BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_consultation     BIGINT NOT NULL UNIQUE,
    instructions        TEXT,
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ordo_consult FOREIGN KEY (id_consultation)
        REFERENCES consultations(id_consultation)
);

-- Lignes de prescription — détail de chaque médicament (L04)
-- Vérification allergie dans OrdonnanceService.verifierAllergie()
CREATE TABLE lignes_prescription (
    id_ligne            BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_ordonance        BIGINT NOT NULL,
    medicament          VARCHAR(150) NOT NULL,
    dosage              VARCHAR(100) NOT NULL,
    frequence           VARCHAR(100) NOT NULL,
    duree_jours         INT NOT NULL,
    CONSTRAINT fk_ligne_ordo FOREIGN KEY (id_ordonance)
        REFERENCES ordonances(id_ordonance)
);

-- Référenements — transfert patient vers autre hôpital (L06)
-- MIXTE : hôpital source (via consultation) + hôpital destination
CREATE TABLE referenements (
    id_ref              BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_consultation     BIGINT NOT NULL,
    id_etablissement_dest BIGINT NOT NULL,
    id_medecin_dest     BIGINT,
    motif               TEXT NOT NULL,
    statut              ENUM(
                            'EN_ATTENTE',
                            'ACCEPTE',
                            'RETOUR_RECU',
                            'CLOTURE'
                        ) NOT NULL DEFAULT 'EN_ATTENTE',
    fichier_courrier    VARCHAR(255),
    date_ref            DATE NOT NULL DEFAULT (CURRENT_DATE),
    retour              TEXT,
    CONSTRAINT fk_ref_consult FOREIGN KEY (id_consultation)
        REFERENCES consultations(id_consultation),
    CONSTRAINT fk_ref_etab_dest FOREIGN KEY (id_etablissement_dest)
        REFERENCES etablissement_santes(id_etablissement),
    CONSTRAINT fk_ref_medecin_dest FOREIGN KEY (id_medecin_dest)
        REFERENCES medecins(id_medecin)
);

-- ============================================================
-- GROUPE 4 : TABLES DE TRAÇABILITÉ
-- ============================================================

-- Journal d'accès au dossier — traçabilité LECTURE/MODIFICATION (L10)
-- Créé automatiquement par DossierService.ouvrirDossier()
-- Consulté par le SUPER_ADMIN dans son journal
CREATE TABLE acces_dossier (
    id_acces            BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_dossier          BIGINT NOT NULL,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    type_acces          ENUM('LECTURE','MODIFICATION') NOT NULL DEFAULT 'LECTURE',
    motif_acces         VARCHAR(255),
    date_acces          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_acces_dossier FOREIGN KEY (id_dossier)
        REFERENCES dossier_medicals(id_dossier),
    CONSTRAINT fk_acces_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_acces_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
);

-- [A6] Historique des modifications du dossier — manquant (L18)
-- Créé par DossierService.tracerModification() avant chaque modification
-- Trace : quel champ, ancienne valeur, nouvelle valeur, qui, quand
-- Visible par MEDECIN (son patient) et SUPER_ADMIN (tout le réseau)
CREATE TABLE historique_modifications (
    id_histo            BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_dossier          BIGINT NOT NULL,
    id_medecin          BIGINT NOT NULL,
    id_etablissement    BIGINT NOT NULL,
    champ_modifie       VARCHAR(100) NOT NULL,       -- ex: 'diagnostic', 'notes'
    ancienne_valeur     TEXT,
    nouvelle_valeur     TEXT,
    date_modification   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- [A6] L18
    CONSTRAINT fk_histo_dossier FOREIGN KEY (id_dossier)
        REFERENCES dossier_medicals(id_dossier),
    CONSTRAINT fk_histo_medecin FOREIGN KEY (id_medecin)
        REFERENCES medecins(id_medecin),
    CONSTRAINT fk_histo_etab FOREIGN KEY (id_etablissement)
        REFERENCES etablissement_santes(id_etablissement)
);

-- ============================================================
-- [A13] INDEX DE PERFORMANCE
-- Sur toutes les colonnes utilisées dans WHERE et ORDER BY
-- ============================================================

-- Isolation par établissement (L11) — les plus importants
CREATE INDEX idx_util_etab         ON utilisateurs(id_etablissement);
CREATE INDEX idx_rdv_etab          ON rendez_vous(id_etablissement);
CREATE INDEX idx_rdv_medecin       ON rendez_vous(id_medecin);
CREATE INDEX idx_rdv_patient       ON rendez_vous(id_patient);
CREATE INDEX idx_rdv_statut        ON rendez_vous(statut);
CREATE INDEX idx_rdv_priorite      ON rendez_vous(priorite);        -- L16
CREATE INDEX idx_rdv_date          ON rendez_vous(date_rendez);
CREATE INDEX idx_consult_etab      ON consultations(id_etablissement);
CREATE INDEX idx_consult_dossier   ON consultations(id_dossier);
CREATE INDEX idx_consult_statut    ON consultations(statut);
CREATE INDEX idx_creneau_medecin   ON creneau_disponible(id_medecin);
CREATE INDEX idx_creneau_date      ON creneau_disponible(date_creneau);
CREATE INDEX idx_creneau_dispo     ON creneau_disponible(disponible); -- L14
CREATE INDEX idx_notif_util        ON notifications(id_utilisateur);  -- L17
CREATE INDEX idx_notif_lue         ON notifications(lue);
CREATE INDEX idx_conge_medecin     ON conges_medecin(id_medecin);     -- L19
CREATE INDEX idx_conge_statut      ON conges_medecin(statut);
CREATE INDEX idx_histo_dossier     ON historique_modifications(id_dossier); -- L18
CREATE INDEX idx_acces_dossier     ON acces_dossier(id_dossier);      -- L10
CREATE INDEX idx_service_etab      ON services(id_etablissement);     -- L24
CREATE INDEX idx_eu_etab           ON etabli_utilisateurs(id_etablissement); -- L23

-- ============================================================
-- DONNÉES DE TEST — jeu de données complet (20+ enregistrements)
-- ============================================================

-- [A7] Hôpital fictif pour le SUPER_ADMIN (id=1 réservé)
-- Le SUPER_ADMIN doit appartenir à UN établissement même fictif
INSERT INTO etablissement_santes (nom, adresse, type_etablissement, email, telephone) VALUES
('Réseau MediCentral (Siège)',            'Avenue Centrale, Gitega',            'Siège Réseau',          'admin@medicentral.bi', '+257 22 00 0000'),
('Hôpital Universitaire de Gitega',       'Avenue de la Santé, Gitega',         'Hôpital Universitaire', 'contact@hug.bi',       '+257 22 40 1001'),
('Hôpital Prince Louis Rwagasore',        'Boulevard de Bujumbura, Bujumbura',  'Hôpital National',      'contact@hplr.bi',      '+257 22 22 2002'),
('Centre de Santé de Ngozi',              'Rue Principale, Ngozi',              'Centre de Santé',       'contact@csn.bi',       '+257 22 30 3003');
-- Résultat : id 1=Siège, 2=Gitega, 3=Bujumbura, 4=Ngozi

-- Utilisateurs
-- [A8] profil_complete :
--   - SUPER_ADMIN : TRUE (pas de profil supplémentaire à compléter)
--   - ADMIN       : TRUE (créé par SUPER_ADMIN, déjà complet)
--   - MEDECIN     : FALSE → devra compléter à la 1ère connexion (L12)
--   - PATIENT     : FALSE → devra compléter à la 1ère connexion (L12)
INSERT INTO utilisateurs
    (id_etablissement, full_name, email, password_hash, role, actif, profil_complete)
VALUES
-- [A7] SUPER_ADMIN rattaché au siège (id_etablissement=1)
(1, 'Super Administrateur',      'superadmin@medicentral.bi', SHA2('super123',256),   'SUPER_ADMIN', TRUE, TRUE),
-- ADMINs (profil complet — créés par SUPER_ADMIN)
(2, 'Admin Gitega',              'admin@hug.bi',              SHA2('admin123',256),   'ADMIN',       TRUE, TRUE),
(3, 'Admin Bujumbura',           'admin@hplr.bi',             SHA2('admin123',256),   'ADMIN',       TRUE, TRUE),
(4, 'Admin Ngozi',               'admin@csn.bi',              SHA2('admin123',256),   'ADMIN',       TRUE, TRUE),
-- MEDECINs Hôpital Gitega (id=2) — profil_complete=TRUE car données insertées ci-dessous
(2, 'Dr. Jean Ndayishimiye',     'jean.nday@hug.bi',          SHA2('medecin123',256), 'MEDECIN',     TRUE, TRUE),
(2, 'Dr. Marie Hakizimana',      'marie.hak@hug.bi',          SHA2('medecin123',256), 'MEDECIN',     TRUE, TRUE),
-- MEDECINs Hôpital Bujumbura (id=3)
(3, 'Dr. Pierre Nkurunziza',     'pierre.nku@hplr.bi',        SHA2('medecin123',256), 'MEDECIN',     TRUE, TRUE),
(3, 'Dr. Alice Ntakarutimana',   'alice.nta@hplr.bi',         SHA2('medecin123',256), 'MEDECIN',     TRUE, TRUE),
-- MEDECIN Hôpital Ngozi (id=4)
(4, 'Dr. Paul Niyonzima',        'paul.niy@csn.bi',           SHA2('medecin123',256), 'MEDECIN',     TRUE, TRUE),
-- PATIENTs rattachés à Gitega par défaut — profil_complete=TRUE car données ci-dessous
(2, 'Emmanuel Bigirimana',       'emma.bigi@gmail.com',       SHA2('patient123',256), 'PATIENT',     TRUE, TRUE),
(2, 'Claudine Uwimana',          'claud.uwi@gmail.com',       SHA2('patient123',256), 'PATIENT',     TRUE, TRUE),
(2, 'Joseph Nkezabahizi',        'joseph.nke@gmail.com',      SHA2('patient123',256), 'PATIENT',     TRUE, TRUE);
-- Résultat IDs : 1=SuperAdmin, 2=AdminGitega, 3=AdminBujumbura, 4=AdminNgozi,
--                5=DrJean, 6=DrMarie, 7=DrPierre, 8=DrAlice, 9=DrPaul,
--                10=Emmanuel, 11=Claudine, 12=Joseph

-- Patients (profil complété — L12)
INSERT INTO patients (id_utilisateur, numero_patient, date_naissance, sexe, telephone, groupe_sanguin, allergies, adresse) VALUES
(10, 'PAT-2026-00001', '1995-03-14', 'M', '+257 79 111 111', 'A+',  'Pénicilline',   'Quartier Gitega Centre'),
(11, 'PAT-2026-00002', '1988-07-22', 'F', '+257 79 222 222', 'O+',  NULL,            'Quartier Rohero, Bujumbura'),
(12, 'PAT-2026-00003', '2000-11-05', 'M', '+257 79 333 333', 'B+',  'Aspirine',      'Ngozi Centre');
-- Résultat IDs : 1=Emmanuel, 2=Claudine, 3=Joseph

-- Dossiers médicaux centraux (1 par patient — GLOBAL)
INSERT INTO dossier_medicals (id_patient, numero_unique, antecedents) VALUES
(1, 'DOS-2026-00001', 'Diabète type 2 depuis 2020. Hypertension légère.'),
(2, 'DOS-2026-00002', 'Hypertension artérielle. Allergie saisonnière.'),
(3, 'DOS-2026-00003', 'Aucun antécédent connu.');
-- Résultat IDs : 1, 2, 3

-- Médecins (profil complété — L12)
INSERT INTO medecins (id_utilisateur, specialite, experience, numero_ordre) VALUES
(5,  'Médecine Générale', '10 ans', 'OM-2016-001'),  -- id_medecin=1
(6,  'Pédiatrie',         '7 ans',  'OM-2019-002'),  -- id_medecin=2
(7,  'Cardiologie',       '12 ans', 'OM-2014-003'),  -- id_medecin=3
(8,  'Gynécologie',       '8 ans',  'OM-2018-004'),  -- id_medecin=4
(9,  'Chirurgie',         '15 ans', 'OM-2011-005');  -- id_medecin=5

-- Affectations médecins-hôpitaux (PRIVÉES par hôpital)
INSERT INTO etabli_utilisateurs (id_medecin, id_etablissement, role_dans_hopital, actif) VALUES
(1, 2, 'Médecin Chef',    TRUE),   -- DrJean → Gitega
(2, 2, 'Pédiatre',        TRUE),   -- DrMarie → Gitega
(3, 3, 'Cardiologue',     TRUE),   -- DrPierre → Bujumbura
(4, 3, 'Gynécologue',     TRUE),   -- DrAlice → Bujumbura
(5, 4, 'Chirurgien Chef', TRUE),   -- DrPaul → Ngozi
(1, 3, 'Consultant',      TRUE);   -- DrJean consulte aussi à Bujumbura

-- Services par hôpital (PRIVÉS — L24)
-- [A3] categorie est maintenant ENUM
INSERT INTO services (id_etablissement, nom, categorie, actif) VALUES
(2, 'Médecine Générale', 'CONSULTATION', TRUE),  -- id=1
(2, 'Urgences Gitega',   'URGENCE',      TRUE),  -- id=2
(2, 'Pédiatrie',         'PEDIATRIE',    TRUE),  -- id=3
(3, 'Cardiologie',       'CONSULTATION', TRUE),  -- id=4
(3, 'Gynécologie',       'MATERNITE',    TRUE),  -- id=5
(3, 'Urgences Bujumbura','URGENCE',      TRUE),  -- id=6
(4, 'Chirurgie',         'CHIRURGIE',    TRUE),  -- id=7
(4, 'Médecine Générale', 'CONSULTATION', TRUE);  -- id=8

-- Disponibilités médecins (L14)
INSERT INTO disponibilite_semaine
    (id_medecin, id_etablissement, date_debut_semaine, date_fin_semaine, duree_creneau_min)
VALUES
(1, 2, '2026-05-18', '2026-05-24', 30),   -- DrJean à Gitega — semaine courante
(2, 2, '2026-05-18', '2026-05-24', 30),   -- DrMarie à Gitega
(3, 3, '2026-05-18', '2026-05-24', 60),   -- DrPierre à Bujumbura (créneaux 1h)
(1, 3, '2026-05-18', '2026-05-24', 30);   -- DrJean consultant à Bujumbura

-- Plages horaires par jour pour les semaines ci-dessus
INSERT INTO jour_travail (id_disponibilite, jour_semaine, heure_debut, heure_fin) VALUES
(1, 'MONDAY',    '08:00:00', '17:00:00'),
(1, 'TUESDAY',   '08:00:00', '17:00:00'),
(1, 'WEDNESDAY', '08:00:00', '17:00:00'),
(1, 'THURSDAY',  '08:00:00', '17:00:00'),
(1, 'FRIDAY',    '08:00:00', '17:00:00'),
(2, 'MONDAY',    '09:00:00', '16:00:00'),
(2, 'TUESDAY',   '09:00:00', '16:00:00'),
(2, 'WEDNESDAY', '09:00:00', '16:00:00'),
(2, 'THURSDAY',  '09:00:00', '16:00:00'),
(2, 'FRIDAY',    '09:00:00', '16:00:00'),
(3, 'MONDAY',    '08:00:00', '12:00:00'),
(3, 'WEDNESDAY', '14:00:00', '18:00:00'),
(3, 'FRIDAY',    '08:00:00', '17:00:00'),
(4, 'TUESDAY',   '08:00:00', '17:00:00'),
(4, 'THURSDAY',  '08:00:00', '12:00:00');

-- Créneaux disponibles (L14) — quelques exemples
INSERT INTO creneau_disponible
    (id_disponibilite, id_medecin, id_etablissement, date_creneau, heure_debut, heure_fin, disponible)
VALUES
(1, 1, 2, '2026-05-20', '08:00:00', '08:30:00', TRUE),
(1, 1, 2, '2026-05-20', '08:30:00', '09:00:00', FALSE),  -- réservé
(1, 1, 2, '2026-05-20', '09:00:00', '09:30:00', TRUE),
(1, 1, 2, '2026-05-21', '08:00:00', '08:30:00', TRUE),
(2, 2, 2, '2026-05-20', '10:00:00', '10:30:00', TRUE),
(2, 2, 2, '2026-05-20', '10:30:00', '11:00:00', TRUE),
(3, 3, 3, '2026-05-20', '14:00:00', '15:00:00', TRUE),
(3, 3, 3, '2026-05-21', '14:00:00', '15:00:00', FALSE);  -- réservé

-- Rendez-vous (PRIVÉS par hôpital — L02, L16)
-- [A9] priorite ajoutée
INSERT INTO rendez_vous
    (id_patient, id_medecin, id_etablissement, id_service, id_creneau, motif, date_rendez, statut, priorite)
VALUES
-- Emmanuel à Gitega — TERMINE
(1, 1, 2, 1, NULL, 'Contrôle diabète',        '2026-01-10 09:00:00', 'TERMINE',      'NORMAL'),
-- Claudine à Gitega — TERMINE
(2, 2, 2, 3, NULL, 'Consultation pédiatrie',  '2026-02-15 10:30:00', 'TERMINE',      'NORMAL'),
-- Emmanuel à Bujumbura — TERMINE
(1, 3, 3, 4, NULL, 'Douleurs cardiaques',     '2026-03-05 14:00:00', 'TERMINE',      'URGENT'),
-- Joseph à Ngozi — RDV_CONFIRME (en cours)
(3, 5, 4, 7, NULL, 'Consultation chirurgie',  '2026-05-25 08:00:00', 'RDV_CONFIRME', 'NORMAL'),
-- Emmanuel à Gitega — RDV_DEMANDE sur créneau id=2 (disponible=FALSE ci-dessus)
(1, 1, 2, 1, 2,    'Suivi diabète mensuel',   '2026-05-20 08:30:00', 'RDV_DEMANDE',  'NORMAL'),
-- Claudine à Bujumbura — RDV_DEMANDE (CRITIQUE — palpitations sévères)
(2, 3, 3, 4, 8,    'Palpitations sévères',    '2026-05-21 14:00:00', 'RDV_DEMANDE',  'CRITIQUE');
-- IDs rdv : 1, 2, 3, 4, 5, 6

-- Consultations (MIXTES — L02, L05)
INSERT INTO consultations
    (id_rendez, id_dossier, id_medecin, id_etablissement, notes, diagnostic, statut, date_consultation)
VALUES
-- Consultation Emmanuel à Gitega → DOS-2026-00001
(1, 1, 1, 2, 'Glycémie à 1.8 g/L. Patient peu observant.', 'Diabète déséquilibré — ajuster traitement', 'VERSEE_AU_DOSSIER', '2026-01-10 09:30:00'),
-- Consultation Claudine à Gitega → DOS-2026-00002
(2, 2, 2, 2, 'Enfant en bonne santé. Poids correct.',       'RAS — vaccins à jour',                      'VERSEE_AU_DOSSIER', '2026-02-15 11:00:00'),
-- Consultation Emmanuel à Bujumbura → MÊME DOS-2026-00001 (inter-établissement L05)
(3, 1, 3, 3, 'Palpitations depuis 3 mois. ECG anormal.',    'Arythmie légère — surveillance recommandée', 'VERSEE_AU_DOSSIER', '2026-03-05 14:30:00');
-- IDs consultations : 1, 2, 3

-- Ordonnances
INSERT INTO ordonances (id_consultation, instructions) VALUES
(1, 'Prendre les médicaments le matin à jeun. Contrôle glycémie hebdomadaire.'),
(3, 'Éviter les efforts physiques intenses. Repos 15 jours.');

-- Lignes de prescription (L04 — vérification allergie sur Pénicilline)
INSERT INTO lignes_prescription (id_ordonance, medicament, dosage, frequence, duree_jours) VALUES
(1, 'Metformine',   '500mg',  '2 fois par jour', 30),
(1, 'Glibenclamide','5mg',    '1 fois par jour', 30),
(2, 'Bisoprolol',   '2.5mg',  '1 fois par jour', 60),
(2, 'Magnésium',    '400mg',  '1 fois le soir',  30);

-- Référenement (L06) — Gitega → Bujumbura pour Emmanuel
INSERT INTO referenements
    (id_consultation, id_etablissement_dest, id_medecin_dest, motif, statut, fichier_courrier, retour)
VALUES
(1, 3, 3, 'Arythmie détectée — avis cardiologue nécessaire',
   'RETOUR_RECU', 'courrier_ref_001.pdf',
   'Arythmie légère confirmée. Traitement Bisoprolol initié. Surveillance à 2 mois.');

-- [A11] Congés médecin (L19)
INSERT INTO conges_medecin (id_medecin, id_etablissement, date_debut, date_fin, motif, statut) VALUES
(2, 2, '2026-06-01', '2026-06-14', 'Congé annuel',          'EN_ATTENTE'),  -- DrMarie demande congé
(1, 2, '2026-07-15', '2026-07-22', 'Formation continue',    'APPROUVE'),    -- DrJean congé approuvé
(3, 3, '2026-05-25', '2026-05-28', 'Congé maladie urgence', 'REFUSE');      -- DrPierre refusé

-- Journal d'accès au dossier (L10)
INSERT INTO acces_dossier (id_dossier, id_medecin, id_etablissement, type_acces) VALUES
(1, 1, 2, 'LECTURE'),       -- DrJean (Gitega) lit dossier Emmanuel
(1, 3, 3, 'LECTURE'),       -- DrPierre (Bujumbura) lit dossier Emmanuel
(1, 3, 3, 'MODIFICATION'),  -- DrPierre ajoute sa consultation
(2, 2, 2, 'LECTURE'),       -- DrMarie lit dossier Claudine
(1, 1, 3, 'LECTURE');       -- DrJean consulte depuis Bujumbura (consultant)

-- [A12] Historique des modifications du dossier (L18)
INSERT INTO historique_modifications
    (id_dossier, id_medecin, id_etablissement, champ_modifie, ancienne_valeur, nouvelle_valeur)
VALUES
(1, 3, 3, 'diagnostic',
   'En attente',
   'Arythmie légère — surveillance recommandée'),
(1, 3, 3, 'notes',
   NULL,
   'Palpitations depuis 3 mois. ECG anormal.'),
(1, 1, 2, 'antecedents',
   'Diabète type 2 depuis 2020.',
   'Diabète type 2 depuis 2020. Hypertension légère.');

-- [A10] Notifications (L17)
INSERT INTO notifications (id_utilisateur, message, lue, type_notif) VALUES
-- Notifications médecin (id_util=5 = DrJean)
(5,  'Nouveau RDV demandé par Emmanuel Bigirimana — 20/05/2026 08h30',              FALSE, 'RDV_NOUVEAU'),
(5,  'RDV annulé par Claudine Uwimana — créneau libéré',                            TRUE,  'RDV_ANNULE'),
-- Notification médecin (id_util=7 = DrPierre)
(7,  'CRITIQUE : Claudine Uwimana — Palpitations sévères — RDV demandé',            FALSE, 'RDV_NOUVEAU'),
-- Notifications patient (id_util=10 = Emmanuel)
(10, 'Votre RDV du 20/05/2026 avec Dr. Jean Ndayishimiye est en attente de confirmation', FALSE, 'RDV_NOUVEAU'),
(10, 'Nouveau référencement reçu vers Hôpital Prince Louis Rwagasore',              TRUE,  'REFERENCEMENT'),
-- Notification patient (id_util=12 = Joseph)
(12, 'Votre RDV du 25/05/2026 avec Dr. Paul Niyonzima est confirmé',                FALSE, 'RDV_CONFIRME'),
-- Notification admin (id_util=2 = AdminGitega)
(2,  'Demande de congé de Dr. Marie Hakizimana du 01/06 au 14/06 — action requise', FALSE, 'CONGE');

-- ============================================================
-- VUES UTILES POUR L'APPLICATION
-- ============================================================

-- Vue 1 : RDV par hôpital (PRIVÉ — filtrer par id_etablissement)
-- Usage : WHERE id_etablissement = :idEtab dans AdminServlet / MedecinServlet
CREATE VIEW vue_rdv_par_hopital AS
SELECT
    r.id_rendez,
    r.date_rendez,
    r.motif,
    r.statut,
    r.priorite,                                        -- [A2] L16
    r.id_etablissement,
    e.nom                   AS nom_hopital,
    p.numero_patient,
    u_patient.full_name     AS nom_patient,
    u_medecin.full_name     AS nom_medecin,
    m.specialite,
    s.nom                   AS nom_service
FROM rendez_vous r
JOIN patients p             ON r.id_patient       = p.id_patient
JOIN utilisateurs u_patient ON p.id_utilisateur   = u_patient.id_utilisateur
JOIN medecins m             ON r.id_medecin        = m.id_medecin
JOIN utilisateurs u_medecin ON m.id_utilisateur    = u_medecin.id_utilisateur
JOIN etablissement_santes e ON r.id_etablissement  = e.id_etablissement
LEFT JOIN services s        ON r.id_service        = s.id_service;

-- Vue 2 : Dossier médical complet d'un patient (GLOBAL — tous hôpitaux)
-- Usage : WHERE p.numero_patient = :num dans DossierService
-- IMPORTANT : aucun filtre id_etablissement — L05, L11 exception
CREATE VIEW vue_dossier_complet AS
SELECT
    p.numero_patient,
    u.full_name             AS nom_patient,
    p.groupe_sanguin,
    p.allergies,
    p.date_naissance,
    p.sexe,
    d.numero_unique         AS numero_dossier,
    d.antecedents,
    d.date_mise_jour,
    c.id_consultation,
    c.date_consultation,
    c.diagnostic,
    c.notes,
    c.statut                AS statut_consultation,
    e.nom                   AS hopital_consultation,
    u_med.full_name         AS nom_medecin,
    m.specialite
FROM dossier_medicals d
JOIN patients p             ON d.id_patient        = p.id_patient
JOIN utilisateurs u         ON p.id_utilisateur    = u.id_utilisateur
LEFT JOIN consultations c   ON d.id_dossier        = c.id_dossier
    AND c.statut = 'VERSEE_AU_DOSSIER'              -- seulement les consultations versées
LEFT JOIN medecins m        ON c.id_medecin         = m.id_medecin
LEFT JOIN utilisateurs u_med ON m.id_utilisateur   = u_med.id_utilisateur
LEFT JOIN etablissement_santes e ON c.id_etablissement = e.id_etablissement
ORDER BY c.date_consultation DESC;

-- Vue 3 : Médecins actifs d'un hôpital (PRIVÉ)
-- Usage : WHERE eu.id_etablissement = :idEtab dans AdminServlet (L23)
CREATE VIEW vue_medecins_par_hopital AS
SELECT
    m.id_medecin,
    u.full_name             AS nom_medecin,
    u.email,
    u.actif                 AS compte_actif,
    u.derniere_connexion,
    m.specialite,
    m.experience,
    m.numero_ordre,
    eu.role_dans_hopital,
    eu.id_etablissement,
    eu.date_affectation,
    e.nom                   AS nom_hopital,
    eu.actif                AS affectation_active
FROM medecins m
JOIN utilisateurs u         ON m.id_utilisateur    = u.id_utilisateur
JOIN etabli_utilisateurs eu ON m.id_medecin        = eu.id_medecin
JOIN etablissement_santes e ON eu.id_etablissement = e.id_etablissement;

-- [A14] Vue 4 : Détail médecin avec statistiques (L23 — Admin voit détail)
-- Usage : WHERE m.id_medecin = :id AND eu.id_etablissement = :idEtab
CREATE VIEW vue_medecins_detail AS
SELECT
    m.id_medecin,
    u.id_utilisateur,
    u.full_name             AS nom_medecin,
    u.email,
    u.actif                 AS compte_actif,
    u.profil_complete,
    u.derniere_connexion,
    m.specialite,
    m.experience,
    m.numero_ordre,
    eu.role_dans_hopital,
    eu.id_etablissement,
    eu.date_affectation,
    eu.actif                AS affectation_active,
    COUNT(DISTINCT r.id_rendez)    AS total_rdv,
    COUNT(DISTINCT c.id_consultation) AS total_consultations
FROM medecins m
JOIN utilisateurs u         ON m.id_utilisateur    = u.id_utilisateur
JOIN etabli_utilisateurs eu ON m.id_medecin        = eu.id_medecin
LEFT JOIN rendez_vous r     ON m.id_medecin        = r.id_medecin
    AND r.id_etablissement  = eu.id_etablissement
LEFT JOIN consultations c   ON m.id_medecin        = c.id_medecin
    AND c.id_etablissement  = eu.id_etablissement
GROUP BY
    m.id_medecin, u.id_utilisateur, u.full_name, u.email,
    u.actif, u.profil_complete, u.derniere_connexion,
    m.specialite, m.experience, m.numero_ordre,
    eu.role_dans_hopital, eu.id_etablissement,
    eu.date_affectation, eu.actif;

-- [A15] Vue 5 : Statistiques par établissement (L08 — Dashboard Admin)
-- Usage : WHERE id_etablissement = :idEtab dans EtablissementService
CREATE VIEW vue_stats_etablissement AS
SELECT
    e.id_etablissement,
    e.nom                                               AS nom_hopital,
    COUNT(DISTINCT eu.id_medecin)                       AS total_medecins_actifs,
    COUNT(DISTINCT r.id_rendez)                         AS total_rdv,
    COUNT(DISTINCT CASE WHEN r.statut = 'RDV_DEMANDE'
                        THEN r.id_rendez END)           AS rdv_en_attente,
    COUNT(DISTINCT CASE WHEN r.statut = 'RDV_CONFIRME'
                        THEN r.id_rendez END)           AS rdv_confirmes,
    COUNT(DISTINCT CASE WHEN r.date_rendez >= CURDATE()
                          AND r.statut != 'RDV_ANNULE'
                        THEN r.id_rendez END)           AS rdv_a_venir,
    COUNT(DISTINCT c.id_consultation)                   AS total_consultations,
    COUNT(DISTINCT CASE WHEN c.statut = 'VERSEE_AU_DOSSIER'
                        THEN c.id_consultation END)     AS consultations_versees,
    COUNT(DISTINCT s.id_service)                        AS total_services_actifs,
    COUNT(DISTINCT cg.id_conge)                         AS conges_en_attente
FROM etablissement_santes e
LEFT JOIN etabli_utilisateurs eu ON e.id_etablissement = eu.id_etablissement
    AND eu.actif = TRUE
LEFT JOIN rendez_vous r     ON e.id_etablissement      = r.id_etablissement
LEFT JOIN consultations c   ON e.id_etablissement      = c.id_etablissement
LEFT JOIN services s        ON e.id_etablissement      = s.id_etablissement
    AND s.actif = TRUE
LEFT JOIN conges_medecin cg ON e.id_etablissement      = cg.id_etablissement
    AND cg.statut = 'EN_ATTENTE'
GROUP BY e.id_etablissement, e.nom;

-- ============================================================
-- AUDIT LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id_audit BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur BIGINT NULL,
    nom_utilisateur VARCHAR(255) NOT NULL,
    role_utilisateur VARCHAR(50) NOT NULL,
    id_etablissement BIGINT NULL,
    nom_etablissement VARCHAR(255) NULL,
    action VARCHAR(255) NOT NULL,
    module VARCHAR(100) NOT NULL,
    niveau VARCHAR(20) NOT NULL DEFAULT 'INFO',
    cible_type VARCHAR(50) NULL,
    cible_id BIGINT NULL,
    description TEXT NULL,
    adresse_ip VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    date_action DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_date (date_action),
    INDEX idx_audit_utilisateur (id_utilisateur),
    INDEX idx_audit_etablissement (id_etablissement),
    INDEX idx_audit_module (module),
    INDEX idx_audit_niveau (niveau),
    INDEX idx_audit_cible (cible_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- HISTORIQUE RDV
-- ============================================================
CREATE TABLE IF NOT EXISTS historique_rdv (
    id_histo_rdv BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_rendez BIGINT NOT NULL,
    ancien_statut VARCHAR(50) NULL,
    nouveau_statut VARCHAR(50) NOT NULL,
    modifie_par VARCHAR(50) NOT NULL,
    id_modificateur BIGINT NULL,
    date_modification DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_histo_rdv_rendez (id_rendez),
    INDEX idx_histo_rdv_date (date_modification),
    CONSTRAINT fk_histo_rdv_rendez FOREIGN KEY (id_rendez) REFERENCES rendez_vous(id_rendez) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- FIN DU SCRIPT — MediCentral v2.0
-- ============================================================
--
--  RAPPEL SECURITE POUR LES EJB :
--
--  REGLE 1 — Données PRIVÉES : TOUJOURS filtrer
--    "SELECT r FROM RendezVous r
--     WHERE r.etablissement.id = :idEtab"
--
--  REGLE 2 — Dossier médical : JAMAIS filtrer
--    "SELECT d FROM DossierMedical d
--     WHERE d.patient.numeroPatient = :num"
--
--  REGLE 3 — Profil propre (L25) : id depuis SESSION uniquement
--    Long id = (Long) session.getAttribute("id_utilisateur");
--    JAMAIS : Long id = Long.parseLong(request.getParameter("id"));
--
--  REGLE 4 — CRUD médecins (L23) : vérifier id_etablissement
--    "SELECT m FROM Medecin m JOIN m.affectations eu
--     WHERE m.id = :id AND eu.etablissement.id = :idEtab"
--
-- ============================================================
