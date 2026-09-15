# MEDICENTRAL — SYSTÈME DE DESIGN (prompt pour agent de code)

> À donner tel quel à l'agent qui génère les JSP. Ce document décrit
> EXACTEMENT comment doit être stylée chaque page de MediCentral.
> Inspiration structurelle : le dashboard "Lynk" (sidebar claire, cartes
> métriques, donut de statuts) — adapté à une identité médicale.
>
> CONTRAINTE ABSOLUE : tout le style est en CSS pur (fichier
> `style.css` unique, lié en `<link>` dans chaque JSP). Aucun
> framework CSS (pas de Tailwind, Bootstrap facultatif à éviter),
> aucun framework JS (pas de React/Vue/htmx/Alpine). Le seul JS
> autorisé est du JS "vanilla" minimal pour l'UI (toggle sidebar,
> toggle dark mode, confirmation de suppression) — jamais pour la
> logique métier, qui reste 100% côté serveur (Servlet + EJB + JPA).

---

## 1. Principe directeur

MediCentral doit inspirer **confiance clinique** et **clarté**, pas
"startup tendance". On garde la structure du dashboard Lynk (sidebar
gauche fixe, topbar avec recherche, grille de cartes métriques, zone
de contenu principal + colonne latérale droite optionnelle) mais on
retire tout ce qui fait "e-commerce/lifestyle" : pas de dégradés
décoratifs, pas d'emoji dans les titres, pas de photos de produits.

---

## 2. Palette de couleurs

### Mode clair (par défaut)

| Rôle | Variable CSS | Valeur |
|---|---|---|
| Fond de page | `--bg-page` | `#F4F8FF` |
| Fond des cartes | `--bg-card` | `#FFFFFF` |
| Fond sidebar | `--bg-sidebar` | `#FFFFFF` |
| Bordures | `--border-color` | `#E4E9F1` |
| Texte principal | `--text-primary` | `#101828` |
| Texte secondaire | `--text-secondary` | `#5A6472` |
| Texte discret | `--text-muted` | `#9AA4B2` |
| Marque primaire (boutons, liens, actif) | `--brand-primary` | `#0B57D0` |
| Marque primaire hover | `--brand-primary-hover` | `#0846AD` |
| Marque primaire, fond léger (item actif sidebar) | `--brand-primary-tint` | `#E8F0FE` |
| Accent secondaire (santé / succès doux) | `--brand-teal` | `#0D9488` |
| Fond accent teal léger | `--brand-teal-tint` | `#ECFDF9` |

### Couleurs de statut (mappées à tes enums métier)

| Statut | Couleur texte | Fond badge |
|---|---|---|
| `RDV_DEMANDE`, `EN_ATTENTE` | `#B45309` | `#FEF3C7` |
| `RDV_CONFIRME`, `EN_COURS`, `ACCEPTE` | `#1D4ED8` | `#DBEAFE` |
| `TERMINE`, `APPROUVE`, `VERSEE_AU_DOSSIER`, `CLOTUREE`/`CLOTURE` | `#15803D` | `#DCFCE7` |
| `RDV_ANNULE`, `REFUSE` | `#B91C1C` | `#FEE2E2` |
| Priorité `NORMAL` | `#475569` | `#F1F5F9` |
| Priorité `URGENT` | `#C2410C` | `#FFEDD5` |
| Priorité `CRITIQUE` | `#FFFFFF` | `#DC2626` (fond plein, pas juste teinté) |

### Mode sombre (`data-theme="dark"` sur `<html>`)

| Variable | Valeur |
|---|---|
| `--bg-page` | `#0B1220` |
| `--bg-card` | `#121B2E` |
| `--bg-sidebar` | `#0E1626` |
| `--border-color` | `#22304A` |
| `--text-primary` | `#EAF0FB` |
| `--text-secondary` | `#9AB0CE` |
| `--text-muted` | `#6B7C97` |
| `--brand-primary` | `#5B8DEF` |
| `--brand-primary-hover` | `#7BA3F5` |
| `--brand-primary-tint` | `#182642` |
| `--brand-teal` | `#2DD4BF` |
| `--brand-teal-tint` | `#0F2A28` |

