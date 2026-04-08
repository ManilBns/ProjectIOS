# MediaTracker

Application web CRUD développée en Swift avec Hummingbird 2 et SQLite, dans le cadre du projet final du cours ISEi à l'Université Paris 8 Vincennes-Saint-Denis.

MediaTracker permet de gérer sa collection personnelle de jeux vidéo et de séries / animes. L'application offre un tableau de bord centralisé pour suivre ce que l'on joue, ce que l'on regarde, noter ses médias et conserver des notes personnelles.

---

## Auteurs

- Manil BENMOUSSA

---

## Lancer l'application

```bash
./build.sh   # Compiler le projet
./run.sh     # Démarrer le serveur sur http://localhost:8080
```

Ne pas modifier `Package.swift`, `build.sh`, `run.sh` ni `.devcontainer/`.

---

## Routes exposées

### General

| Méthode | Route     | Description                              |
|---------|-----------|------------------------------------------|
| GET     | `/`       | Page d'accueil avec statistiques globales |
| GET     | `/search` | Formulaire de recherche globale           |
| POST    | `/search` | Recherche dans jeux et séries simultanément |

### Jeux vidéo

| Méthode | Route                  | Description                              |
|---------|------------------------|------------------------------------------|
| GET     | `/games`               | Liste tous les jeux (tri via ?sort=field) |
| GET     | `/games/new`           | Formulaire de création                   |
| POST    | `/games/create`        | CREATE — Insère un nouveau jeu           |
| GET     | `/games/:id`           | READ — Détail et formulaire de modification |
| POST    | `/games/update/:id`    | UPDATE — Modifie un jeu existant         |
| POST    | `/games/delete/:id`    | DELETE — Supprime un jeu                 |

### Séries

| Méthode | Route                   | Description                               |
|---------|-------------------------|-------------------------------------------|
| GET     | `/series`               | Liste toutes les séries (tri via ?sort=field) |
| GET     | `/series/new`           | Formulaire de création                    |
| POST    | `/series/create`        | CREATE — Insère une nouvelle série        |
| GET     | `/series/:id`           | READ — Détail et formulaire de modification |
| POST    | `/series/update/:id`    | UPDATE — Modifie une série existante      |
| POST    | `/series/delete/:id`    | DELETE — Supprime une série               |

Total : 15 routes (2 GET globaux + 6 GET + 7 POST).

---

## Modeles de données

### Game — table `games`

| Champ        | Type    | Description                                             |
|--------------|---------|---------------------------------------------------------|
| id           | INTEGER | Clé primaire auto-incrémentée                           |
| title        | TEXT    | Titre du jeu                                            |
| platform     | TEXT    | PC, PS5, PS4, Xbox, Nintendo Switch, Mobile, Autre      |
| genre        | TEXT    | Action, RPG, FPS, Sport, Stratégie, Aventure, Horreur   |
| status       | TEXT    | wishlist / in_progress / completed / dropped            |
| rating       | REAL    | Note sur 10 (0 = non noté)                              |
| hours_played | REAL    | Heures jouées                                           |
| notes        | TEXT    | Notes libres                                            |

### Series — table `series`

| Champ    | Type    | Description                                                   |
|----------|---------|---------------------------------------------------------------|
| id       | INTEGER | Clé primaire auto-incrémentée                                 |
| title    | TEXT    | Titre de la série                                             |
| platform | TEXT    | Netflix, Disney+, Prime Video, Max / HBO, Apple TV+, Autre    |
| genre    | TEXT    | Action, Comédie, Drame, Sci-Fi, Thriller, Horreur, Anime      |
| status   | TEXT    | wishlist / in_progress / completed / dropped                  |
| rating   | REAL    | Note sur 10 (0 = non noté)                                    |
| seasons  | INTEGER | Nombre de saisons vues                                        |
| notes    | TEXT    | Notes libres                                                  |

### Statuts disponibles (partagés entre les deux modèles)

| Valeur      | Affichage       |
|-------------|-----------------|
| wishlist    | A faire / A voir |
| in_progress | En cours        |
| completed   | Terminé         |
| dropped     | Abandonné       |

---

## Structure du projet

```
Sources/App/
├── main.swift       # Point d'entrée — 15 routes Hummingbird 2
├── Models.swift     # Structs Game, Series, GameForm, SeriesForm, enums, extensions
├── Database.swift   # DatabaseManager — CRUD SQLite pour les deux tables
└── Views.swift      # Génération HTML côté serveur — toutes les pages
```

---

## Fonctionnalités bonus

| Fonctionnalité        | Description                                                              |
|-----------------------|--------------------------------------------------------------------------|
| Deuxième modèle (+5)  | Tables `games` et `series` indépendantes avec CRUD complet chacune       |
| Recherche (+5)        | `/search` interroge les deux tables simultanément avec des clauses LIKE  |
| Tri (+3)              | Paramètre `?sort=` disponible sur `/games` et `/series`                  |
| Page de détails (+5)  | `/games/:id` et `/series/:id` avec formulaire de modification intégré    |
| UI personnalisée (+3) | Thème sombre, couleurs distinctes, badges de statut, étoiles de notation |

---

## Concepts Swift démontrés

- `struct` — Game, Series, GameForm, SeriesForm conformes à Codable et Sendable
- `enum` — MediaStatus, GamePlatform, StreamingPlatform, GameGenre, SeriesGenre avec CaseIterable
- `final class` — DatabaseManager avec @unchecked Sendable
- `extension` — validation des formulaires sur GameForm et SeriesForm
- `async/await` — lecture du corps HTTP dans les handlers POST
- `try/throws` — interactions SQLite et démarrage du serveur
- Closures — handlers de routes Hummingbird passés en trailing closure

---

## Dépendances

Aucune dépendance ajoutée. Le projet utilise uniquement celles fournies dans le `Package.swift` du template :

- Hummingbird 2 — framework web Swift
- SQLite.swift — interactions SQLite avec expressions typées (pas de SQL brut)
