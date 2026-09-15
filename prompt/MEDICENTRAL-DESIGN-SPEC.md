# MEDICENTRAL — SPÉCIFICATION DE DESIGN (sans code, à donner à l'agent)

> Ce fichier décrit intégralement le design de MediCentral : couleurs, typographie,
> boutons, badges, cartes, tableaux, formulaires, disposition de l'écran (sidebar/topbar),
> mode sombre, graphiques. L'agent doit **écrire lui-même** le CSS/JS/JSP à partir de
> cette spécification, en respectant les contraintes du projet (voir §0).

---

## 0. CONTRAINTES DU PROJET (à respecter par l'agent)

MediCentral est une appli Jakarta EE : Servlet + JSP + JSTL + EJB + JPA + CDI, GlassFish 7.
- Aucun scriptlet Java dans les JSP → uniquement JSTL (`c:forEach`, `c:if`, `c:choose`) + EL.
- Aucun framework front (React/Vue/htmx/Alpine), aucune lib de composants.
- Aucun REST/JSON entre client et serveur.
- Le design doit donc être implémenté en **CSS pur + JS natif (vanilla)**, sans dépendance,
  hormis une police web optionnelle et, si besoin de graphiques, une lib de rendu canvas
  simple (type Chart.js) — pas un framework applicatif.
- 4 rôles à distinguer visuellement : `SUPER_ADMIN`, `ADMIN`, `MEDECIN`, `PATIENT`.

---

## 1. IDENTITÉ VISUELLE

