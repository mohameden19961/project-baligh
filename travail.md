# Répartition du travail — Projet Baligh

## Membres de l'équipe

| Numéro | Nom | Rôle principal |
|--------|-----|---------------|
| 24068 | **Abdy Mohameden** | Architecture, Backend, Routing |
| 24139 | **Abdselam Abdelvetah** | UI/UX, Signalement, Carte, Home |
| 24157 | **Ahmedou Bedou** | Alertes, Notifications, Crédibilité |
| 24238 | **Hassen Oumeiry** | Authentification, Profil, Paramètres |

---

## Répartition détaillée

### Abdy Mohameden (24068) — Architecture & Backend

- `lib/main.dart` — Point d'entrée, configuration ProviderScope, MaterialApp.router
- `lib/router/app_router.dart` — Routes GoRouter (15 routes)
- `lib/core/providers/app_providers.dart` — Providers globaux (locale, theme)
- `lib/core/theme/app_theme.dart` — Thème Material 3 (clair/sombre), typographie Cairo
- `lib/core/l10n/` — Fichiers ARB (ar/fr/en) + code généré de localisation
- `rapport_baligh.tex` — Rédaction du rapport LaTeX (architecture, base de données, sécurité, déploiement)
- `diagrammes/` — Diagrammes SVG (architecture MVC, navigation, stack technologique, flux signalement)

### Abdselam Abdelvetah (24139) — UI/UX & Fonctionnalités principales

- `lib/features/home/screens/home_screen.dart` — Scaffold principal, BottomAppBar, IndexedStack, FAB
- `lib/features/home/screens/home_content.dart` — Fil d'actualité, chips de filtre, cartes signalements, stats
- `lib/features/home/screens/map_picker_screen.dart` — Sélecteur de localisation
- `lib/features/report/screens/report_form_screen.dart` — Formulaire de signalement (catégories, description, photo, validation)
- `lib/core/widgets/category_card.dart` — Widget carte de catégorie
- `captures-application/` — Captures d'écran de l'application
- `rapport_baligh.tex` — Rédaction du rapport (signalement, carte, accueil)
- `generate_pptx.py` — Génération de la présentation PowerPoint

### Ahmedou Bedou (24157) — Alertes & Interactions sociales

- `lib/features/alerts/screens/alert_feed_screen.dart` — Liste des alertes avec filtres
- `lib/features/alerts/screens/alert_detail_screen.dart` — Détail d'alerte (crédibilité, images, actions)
- `lib/features/alerts/screens/notifications_screen.dart` — Centre de notifications (lu/non lu)
- `lib/core/widgets/alert_card.dart` — Widget carte d'alerte complète
- `lib/core/widgets/credibility_badge.dart` — Badge de crédibilité coloré
- `rapport_baligh.tex` — Rédaction du rapport (messagerie, notifications, vote)
- `diagrammes/` — Contribution aux diagrammes de flux

### Hassen Oumeiry (24238) — Authentification & Gestion utilisateur

- `lib/features/auth/screens/splash_screen.dart` — Écran de bienvenue animé
- `lib/features/auth/screens/onboarding_screen.dart` — PageView onboarding (3 slides)
- `lib/features/auth/screens/language_select_screen.dart` — Sélection de langue (AR/FR/EN)
- `lib/features/auth/screens/login_screen.dart` — Écran de connexion
- `lib/features/auth/screens/register_screen.dart` — Écran d'inscription
- `lib/features/auth/screens/forgot_password_screen.dart` — Mot de passe oublié
- `lib/features/profile/screens/profile_screen.dart` — Profil utilisateur (stats, menu)
- `lib/features/profile/screens/edit_profile_screen.dart` — Édition du profil
- `lib/features/settings/screens/settings_screen.dart` — Paramètres (langue, thème, notifications)
- `lib/core/widgets/app_button.dart` — Bouton réutilisable
- `lib/core/widgets/app_text_field.dart` — Champ de texte RTL
- `rapport_baligh.tex` — Rédaction du rapport (authentification, profil, paramètres)

---

## Récapitulatif

| Membre | Rôle | Contributions clés |
|--------|------|-------------------|
| **Abdy Mohameden (24068)** | Architecture & Backend | Structure du projet, routing, providers, thème, i18n, diagrammes, rapport |
| **Abdselam Abdelvetah (24139)** | UI/UX & Fonctionnalités | Home, carte, formulaire signalement, captures, PowerPoint, rapport |
| **Ahmedou Bedou (24157)** | Alertes & Social | Alertes, notifications, crédibilité, diagrammes, rapport |
| **Hassen Oumeiry (24238)** | Auth & Profil | 6 écrans auth, profil, settings, widgets partagés, rapport |
