# Répartition du travail — Projet Baligh

## Membres de l'équipe

| Numéro | Nom | Rôle principal |
|--------|-----|---------------|
| 24068 | **Abdy Mohameden** | Architecture, Backend, Datamodel |
| 24139 | **Abdselam Abdelvetah** | UI/UX, Formulaire signalement, Carte |
| 24157 | **Ahmedou Bedou** | Backend, Vote, Messagerie, Notifications |
| 24238 | **Hassen Oumeiry** | Auth, Profil, Paramètres, Localisation |

---

## Répartition détaillée

### Abdy Mohameden (24068)

| Fichier | Rôle | Lignes |
|---------|------|--------|
| `lib/main.dart` | Point d'entrée, ProviderScope, MaterialApp.router | 43 |
| `lib/router/app_router.dart` | Définition des 15 routes GoRouter | 82 |
| `lib/core/providers/app_providers.dart` | Providers globaux (locale, theme, SharedPreferences) | 47 |
| `lib/core/theme/app_theme.dart` | Thème Material 3 (clair/sombre) + typographie Cairo | 88 |
| `lib/core/l10n/` | Génération ARB + fichiers de traduction (ar/fr/en) | 560 |
| **Total** | **~820 lignes** | |

### Abdselam Abdelvetah (24139)

| Fichier | Rôle | Lignes |
|---------|------|--------|
| `lib/features/home/screens/home_screen.dart` | Scaffold principal, BottomAppBar, IndexedStack 4 tabs, FAB | 86 |
| `lib/features/home/screens/home_content.dart` | Fil d'actualité, chips de filtre, cartes d'alertes, stats | 271 |
| `lib/features/home/screens/map_picker_screen.dart` | Sélecteur de localisation sur carte (placeholer Google Maps) | 81 |
| `lib/features/report/screens/report_form_screen.dart` | Formulaire de signalement : grille catégories, description, photo, validation | 233 |
| `lib/core/widgets/category_card.dart` | Carte de catégorie avec état sélectionné | 53 |
| **Total** | **~724 lignes** | |

### Ahmedou Bedou (24157)

| Fichier | Rôle | Lignes |
|---------|------|--------|
| `lib/features/alerts/screens/alert_feed_screen.dart` | Liste des alertes avec filtres | 80 |
| `lib/features/alerts/screens/alert_detail_screen.dart` | Détail alerte : SliverAppBar, crédibilité, images, actions | 231 |
| `lib/features/alerts/screens/notifications_screen.dart` | Centre de notifications (lu/non lu, grouped by date) | 138 |
| `lib/core/widgets/alert_card.dart` | Widget carte d'alerte complète avec crédibilité | 169 |
| `lib/core/widgets/credibility_badge.dart` | Badge de crédibilité coloré (vert/orange/rouge) | 36 |
| **Total** | **~654 lignes** | |

### Hassen Oumeiry (24238)

| Fichier | Rôle | Lignes |
|---------|------|--------|
| `lib/features/auth/screens/splash_screen.dart` | Écran de bienvenue animé | 101 |
| `lib/features/auth/screens/onboarding_screen.dart` | PageView onboarding 3 slides | 121 |
| `lib/features/auth/screens/language_select_screen.dart` | Sélection de langue (AR/FR/EN) | 88 |
| `lib/features/auth/screens/login_screen.dart` | Écran de connexion | 141 |
| `lib/features/auth/screens/register_screen.dart` | Écran d'inscription | 138 |
| `lib/features/auth/screens/forgot_password_screen.dart` | Mot de passe oublié | 78 |
| `lib/features/profile/screens/profile_screen.dart` | Profil utilisateur, statistiques, menu | 202 |
| `lib/features/profile/screens/edit_profile_screen.dart` | Édition du profil | 81 |
| `lib/features/settings/screens/settings_screen.dart` | Paramètres (langue, thème, notifications, à propos) | 190 |
| `lib/core/widgets/app_button.dart` | Bouton réutilisable avec chargement | 36 |
| `lib/core/widgets/app_text_field.dart` | Champ de texte RTL | 61 |
| **Total** | **~1237 lignes** | |

---

## Récapitulatif

| Membre | Lignes | Fichiers | Domaines principaux |
|--------|--------|----------|---------------------|
| Abdy Mohameden (24068) | ~820 | 6 | Architecture, routing, state management, thème, i18n |
| Abdselam Abdelvetah (24139) | ~724 | 5 | Home, feed, carte, formulaire signalement |
| Ahmedou Bedou (24157) | ~654 | 5 | Alertes, notifications, widgets crédibilité |
| Hassen Oumeiry (24238) | ~1237 | 11 | Auth (6 écrans), profil, settings, widgets partagés |

---

## Fonctionnalités restantes (backend / API)

Toutes les données sont actuellement en **dur (mock)**. Les prochaines étapes :

| Fonctionnalité | Priorité | Assigné |
|---------------|----------|---------|
| Backend Supabase (Auth, DB, API) | Haute | Abdy + Ahmedou |
| Authentification réelle (Supabase Auth) | Haute | Hassen |
| API signalements (CRUD Supabase) | Haute | Abdselam |
| Upload photo (image_picker → Supabase Storage) | Moyenne | Abdselam |
| Google Maps intégration | Moyenne | Abdselam |
| Géolocalisation (geolocator) | Moyenne | Abdy |
| Messagerie temps réel (Realtime) | Basse | Ahmedou |
| Système de vote | Basse | Ahmedou |
| Tests unitaires | Basse | Tous |
