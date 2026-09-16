<div align="center">

# 🏥 BurundiHealthConnect — MediCentral

**Système de Centralisation des Dossiers Médicaux — plateforme SaaS multi-hôpitaux**

[![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-176FA3)](https://jakarta.ee)
[![GlassFish](https://img.shields.io/badge/GlassFish-7-0A6EBD)](https://glassfish.org)
[![MySQL](https://img.shields.io/badge/MySQL-8-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com)
[![Maven](https://img.shields.io/badge/Maven-3-C71A36?logo=apache-maven&logoColor=white)](https://maven.apache.org)



</div>

---

## 🧭 À propos

**BurundiHealthConnect** est une plateforme **multi-tenant** de centralisation des dossiers médicaux pour un réseau d'établissements de santé. Elle couvre l'ensemble du parcours de soins : prise de rendez-vous, consultations, prescriptions avec alerte d'allergie, transferts de patients inter-hôpitaux et suivi d'un dossier médical centralisé sur tout le réseau.

La donnée se gère selon deux logiques complémentaires :
- **Privée par établissement (tenant)** : rendez-vous, médecins, services, disponibilités…
- **Globale réseau** : le dossier médical du patient reste consultable par tout médecin du réseau, où qu'il exerce, pour assurer la continuité des soins.

Chaque action est tracée (audit, journal d'accès, historique) et un tableau de bord dédié est fourni pour chaque rôle.

---

## ✨ Fonctionnalités

**Super Admin**
- Gestion des établissements du réseau (création, modification, activation)
- Gestion des administrateurs d'hôpitaux
- Tableau de bord réseau, statistiques et piste d'audit globale

**Admin d'établissement**
- Gestion des médecins (création de compte, détail, modification, désactivation)
- Gestion des services hospitaliers (catégories, suppression logique)
- Validation des congés, suivi des référencements, rapports mensuels

**Médecin**
- Rendez-vous (confirmation, refus, clôture, priorités)
- Disponibilités hebdomadaires et génération automatique des créneaux
- Consultations et ordonnances multi-lignes avec alerte d'allergie
- Dossier médical du patient et historique inter-hôpitaux (recherche par numéro)
- Référencements de patients, demandes de congés

**Patient**
- Inscription en deux temps (compte puis profil médical)
- Prise de rendez-vous en 3 étapes : hôpital → médecin → créneau
- Suivi et annulation de rendez-vous
- Dossier médical personnel, timeline médicale et notifications

---

## 🧩 Architecture

Projet **Maven multi-modules** : un cœur métier réutilisable (JAR) et une couche de présentation (WAR).

```
Navigateur Web
      │ HTTP
      ▼
┌─────────────────────────────────────────────┐
│  burundihealthconnect-web  (WAR)            │
│  Servlets · JSP/JSTL · Filtres de sécurité  │
└────────────────────┬────────────────────────┘
                     │ CDI @Inject
┌────────────────────▼────────────────────────┐
│  burundihealthconnect-core  (JAR)           │
│  EJB Stateless · Entités JPA · Exceptions   │
└────────────────────┬────────────────────────┘
                     │ JPA (JTA)
┌────────────────────▼────────────────────────┐
│  MySQL 8 — burundihealthconnect_db          │
└─────────────────────────────────────────────┘
```

| Module | Type | Rôle |
|---|---|---|
| `burundihealthconnect-core` | JAR | 21 entités JPA, 17 EJB Stateless, exceptions métier, utilitaires (bcrypt, clés de session) |
| `burundihealthconnect-web` | WAR | 8 servlets, 3 filtres, vues JSP (JSTL, zéro scriptlet), i18n, design system |

Points clés :
- **Isolation multi-tenant** : instance unique, données filtrées par `id_etablissement` (session → EJB → requêtes JPQL)
- **Transactions JTA** avec rollback automatique sur exception métier
- **Pagination** systématique (10 éléments/page) et recherche par mots-clés
- **Sécurité** : bcrypt, contrôle d'accès applicatif par rôle
- **Schéma de données** géré exclusivement par script SQL (`schema-generation = none`)

---

## 👥 Rôles

| Rôle | Périmètre | Espace |
|---|---|---|
| `SUPER_ADMIN` | Tout le réseau : établissements, admins, audits, statistiques | `/superadmin/*` |
| `ADMIN` | Son établissement : médecins, services, congés, rapports | `/admin/*` |
| `MEDECIN` | Son activité : RDV, consultations, ordonnances, dossiers | `/medecin/*` |
| `PATIENT` | Son profil : RDV, dossier, notifications | `/patient/*` |

---

## 📂 Structure du dépôt

```
ProjetJakarta/
├── pom.xml                              # Parent Maven (réacteur core + web)
├── burundihealthconnect-core/           # Backend (JAR)
│   └── src/main/java/com/burundihealthconnect/
│       ├── entity/                      # Entités JPA + enums
│       ├── ejb/                         # Services métier (EJB Stateless)
│       ├── exception/                   # Exceptions métier
│       └── util/                        # PasswordHasher, SessionKeys
├── burundihealthconnect-web/            # Frontend (WAR)
│   └── src/main/
│       ├── java/com/burundihealthconnect/
│       │   ├── servlet/                 # Servlets + ServletUtils
│       │   └── filter/                  # Filtres (sécurité, locale, cache)
│       └── webapp/
│           ├── WEB-INF/views/           # Vues JSP par rôle
│           ├── resources/               # CSS, fonts, Chart.js, Lucide
│           └── accueil.jsp              # Page publique de présentation
├── databaseAndLogic/                    # Script SQL et modélisation
└── DesignAndResponsive/                 # Maquettes et supports design
```

---

## 🚀 Démarrage rapide

**Prérequis** : JDK 17, Maven 3.8+, GlassFish 7, MySQL 8.

```bash
# 1. Compiler
mvn clean install

# 2. Créer la base et appliquer le schéma (avec les données de test)
mysql -u root -p burundihealthconnect_db < databaseAndLogic/medicentral_script_v2.sql

# 3. Configurer sur GlassFish : pool JDBC + ressource JNDI jdbc/BHCDataSource

# 4. Déployer
asadmin start-domain domain1
asadmin deploy --force burundihealthconnect-web/target/burundihealthconnect.war
```

Application accessible sur `http://localhost:8080/burundihealthconnect`.

---

## 🛠 Technologies

| Domaine | Technologie |
|---|---|
| Langage | Java 17 |
| Plateforme | Jakarta EE 10 — EJB, JPA 3.0, CDI 4.0, Servlet 6.0 |
| Serveur | GlassFish 7 |
| Base de données | MySQL 8 (InnoDB, utf8mb4) |
| Build | Maven 3 |
| Présentation | Servlets, JSP + JSTL, EL (zéro scriptlet) |
| Sécurité | jBCrypt, CSRF, contrôle d'accès applicatif |
| Frontend | Design system CSS custom, Chart.js, Lucide |
| Tests | JUnit 5, Mockito |

---