Les couleurs de statut gardent la même **teinte** en dark mode mais
avec un fond plus sombre et un texte plus clair (voir `style.css`,
section `[data-theme="dark"]`).

---

## 3. Typographie

- Police unique : **Inter** (fallback `system-ui, -apple-system,
  "Segoe UI", sans-serif`) — chargée en local ou via Google Fonts
  self-hosted si le serveur n'a pas accès à Internet en prod.
- Échelle : `12 / 13 / 14 (base) / 16 / 20 / 24 / 32`
- Poids : 400 (texte courant), 500 (labels, boutons), 600 (titres de
  carte), 700 (chiffres clés / KPI)
- Pas de MAJUSCULES pour les labels. Pas de lettres espacées.
- Longueur de ligne du contenu texte (rapports, notes) : max ~75
  caractères.

---

## 4. Grille et dimensions

- Layout global : sidebar fixe **260px** (72px en mode réduit) +
  contenu fluide.
- Topbar : hauteur **64px**, fixe en haut de la zone de contenu.
- Conteneur de contenu : `padding: 32px 32px 48px` sur desktop,
  `16px` sur mobile.
- Grille de cartes KPI : `grid-template-columns:
  repeat(auto-fit, minmax(220px, 1fr))`, `gap: 20px`.
- Rayon de bordure :
  - Cartes / panneaux : `12px`
  - Boutons / champs de formulaire : `8px`
  - Badges de statut : `999px` (pilule)
  - Avatars : `50%`
- Ombres (légères, jamais lourdes) :
  - `--shadow-sm: 0 1px 2px rgba(16,24,40,.06)`
  - `--shadow-md: 0 4px 12px rgba(16,24,40,.08)`
- Breakpoints : `1200px` (large), `960px` (tablette — sidebar en
  overlay), `640px` (mobile — cartes en colonne unique).

---

## 5. Composants

### Sidebar
- Fond `--bg-sidebar`, bordure droite `1px solid var(--border-color)`.
- Logo + nom de l'app en haut (hauteur 64px, aligné avec la topbar).
- Items de nav : icône 20px + label 14px/500, hauteur 40px, radius 8px.
- Item actif : fond `--brand-primary-tint`, texte et icône
  `--brand-primary`, barre verticale 3px `--brand-primary` collée au
  bord gauche.
- Item au survol (non actif) : fond `--border-color` à 50% d'opacité,
  transition `background-color .15s ease`.
- Items filtrés par rôle : le Servlet/JSP ne rend que les `<li>`
  autorisés pour `session.role` (via JSTL `<c:if>`), jamais caché en
  CSS uniquement.

### Topbar
- Barre de recherche à gauche (si utile au rôle), notifications
  (icône cloche + pastille rouge si non lues), sélecteur de thème
  (☀/☾), avatar + nom + rôle à droite.

### Cartes KPI (métriques)
- `--bg-card`, `border: 1px solid var(--border-color)`, `radius:12px`,
  `padding: 20px`, `box-shadow: var(--shadow-sm)`.
- Icône ronde 40px en haut à gauche, fond teinté selon le sens de la
  métrique (teal pour positif, ambre pour attention).
- Chiffre clé : 24px/700, `--text-primary`.
- Variation : 12px/500, vert si positif (`#15803D`), rouge si négatif
  (`#B91C1C`), avec petite flèche ▲/▼ — jamais de couleur seule pour
  porter l'information (toujours + le signe et la flèche).
- Au survol : `transform: translateY(-2px)`, `box-shadow:
  var(--shadow-md)`, transition `.18s ease`. Un seul effet, pas de
  cumul d'animations.

### Boutons

