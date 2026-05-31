// MVC - Controller
// lib/controllers/add_report_controller.dart
// ─────────────────────────────────────────────────────────────────
// Scoped controller for the multi-step "Add Report" flow.
// Lives only while the AddReportView is on screen (created inside
// a ChangeNotifierProvider in the route, not in main.dart).
//
// Responsibilities:
//   Step 1 → category selection + optional description
//   Step 2 → location pin (future)
//   Step 3 → photo attachment (future)
//
// The draft is assembled here and handed off to ReportProvider
// for the actual network submission.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

// ════════════════════════════════════════════════════════════════
// ENUM: FormStep  — tracks which step the wizard is on
// ════════════════════════════════════════════════════════════════
enum FormStep { category, location, photo, review }

// ════════════════════════════════════════════════════════════════
// CLASS: AddReportProvider
// ════════════════════════════════════════════════════════════════
class AddReportProvider extends ChangeNotifier {
  // ── Draft state ──────────────────────────────────────────────────
  ReportCategory? _selectedCategory;
  String _description = '';
  ReportLocation? _selectedLocation;
  String? _photoUrl;
  bool _photoUploading = false;
  FormStep _currentStep = FormStep.category;

  // ── Validation flags ─────────────────────────────────────────────
  bool _showCategoryError = false;
  bool _showLocationError = false;

  // ── Getters ──────────────────────────────────────────────────────
  ReportCategory? get selectedCategory => _selectedCategory;
  String get description => _description;
  ReportLocation? get selectedLocation => _selectedLocation;
  String? get photoUrl => _photoUrl;
  bool get photoUploading => _photoUploading;
  FormStep get currentStep => _currentStep;
  int get currentStepIndex => _currentStep.index;
  bool get showCategoryError => _showCategoryError;
  bool get showLocationError => _showLocationError;

  bool get hasCategory => _selectedCategory != null;
  bool get hasDescription => _description.trim().isNotEmpty;
  bool get hasLocation => _selectedLocation != null;
  bool get hasPhoto => _photoUrl != null;

  /// Step 1 is complete when a category is selected.
  bool get isStep1Valid => hasCategory;

  /// Step 2 is complete when a location is pinned.
  bool get isStep2Valid => hasLocation;

  // ── Step 1: Category & Description ───────────────────────────────

  void selectCategory(ReportCategory category) {
    if (_selectedCategory == category) {
      // Tap again to deselect.
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
      _showCategoryError = false;
    }
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    // No notifyListeners needed — TextField manages its own display.
    // We only need the value at submission time.
  }

  /// Called when the user taps "Next" on Step 1.
  /// Returns true if validation passes.
  bool validateStep1() {
    if (!hasCategory) {
      _showCategoryError = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  // ── Step 2: Location ──────────────────────────────────────────────

  void setLocation(ReportLocation location) {
    _selectedLocation = location;
    _showLocationError = false;
    notifyListeners();
  }

  bool validateStep2() {
    if (!hasLocation) {
      _showLocationError = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  // ── Step 3: Photo ─────────────────────────────────────────────────

  void setPhotoUrl(String url) {
    _photoUrl = url;
    _photoUploading = false;
    notifyListeners();
  }

  void setPhotoUploading(bool value) {
    _photoUploading = value;
    notifyListeners();
  }

  void removePhoto() {
    _photoUrl = null;
    _photoUploading = false;
    notifyListeners();
  }

  // ── Navigation ────────────────────────────────────────────────────

  /// Advance to the next step if current step validates.
  bool nextStep() {
    switch (_currentStep) {
      case FormStep.category:
        if (!validateStep1()) return false;
        _currentStep = FormStep.location;
      case FormStep.location:
        if (!validateStep2()) return false;
        _currentStep = FormStep.photo;
      case FormStep.photo:
        _currentStep = FormStep.review;
      case FormStep.review:
        return false; // Submit is handled externally.
    }
    notifyListeners();
    return true;
  }

  void previousStep() {
    if (_currentStep.index == 0) return;
    _currentStep = FormStep.values[_currentStep.index - 1];
    notifyListeners();
  }

  // ── Build final model for submission ─────────────────────────────

  /// Assembles the complete [ReportModel] draft from current state.
  /// Caller (ReportProvider) assigns the id after server response.
  ///
  /// Throws [StateError] if no category is selected — the wizard
  /// gates this via [validateStep1], but the runtime guard prevents
  /// a release-mode null-pointer crash if that contract is ever broken.
  ReportModel buildDraft() {
    final category = _selectedCategory;
    if (category == null) {
      debugPrint('AddReportProvider.buildDraft: category is null — '
          'draft cannot be built. Step 1 validation was bypassed.');
      throw StateError('Cannot build report draft: category is required.');
    }
    return ReportModel(
      category: category,
      description: _description.trim(),
      location: _selectedLocation ??
          // Fallback to Nouakchott city centre if location step skipped.
          const ReportLocation(latitude: 18.0735, longitude: -15.9582),
      createdAt: DateTime.now().toUtc(),
      photoUrl: _photoUrl,
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────

  /// Wipes all draft state — call after successful submission.
  void reset() {
    _selectedCategory = null;
    _description = '';
    _selectedLocation = null;
    _photoUrl = null;
    _photoUploading = false;
    _currentStep = FormStep.category;
    _showCategoryError = false;
    _showLocationError = false;
    notifyListeners();
  }
}