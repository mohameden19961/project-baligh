// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Baligh';

  @override
  String get onboardingTitle1 => 'Signaler les Problèmes';

  @override
  String get onboardingDesc1 =>
      'Signalez facilement les problèmes urbains dans votre quartier.';

  @override
  String get onboardingTitle2 => 'Localisez Précisément';

  @override
  String get onboardingDesc2 =>
      'Marquez l\'emplacement exact du problème sur la carte.';

  @override
  String get onboardingTitle3 => 'Recevez des Alertes';

  @override
  String get onboardingDesc3 =>
      'Restez informé des signalements de la communauté en temps réel.';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get getStarted => 'Commencer';

  @override
  String get home => 'Accueil';

  @override
  String get map => 'Carte';

  @override
  String get alerts => 'Alertes';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get reportNow => 'Signaler maintenant';
}