| Variante | Fond | Texte | Bordure | Usage |
|---|---|---|---|---|
| Primaire | `--brand-primary` | blanc | aucune | Action principale (Enregistrer, Confirmer le RDV) |
| Secondaire | transparent | `--brand-primary` | `1px solid var(--brand-primary)` | Action alternative (Annuler, Retour) |
| Danger | `--danger` `#DC2626` | blanc | aucune | Refuser, Désactiver, Supprimer |
| Fantôme | transparent | `--text-secondary` | aucune | Actions tertiaires dans les tableaux |

- Hauteur standard : `40px` (`36px` en version compacte pour les
  tableaux). Padding horizontal `16px`. Radius `8px`. `font-weight:500`.
- Hover : assombrir de ~8% (`--brand-primary-hover`), transition
  `.15s ease`.
- Active (clic) : `transform: scale(.98)`.
- Focus clavier : `outline: 2px solid var(--brand-primary); outline-offset:2px` — jamais `outline:none` sans remplacement.
- Disabled : `opacity:.5; cursor:not-allowed`, aucun hover.

### Badges de statut
- Pilule (`radius:999px`), padding `4px 10px`, `font-size:12px`,
  `font-weight:600`. Couleurs = tableau section 2.
- Toujours accompagnés du **texte du statut en toutes lettres**
  (jamais juste une pastille de couleur), pour l'accessibilité.

### Tableaux (listes de RDV, médecins, patients, dossiers…)
- En-tête : fond `--bg-page`, texte `--text-secondary` 12px/600,
  ligne de séparation `1px solid var(--border-color)`.
- Lignes : hauteur `56px`, séparateur `1px solid var(--border-color)`.
- Survol de ligne : fond `--brand-primary-tint` à 40% d'opacité.
- Pagination JSTL en bas à droite (boutons fantôme + numéro actif en
  primaire plein).

### Formulaires
- Label 13px/500 `--text-secondary` au-dessus du champ.
- Champ : hauteur `40px`, `border:1px solid var(--border-color)`,
  `radius:8px`, `padding:0 12px`, fond `--bg-card`.
- Focus : bordure `--brand-primary`, `box-shadow:0 0 0 3px
  var(--brand-primary-tint)`.
- Erreur (validation serveur, EL `${erreur}`) : bordure `--danger`,
  message d'erreur 12px `--danger` sous le champ, jamais de pop-up.
- Formulaires multi-étapes (upload pièces jointes, etc.) : indicateur
  d'étapes en haut = numéros dans un cercle, relié par un trait ; étape
  active en `--brand-primary` plein, étapes terminées en `--brand-teal`
  avec coche, étapes à venir en gris.

### Carte "workflow" (donut / anneau de statuts)
- Reprend le donut "Tasks by Status" de Lynk → renommé selon la page :
  "Rendez-vous par statut" (dashboard médecin/admin), "Consultations
  par statut", "Congés par statut".
- Centre du donut : total en 28px/700 + libellé 12px `--text-muted`.
- Légende à droite avec puce de couleur (ronde 8px) + libellé +
  nombre + pourcentage — mêmes couleurs que les badges de statut pour
  garder la cohérence visuelle entre le graphique et les listes.

