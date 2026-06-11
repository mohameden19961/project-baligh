# Répartition du travail — Projet Baligh

## Membres de l'équipe

| Numéro | Nom | Rôle |
|--------|-----|------|
| 24068 | **Abdy Mohameden** | Architecture, State management, Services, DAOs |
| 24139 | **Abdselam Abdelvetah** | Views principales, Signalement, Carte, Rapports |
| 24157 | **Ahmedou Bedou** | Backend, Messagerie, Notifications, Votes |
| 24238 | **Hassen Oumeiry** | Authentification, Profil, Paramètres, UI widgets |

---

## Répartition détaillée

### Abdy Mohameden (24068)

| Fichier | Description |
|---------|-------------|
| `lib/main.dart` | Point d'entrée, MultiProvider, initialisation Supabase/FMTC |
| `lib/controllers/navigation_provider.dart` | Navigation entre tabs (NavigationProvider) |
| `lib/controllers/locale_provider.dart` | Gestion de la langue (LocaleProvider) |
| `lib/controllers/theme_provider.dart` | Gestion du thème clair/sombre (ThemeProvider) |
| `lib/controllers/report_controller.dart` | Contrôleur des signalements (CRUD, filtres, recherche) |
| `lib/controllers/map_provider.dart` | Contrôleur carte (markers, filtres, sélection) |
| `lib/core/services/report_service.dart` | Interface abstraite ReportService |
| `lib/core/services/report_service_db.dart` | Implémentation Supabase du service signalement |
| `lib/core/services/location_service.dart` | Service de géolocalisation (Haversine) |
| `lib/core/database/report_dao.dart` | DAO signalements (CRUD Supabase) |
| `lib/core/database/user_dao.dart` | DAO utilisateurs (CRUD Supabase) |
| `lib/core/database/vote_dao.dart` | DAO votes (CRUD + compteurs) |
| `lib/core/models/report_model.dart` | Modèle ReportModel (12 catégories, 3 statuts) |
| `lib/core/models/user_model.dart` | Modèle UserModel (badge réputation) |
| `lib/core/models/vote_model.dart` | Modèle VoteModel (confirm/deny) |
| `lib/utils/app_constants.dart` | Constantes globales |
| `lib/utils/report_category_meta.dart` | Métadonnées catégories (icônes, couleurs) |
| `lib/utils/supabase_config.dart` | Configuration Supabase |
| `lib/views/map/map_view.dart` | Vue carte (flutter_map, FMTC, marqueurs) |
| `lib/views/my_reports/my_reports_view.dart` | Liste de mes signalements |
| `lib/views/main_layout.dart` | Shell principal (BottomAppBar, IndexedStack, FAB) |
| `rapport_baligh.tex` | Rédaction (architecture, base de données, déploiement) |
| `diagrammes/` | Diagrammes SVG (architecture MVC, stack technologique) |

### Abdselam Abdelvetah (24139)

| Fichier | Description |
|---------|-------------|
| `lib/views/home/home_view.dart` | Fil d'actualité (SliverAppBar, stats, filtres, liste) |
| `lib/views/add_report/add_report_view.dart` | Assistant création signalement (wizard 4 étapes) |
| `lib/views/report_detail/report_detail_view.dart` | Détail d'un signalement |
| `lib/views/emergency/emergency_numbers_view.dart` | Numéros d'urgence (SOS) |
| `lib/views/settings/settings_view.dart` | Écran paramètres |
| `lib/widgets/report_card.dart` | Carte de signalement réutilisable |
| `lib/widgets/empty_state.dart` | Widget état vide |
| `lib/widgets/google_button.dart` | Bouton Google Sign-In |
| `lib/core/database/notification_dao.dart` | DAO notifications |
| `lib/core/models/notification_model.dart` | Modèle NotificationModel |
| `lib/l10n/` | Fichiers ARB et code localisation (ar/fr/en) |
| `captures-application/` | Captures d'écran de l'application |
| `generate_pptx.py` | Script de génération PowerPoint |
| `rapport_baligh.tex` | Rédaction (signalement, carte, captures, accueil) |
| `diagrammes/` | Diagramme de navigation de l'application |

### Ahmedou Bedou (24157)

| Fichier | Description |
|---------|-------------|
| `lib/controllers/chat_controller.dart` | Messagerie temps réel (ChatProvider + Realtime) |
| `lib/controllers/alert_controller.dart` | Notifications (AlertProvider) |
| `lib/controllers/add_report_controller.dart` | Contrôleur assistant signalement (AddReportProvider) |
| `lib/views/chat/chat_view.dart` | Vue conversation (bulles, envoi) |
| `lib/views/chat/conversations_view.dart` | Liste des conversations |
| `lib/views/alerts/alerts_view.dart` | Vue notifications |
| `lib/core/services/auth_service.dart` | Service d'authentification (email + Google) |
| `lib/core/services/notification_service.dart` | Service de notifications (création) |
| `lib/core/database/message_dao.dart` | DAO messages (CRUD + Realtime) |
| `lib/core/models/message_model.dart` | Modèle MessageModel |
| `lib/views/splash/splash_view.dart` | Écran de bienvenue (splash) |
| `rapport_baligh.tex` | Rédaction (messagerie, notifications, vote, sécurité) |
| `diagrammes/` | Diagramme de flux de signalement |

### Hassen Oumeiry (24238)

| Fichier | Description |
|---------|-------------|
| `lib/controllers/auth_controller.dart` | Authentification (login, register, logout, session) |
| `lib/views/auth/login_view.dart` | Écran de connexion |
| `lib/views/auth/register_view.dart` | Écran d'inscription |
| `lib/views/account/account_view.dart` | Profil utilisateur |
| `lib/core/database/vote_dao.dart` | DAO votes (collaboration) |
| `lib/core/models/vote_model.dart` | Modèle VoteModel (collaboration) |
| `lib/core/database/user_dao.dart` | DAO utilisateurs (collaboration) |
| `lib/core/models/user_model.dart` | Modèle UserModel (collaboration) |
| `rapport_baligh.tex` | Rédaction (authentification, profil, paramètres, introduction) |
| Tests | Tests unitaires et validation |

---

## Récapitulatif

| Membre | Fichiers | Domaines |
|--------|----------|----------|
| **Abdy Mohameden (24068)** | ~22 fichiers | Architecture, state management, DAOs, modèles, carte, services, diagrammes |
| **Abdselam Abdelvetah (24139)** | ~18 fichiers | Home, add report, report detail, emergency, settings, widgets, i18n, captures, PowerPoint |
| **Ahmedou Bedou (24157)** | ~13 fichiers | Chat, notifications, signalement, auth service, splash, diagrammes |
| **Hassen Oumeiry (24238)** | ~10 fichiers | Auth, profil, votes, DAOs, tests, rapport |
