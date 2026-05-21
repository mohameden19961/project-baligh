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
  String get appTagline => 'Votre voix fait la différence';

  @override
  String get language => 'Langue';

  @override
  String get arabic => 'Arabe';

  @override
  String get french => 'Français';

  @override
  String get continueButton => 'Continuer';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get backButton => 'Retour';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get retry => 'Réessayer';

  @override
  String get navHome => 'Accueil';

  @override
  String get navMap => 'Carte';

  @override
  String get navReport => 'Signaler';

  @override
  String get navMyReports => 'Mes signalements';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get homeWelcome => 'Bienvenue sur Baligh';

  @override
  String get homeSubtitle =>
      'Contribuez à améliorer votre ville en signalant les problèmes';

  @override
  String get homeRecentReports => 'Signalements récents';

  @override
  String get homeNoReports =>
      'Aucun signalement pour l\'instant. Soyez le premier !';

  @override
  String get homeQuickReport => 'Signalement rapide';

  @override
  String get homeViewMap => 'Voir la carte';

  @override
  String get reportTitle => 'Nouveau signalement';

  @override
  String get reportCategory => 'Catégorie du problème';

  @override
  String get reportSelectCategory => 'Choisir une catégorie';

  @override
  String get reportDescription => 'Description du problème';

  @override
  String get reportDescriptionHint => 'Décrivez le problème en détail...';

  @override
  String get reportLocation => 'Localisation';

  @override
  String get reportLocationHint => 'Sélectionner sur la carte';

  @override
  String get reportPhoto => 'Photo du problème';

  @override
  String get reportAddPhoto => 'Ajouter une photo';

  @override
  String get reportChangePhoto => 'Changer la photo';

  @override
  String get reportSubmit => 'Envoyer le signalement';

  @override
  String get reportSubmitSuccess =>
      'Votre signalement a été envoyé avec succès !';

  @override
  String get reportSubmitError => 'Échec de l\'envoi. Veuillez réessayer.';

  @override
  String get reportValidationCategory => 'Veuillez choisir une catégorie';

  @override
  String get reportValidationDescription => 'Veuillez décrire le problème';

  @override
  String get reportValidationLocation => 'Veuillez indiquer la localisation';

  @override
  String get categoryRoads => 'Routes et trottoirs';

  @override
  String get categoryLighting => 'Éclairage public';

  @override
  String get categoryWaste => 'Déchets et assainissement';

  @override
  String get categoryWater => 'Eau et électricité';

  @override
  String get categoryParks => 'Parcs et espaces verts';

  @override
  String get categoryOther => 'Autre';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusResolved => 'Résolu';

  @override
  String get statusRejected => 'Rejeté';

  @override
  String get myReportsTitle => 'Mes signalements';

  @override
  String get myReportsEmpty => 'Vous n\'avez encore créé aucun signalement.';

  @override
  String get myReportsFilter => 'Filtrer';

  @override
  String get myReportsAll => 'Tous';

  @override
  String get reportDetailTitle => 'Détails du signalement';

  @override
  String get reportDetailDate => 'Date du signalement';

  @override
  String get reportDetailStatus => 'Statut';

  @override
  String get reportDetailCategory => 'Catégorie';

  @override
  String get reportDetailDescription => 'Description';

  @override
  String get reportDetailLocation => 'Localisation';

  @override
  String get mapTitle => 'Carte des signalements';

  @override
  String get mapFilterAll => 'Tous';

  @override
  String get mapLoading => 'Chargement de la carte...';

  @override
  String get mapNoLocation => 'Impossible de déterminer votre position';

  @override
  String get mapSelectLocation => 'Appuyez pour choisir l\'emplacement';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Recevoir des notifications lors de la mise à jour de vos signalements';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsContact => 'Nous contacter';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeSystem => 'Automatique';

  @override
  String get permissionLocationTitle => 'Autorisation de localisation';

  @override
  String get permissionLocationMessage =>
      'L\'application nécessite l\'accès à votre position pour localiser le problème avec précision.';

  @override
  String get permissionLocationGrant => 'Autoriser';

  @override
  String get permissionLocationDeny => 'Refuser';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navAccount => 'Profil';

  @override
  String get networkError =>
      'Impossible de se connecter au réseau. Vérifiez votre connexion Internet.';

  @override
  String get unknownError =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '1 signalement',
      zero: 'Aucun signalement',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count h',
      one: 'il y a 1 h',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count j',
      one: 'il y a 1 j',
    );
    return '$_temp0';
  }
}