Univers : réseau d'hôpitaux, dossiers médicaux partagés, traçabilité stricte. Le design doit
transmettre confiance clinique (sobre, jamais criard), lisibilité immédiate des statuts, et
un traitement visuel distinct pour les identifiants officiels (numéro de patient, numéro de
dossier). Couleur de marque : un **teal clinique**, plus adapté au sujet qu'un violet SaaS
générique. Signe distinctif maison : une fine **ligne de pouls (ECG)**, utilisée une seule
fois par écran (sous un titre de page, ou sur l'écran de connexion) — jamais en texture répétée.

---

## 2. PALETTE DE COULEURS

### 2.1 Couleurs de base
| Rôle | Mode clair | Mode sombre |
|---|---|---|
| Fond de page | `#F6F9F8` | `#0A1614` |
| Surface (cartes, panneaux) | `#FFFFFF` | `#10201D` |
| Surface alternative (zébrures, sections secondaires) | `#EEF4F2` | `#16302B` |
| Bordure | `#DCE7E4` | `#1F3A34` |
| Texte principal | `#10221F` | `#E7F3F0` |
| Texte secondaire | `#4B615D` | `#A9C4BE` |
| Texte discret (placeholders, métadonnées) | `#7C8F8B` | `#74928C` |

### 2.2 Couleur de marque (primary)
| | Mode clair | Mode sombre |
|---|---|---|
| Primary | `#0F6B63` | `#2FBFA8` |
| Primary hover | `#0B5750` | `#3FD1B9` |
| Primary active | `#084039` | `#1F9C89` |
| Primary soft (fond doux) | `#E3F1EE` | `#12332C` |

Usage : boutons principaux, lien actif de la sidebar, focus des champs, en-têtes de section.

### 2.3 Couleur secondaire (accent)
| | Mode clair | Mode sombre |
|---|---|---|
| Accent (liens, info) | `#2563EB` | `#5B8DEF` |
| Accent soft | `#E8EFFD` | `#16233C` |

### 2.4 Couleurs de statut métier
Ces couleurs correspondent directement aux ENUM `statut` et `priorite` de la base de données.

| Statut / usage | Mode clair (couleur / fond) | Mode sombre (couleur / fond) |
|---|---|---|
| Succès — `RDV_CONFIRME`, `APPROUVE`, `ACCEPTE`, `TERMINE` | `#16A34A` / `#E6F6EA` | `#34D399` / `#123328` |
| Attente — `RDV_DEMANDE`, `EN_ATTENTE` | `#D97706` / `#FDF1E0` | `#FBBF24` / `#332707` |
| Erreur / refus — `RDV_ANNULE`, `REFUSE` | `#DC2626` / `#FCE8E8` | `#F87171` / `#3A1414` |
| Priorité CRITIQUE | `#9F1239` / `#FBE4EA` | `#FB7185` / `#3A121C` |
| Priorité URGENT | `#EA580C` / `#FEEFE6` | `#FB923C` / `#331C0C` |
| Priorité NORMAL / neutre | `#64748B` / `#EEF1F4` | `#94A3B8` / `#1E2530` |

### 2.5 Couleurs de rôle
| Rôle | Mode clair | Mode sombre |
|---|---|---|
| SUPER_ADMIN | `#7C3AED` / fond `#F1EAFE` | `#A78BFA` / fond `#241C3D` |
| ADMIN | `#0F6B63` / fond `#E3F1EE` | `#2FBFA8` / fond `#12332C` |
| MEDECIN | `#2563EB` / fond `#E8EFFD` | `#5B8DEF` / fond `#16233C` |
| PATIENT | `#D97706` / fond `#FDF1E0` | `#FBBF24` / fond `#332707` |

Le PATIENT reçoit volontairement une couleur chaude (ambre) : c'est le seul rôle grand public,
il doit paraître accueillant plutôt que clinique-froid.

---

## 3. TYPOGRAPHIE

| Rôle | Police | Usage |
|---|---|---|
| Display | **Sora**, graisses 600/700 | Titres de page, logo de la sidebar, titres de carte |
| Corps de texte | **Inter**, graisses 400/500/600 | Paragraphes, labels, boutons, contenu de tableau |
| Data / identifiants | **JetBrains Mono**, graisses 400/500 | numéro_patient, numéro_dossier, numéro d'ordonnance, dates d'audit, tout ID |

La police mono sur les identifiants est le détail qui donne le côté "officiel" : un numéro de
dossier en chasse fixe se lit comme un identifiant tamponné, jamais confondu avec du texte narratif.

### Échelle typographique
| Élément | Taille | Graisse | Police |
|---|---|---|---|
| Titre de page (H1) | 1.875rem | 700 | Sora |
| Titre de section/carte (H2) | 1.375rem | 700 | Sora |
| Sous-titre (H3) | 1.125rem | 600 | Sora |
| Corps de texte | 0.9375rem | 400 | Inter |
| Label de formulaire | 0.8125rem | 600 | Inter |
| Texte discret / légende | 0.8125rem | 400 | Inter |
| Donnée / identifiant | 0.875rem | 500 | JetBrains Mono |

---

## 4. ÉCHELLES D'ESPACEMENT, RAYONS, OMBRES

- Espacements : 4 / 8 / 12 / 16 / 24 / 32 / 48 px — utilisés pour tout padding/margin, du plus
  petit (icônes, badges) au plus grand (sections de page).
- Rayons : petit 6px (champs de saisie fins), moyen 10px (boutons, champs), grand 16px (cartes),
  pilule 999px (badges, boutons "toggle").
- Ombres : très légère pour les cartes au repos, moyenne pour les éléments flottants (menus,
  notifications), forte réservée aux modales — jamais d'ombre lourde/portée sur les boutons.

---

## 5. BOUTONS

- **Bouton principal** : fond teal (`primary`), texte blanc, coins moyens, utilisé pour LA
  seule action principale d'un écran (ex. "Confirmer le RDV", "Enregistrer").
- **Bouton secondaire** : contour teal, fond transparent, texte teal, fond teinté au survol —
  pour les actions secondaires ("Modifier", "Voir le détail").
- **Bouton discret (ghost)** : sans contour, texte gris secondaire, fond gris clair au survol —
  pour les actions mineures ("Annuler", "Fermer").
- **Bouton danger** : fond rouge, texte blanc — pour désactiver/supprimer/refuser
  (désactiver un médecin, refuser un congé, annuler un RDV).
- **Bouton succès** : fond vert, texte blanc — pour valider/confirmer (confirmer un RDV,
  approuver un congé).
- Deux tailles : compacte (listes, actions de ligne de tableau) et grande (formulaires,
  actions principales de page).
- État désactivé : opacité réduite, curseur bloqué, aucune interaction visuelle au clic.
- Focus clavier toujours visible (contour teal net) pour l'accessibilité.

---

## 6. BADGES

- **Badge de statut** : forme pilule, petit point coloré + texte, couleur = statut (succès,
  attente, erreur, critique, urgent, neutre) selon le tableau §2.4. Utilisé pour `statut` des
  RDV, congés, référencements, consultations.
- **Badge de rôle** : forme pilule compacte, texte en majuscules, couleur = rôle (§2.5).
  Affiché à côté du nom d'utilisateur dans la topbar et dans les listes d'utilisateurs.
- **Badge identifiant (mono)** : fond neutre, bordure fine, texte en police mono — pour
  afficher `numero_patient`, `numero_dossier`, `numero_ordonance` façon "code" traçable.

---

## 7. CARTES

- **Carte générique** : fond surface, bordure fine, coins larges, ombre légère, en-tête
  optionnel avec titre + action à droite. Conteneur de base pour tout bloc de contenu
  (formulaire, détail d'un médecin, historique d'un dossier...).
- **Carte statistique (KPI)** : petite icône ronde teintée en haut, grande valeur chiffrée en
  police display, libellé discret en dessous, indicateur de tendance (vert si hausse positive,
  rouge si baisse). Utilisée sur les dashboards ADMIN et SUPER_ADMIN (nombre de RDV du mois,
  nombre de médecins actifs, taux d'occupation...).

---

## 8. TABLEAUX

- En-tête collant (reste visible au défilement), fond légèrement teinté, texte en majuscules
  discret.
- Lignes zébrées légèrement, ligne surlignée au survol.
- Conteneur avec défilement horizontal sur mobile pour ne jamais casser la mise en page.
- Utilisés pour toutes les listes : médecins, services, RDV, congés, référencements, hôpitaux.

---

## 9. FORMULAIRES

- Champ avec label au-dessus (gras, petit), bordure fine, coins moyens, fond surface.
- État focus : bordure teal + halo teinté doux autour du champ.
- Texte d'aide discret sous le champ si besoin.
- État d'erreur : bordure rouge + message d'erreur rouge sous le champ — pensé pour la
  validation manuelle côté serveur (le Servlet renvoie les erreurs, la JSP les affiche via
  JSTL, aucune validation JS bloquante côté client).
- Bandeaux d'alerte (succès/attention/erreur) pleine largeur en haut de formulaire pour les
  messages globaux ("Modification enregistrée", "Le créneau n'est plus disponible"...).

---

## 10. DISPOSITION DE L'ÉCRAN (LAYOUT)

Structure commune à toutes les pages connectées : sidebar fixe à gauche + zone de contenu à
droite (topbar + contenu principal).

```
┌───────────────────────────────────────────────────────────┐
│  SIDEBAR (fixe, ~264px)   │  TOPBAR (recherche | cloche    │
│  ────────────────────────│  notifications | badge de rôle │
│  Logo MediCentral          │  | avatar | interrupteur      │
│                             │  clair/sombre)                │
│  Liens de navigation,      │──────────────────────────────│
│  différents selon le rôle  │  CONTENU PRINCIPAL             │
│  connecté (Dashboard,      │  Titre de page                 │
│  Médecins, Services,       │  Ligne de pouls (signature)    │
│  RDV, Rapports...)         │  Cartes / tableaux / formulaire│
│                             │  de la page                    │
│  En bas : Mon profil,      │                                 │
│  Déconnexion                │                                │
└───────────────────────────────────────────────────────────┘
```

Détails de la topbar, de gauche à droite : barre de recherche compacte, cloche de
notifications avec pastille indiquant le nombre de notifications non lues (table
`notifications`), badge du rôle courant, avatar (initiale du nom), interrupteur clair/sombre.

La sidebar affiche des liens différents selon le rôle en session :
- **PATIENT** : Tableau de bord, Mon dossier, Prendre RDV, et ce qui concerne de patient .
donc tu fais pour les autres roles c est comme ca et je sais que tu le sais 
global.
- Commun à tous : Mon profil, Déconnexion.

Sur mobile/tablette (largeur réduite), la sidebar se rétracte hors écran et s'ouvre en
tiroir superposé au contenu.

---

## 11. MODE SOMBRE

Basculé par un interrupteur dans la topbar (icône soleil/lune). Comportement attendu :
- Au premier chargement, respecte la préférence système de l'utilisateur (clair/sombre) s'il
  n'a jamais choisi manuellement.
- Une fois choisi, le thème est mémorisé côté navigateur et réappliqué à chaque visite, sans
  aucun échange avec le serveur (donc aucune techno interdite impliquée).
- Aucun flash de couleur claire ne doit apparaître au chargement si le thème sombre est actif.
- Toutes les couleurs du §2 ont leur variante sombre — aucune couleur "en dur" ne doit être
  utilisée dans le code, uniquement des valeurs qui changent selon le thème actif.

---

## 12. GRAPHIQUES ET STATISTIQUES

Les dashboards ADMIN,MEDECIN, et SUPER_ADMIN ,ont besoin de visualiser des données (répartition des RDV
par statut, activité mensuelle, taux d'occupation par hôpital). Deux approches possibles :

- **Avec une petite librairie de graphiques en JS natif** (type Chart.js) : rapide à mettre en
  place, rendu dans un simple élément graphique de page, les données viennent du serveur (EJB
  → JSP) sans passer par une API REST/JSON.
- **Sans aucune dépendance** : graphiques simples dessinés directement dans la page à partir de
  pourcentages calculés côté serveur (ex. un anneau de répartition RDV confirmés/en
  attente/annulés, coloré avec les couleurs de statut du §2.4).

Dans les deux cas : couleurs de graphique = couleurs de statut/rôle définies plus haut, jamais
de couleurs inventées à part, pour rester cohérent avec le reste de l'interface.

---

## 13. ACCESSIBILITÉ ET QUALITÉ

- Contraste suffisant entre texte et fond dans les deux modes (déjà vérifié dans les valeurs
  choisies).
- Focus clavier toujours visible sur boutons, liens, champs.
- Respect de la préférence "mouvement réduit" de l'utilisateur : désactiver toute transition/
  animation si l'utilisateur l'a demandé au niveau système.
- Interface responsive jusqu'à l'écran mobile (sidebar en tiroir, tableaux défilables).

FIN DU FICHIER.
