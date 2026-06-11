# Répartition du travail — Projet Baligh

## Membres de l'équipe

| Numéro | Nom | Rôle |
|--------|-----|------|
| 24068 | **Abdy Mohameden** | Architecture, State management, Services, DAOs |
| 24139 | **Abdselam Abdelvetah** | Views principales, Signalement, Carte, Widgets |
| 24157 | **Ahmedou Bedou** | Chat, Alertes, Notifications, Utilisateurs |
| 24238 | **Hassen Oumeiry** | Authentification, Profil, Paramètres, i18n |

---

## Répartition détaillée

### Abdy Mohameden (24068) — 14 fichiers

| Fichier |
|---------|
| `main.dart` |
| `controllers/navigation_provider.dart` |
| `controllers/locale_provider.dart` |
| `controllers/theme_provider.dart` |
| `controllers/report_controller.dart` |
| `controllers/map_provider.dart` |
| `core/services/report_service.dart` |
| `core/services/report_service_db.dart` |
| `core/services/location_service.dart` |
| `core/database/report_dao.dart` |
| `core/models/report_model.dart` |
| `utils/app_constants.dart` |
| `utils/report_category_meta.dart` |
| `utils/supabase_config.dart` |

### Abdselam Abdelvetah (24139) — 13 fichiers

| Fichier |
|---------|
| `views/home/home_view.dart` |
| `views/add_report/add_report_view.dart` |
| `views/report_detail/report_detail_view.dart` |
| `views/emergency/emergency_numbers_view.dart` |
| `views/my_reports/my_reports_view.dart` |
| `views/map/map_view.dart` |
| `views/main_layout.dart` |
| `controllers/add_report_controller.dart` |
| `widgets/report_card.dart` |
| `widgets/empty_state.dart` |
| `widgets/google_button.dart` |
| `l10n/app_ar.arb` |
| `l10n/app_fr.arb` |

### Ahmedou Bedou (24157) — 13 fichiers

| Fichier |
|---------|
| `controllers/chat_controller.dart` |
| `controllers/alert_controller.dart` |
| `views/chat/chat_view.dart` |
| `views/chat/conversations_view.dart` |
| `views/alerts/alerts_view.dart` |
| `core/services/auth_service.dart` |
| `core/services/notification_service.dart` |
| `core/database/message_dao.dart` |
| `core/database/notification_dao.dart` |
| `core/database/user_dao.dart` |
| `core/models/message_model.dart` |
| `core/models/notification_model.dart` |
| `core/models/user_model.dart` |

### Hassen Oumeiry (24238) — 13 fichiers

| Fichier |
|---------|
| `controllers/auth_controller.dart` |
| `views/auth/login_view.dart` |
| `views/auth/register_view.dart` |
| `views/account/account_view.dart` |
| `views/settings/settings_view.dart` |
| `views/splash/splash_view.dart` |
| `l10n/app_localizations.dart` |
| `l10n/app_localizations_ar.dart` |
| `l10n/app_en.arb` |
| `l10n/app_localizations_en.dart` |
| `l10n/app_localizations_fr.dart` |
| `core/database/vote_dao.dart` |
| `core/models/vote_model.dart` |

---

**Total :** 53 fichiers, 4 membres, ~13 fichiers chacun.
