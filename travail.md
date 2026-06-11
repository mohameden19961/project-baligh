# Répartition du travail — Projet Baligh
> Organisation **Feature-Based** (corrigée) · 4 membres · 53 fichiers

---


## Vue d'ensemble

| Membre | N° | Feature principale | Fichiers 
|--------|----|--------------------|----------|
| **Abdy Mohameden** | 24068 | Architecture + Signalements & Carte | 14 | 
| Abdselam Abdelvetah | 24139 |  Chat & Messagerie + Reports UI | 13 |
| Ahmedou Bedou | 24157 | Alertes, Notifications & Users | 13 | 
| Hassen Oumeiry | 24238 | Auth, Profil & i18n | 13 | 

---

## Répartition détaillée

###  Abdy Mohameden (24068) — Architecture + Signalements & Carte 
> Charge la plus lourde : socle technique sur lequel tout le monde s'appuie

**Core / Architecture (partagé par tous)**
| Fichier |
|---------|
| `main.dart` |
| `utils/app_constants.dart` |
| `utils/supabase_config.dart` |
| `controllers/navigation_provider.dart` |
| `controllers/theme_provider.dart` |
| `controllers/locale_provider.dart` |

**Feature : Signalements & Carte**
| Fichier |
|---------|
| `core/models/report_model.dart` |
| `core/database/report_dao.dart` |
| `core/services/report_service.dart` |
| `core/services/report_service_db.dart` |
| `core/services/location_service.dart` |
| `controllers/report_controller.dart` |
| `controllers/map_provider.dart` |
| `utils/report_category_meta.dart` |

---

###  Abdselam Abdelvetah (24139) — Chat & Messagerie + Reports UI
> Feature Chat complète + vues Reports + widgets partagés

**Shared Widgets**
| Fichier |
|---------|
| `views/main_layout.dart` |
| `widgets/report_card.dart` |
| `widgets/empty_state.dart` |
| `widgets/google_button.dart` |

**Feature : Chat**
| Fichier |
|---------|
| `core/models/message_model.dart` |
| `core/database/message_dao.dart` |
| `controllers/chat_controller.dart` |
| `views/chat/chat_view.dart` |
| `views/chat/conversations_view.dart` |

**Feature : Reports UI**
| Fichier |
|---------|
| `views/home/home_view.dart` |
| `views/add_report/add_report_view.dart` |
| `controllers/add_report_controller.dart` |
| `views/report_detail/report_detail_view.dart` |

---

### 

### Ahmedou Bedou (24157) — Alertes, Notifications & Users
> Feature Alertes + Notifications + gestion des utilisateurs et votes

**Feature : Alertes & Notifications**
| Fichier |
|---------|
| `core/models/notification_model.dart` |
| `core/database/notification_dao.dart` |
| `core/services/notification_service.dart` |
| `controllers/alert_controller.dart` |
| `views/alerts/alerts_view.dart` |
| `views/emergency/emergency_numbers_view.dart` |

**Feature : Users & Votes**
| Fichier |
|---------|
| `core/models/user_model.dart` |
| `core/database/user_dao.dart` |
| `core/services/auth_service.dart` |
| `views/my_reports/my_reports_view.dart` |
| `views/map/map_view.dart` |
| `core/database/vote_dao.dart` |
| `core/models/vote_model.dart` |

---

### Hassen Oumeiry (24238) — Auth, Profil & i18n 
> Feature Auth & Profil complète + toute la localisation centralisée

** Feature : Auth & Profil**
| Fichier |
|---------|
| `controllers/auth_controller.dart` |
| `views/auth/login_view.dart` |
| `views/auth/register_view.dart` |
| `views/account/account_view.dart` |
| `views/settings/settings_view.dart` |
| `views/splash/splash_view.dart` |

** i18n / Localisation (centralisée)**
| Fichier |
|---------|
| `l10n/app_en.arb` |
| `l10n/app_ar.arb` |
| `l10n/app_fr.arb` |
| `l10n/app_localizations.dart` |
| `l10n/app_localizations_en.dart` |
| `l10n/app_localizations_ar.dart` |
| `l10n/app_localizations_fr.dart` |

---

**Total : 53 fichiers · 4 membres · Organisation Feature-Based · Projet Baligh**

