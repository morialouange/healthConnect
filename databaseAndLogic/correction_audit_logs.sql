-- Correction : `nom_utilisateur` et `role_utilisateur` étaient NOT NULL
-- mais les audits échoués peuvent ne pas avoir d'utilisateur associé.
ALTER TABLE audit_logs
    MODIFY COLUMN nom_utilisateur VARCHAR(255) NULL,
    MODIFY COLUMN role_utilisateur VARCHAR(50) NULL;