### Alertes / urgences
- Bandeau plein en haut de page (pas une carte parmi d'autres) pour
  les RDV `priorite = CRITIQUE` en attente : fond `--danger` à 10%
  d'opacité, bordure gauche `4px solid var(--danger)`, icône
  d'alerte, texte `--text-primary`.

---

## 6. Animations et micro-interactions

Principe : **une seule intention de mouvement par action**, jamais de
cumul. Durée `150–200ms`, easing `ease` ou `cubic-bezier(.4,0,.2,1)`.

- Survol de carte / ligne de tableau : léger déplacement ou teinte —
  pas les deux avec un troisième effet en plus.
- Ouverture d'un panneau latéral (dossier patient, détail médecin) :
  translation depuis la droite `.25s ease`, pas de fondu + zoom en
  même temps.
- Changement de statut (ex : confirmer un RDV) : le badge change de
  couleur avec une transition `.2s`, pas d'animation de rebond.
- Toujours respecter `prefers-reduced-motion: reduce` → désactiver les
  transitions non essentielles pour les utilisateurs qui le demandent.
- Le sélecteur de thème clair/sombre transitionne les couleurs de fond
  et de texte en `.2s ease` sur `body, .sidebar, .card` uniquement
  (pas de transition globale sur `*`, trop coûteuse).

---

## 7. Accessibilité (obligatoire, contexte médical = public large)

- Contraste texte/fond minimum AA (4.5:1) partout, y compris en dark
  mode — vérifié pour chaque couleur de statut.
- Le focus clavier doit toujours être visible (voir boutons).
- Les icônes seules (cloche, poubelle…) ont un `title`/`aria-label`.
- Les tableaux ont de vraies balises `<th scope="col">`.
- Taille de police jamais en dessous de 12px, texte redimensionnable.

---

## 8. Intégration technique dans le projet Jakarta EE

- Un seul fichier `webapp/resources/css/style.css` (voir fichier livré),
  inclus dans `common/header.jsp` :
  ```jsp
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css">
  ```
- Le toggle dark mode est un petit script inline dans `footer.jsp`
  (vanilla JS, aucune dépendance) qui :
  1. lit `localStorage.getItem('mc-theme')`
  2. applique `document.documentElement.setAttribute('data-theme', ...)`
  3. sauvegarde le choix au clic
  → Ceci reste conforme aux interdictions : ce n'est ni un framework
  front, ni de la logique métier, juste une préférence d'affichage.
- Les classes CSS sont génériques et réutilisées par JSTL dans toutes
  les JSP : `.card`, `.btn`, `.btn-primary`, `.btn-secondary`,
  `.btn-danger`, `.badge`, `.badge-warning`, `.badge-info`,
  `.badge-success`, `.badge-danger`, `.table`, `.sidebar`,
  `.sidebar-item`, `.sidebar-item.active`, `.kpi-card`, `.form-group`,
  `.form-control`, `.stepper`, `.alert-critical`.
- Exemple JSTL pour un badge de statut dynamique :
  ```jsp
  <c:choose>
    <c:when test="${rdv.statut == 'RDV_CONFIRME'}">
      <span class="badge badge-info">Confirmé</span>
    </c:when>
    <c:when test="${rdv.statut == 'TERMINE'}">
      <span class="badge badge-success">Terminé</span>
    </c:when>
    <c:when test="${rdv.statut == 'RDV_ANNULE'}">
      <span class="badge badge-danger">Annulé</span>
    </c:when>
    <c:otherwise>
      <span class="badge badge-warning">Demandé</span>
    </c:otherwise>
  </c:choose>
  ```

---

### Application globale du guide bleu

- `burundihealthconnect-web/src/main/webapp/resources/css/style.css` est le
  point d'entrée unique chargé par `common/theme-init.jsp` sur chaque page.
- Il charge `style-guide.css`, la couche d'unification globale : focus clavier,
  tableaux, formulaires, en-têtes de pages, états vides et comportement mobile.
- La marque principale reste le bleu clinique `#2563EB` (et `#5B8DEF` en mode
  sombre). Les couleurs rouge, ambre et vert sont réservées aux statuts et aux
  alertes, jamais à la navigation principale.
- Les copies de référence sont maintenues dans `databaseAndLogic/` ; les
  fichiers effectivement servis au navigateur sont dans
  `burundihealthconnect-web/src/main/webapp/resources/css/`.

## 9. Ce qu'on ne fait PAS (rappel des interdits du cahier des charges)

- Pas de Tailwind/Bootstrap CSS framework complet, pas de compilateur
  CSS (Sass autorisé seulement si compilé à la main hors build tool
  imposé par le sujet — sinon CSS pur suffit largement ici).
- Pas de React/Vue/htmx/Alpine, pas de composants JS réactifs.
- Pas de scriptlet Java dans les JSP — tout l'état dynamique passe par
  EL/JSTL, le CSS ne fait que styliser ce que le serveur a déjà décidé.
- Pas d'appel AJAX/REST/JSON pour rafraîchir les données (interdit par
  le sujet) — chaque action = un formulaire POST classique + redirection
  Servlet + re-render JSP complet.
