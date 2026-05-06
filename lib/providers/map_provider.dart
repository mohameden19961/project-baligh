// lib/providers/map_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller layer — owns all state for the Map screen.
// Responsibilities:
//   • Track the GoogleMapController (camera movement).
//   • Maintain active category filter and search query.
//   • Derive the visible filtered report list for marker rendering.
//   • Own the selected report (drives the bottom detail sheet).
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';

// ════════════════════════════════════════════════════════════════
// Default camera: Nouakchott, Mauritania
// ════════════════════════════════════════════════════════════════
const LatLng kNouakchottCenter = LatLng(18.0735, -15.9582);
const double kDefaultZoom = 13.0;

class MapProvider extends ChangeNotifier {
  // ── GoogleMapController ──────────────────────────────────────────

  final MapController mapController = MapController();

  // ── Filter & search state ────────────────────────────────────────
  ReportCategory? _activeCategory;
  String _searchQuery = '';

  // ── Selected report (drives the bottom preview sheet) ────────────
  ReportModel? _selectedReport;

  // ── My-location loading flag ─────────────────────────────────────
  bool _isLocating = false;

  // ── Getters ──────────────────────────────────────────────────────
  ReportCategory? get activeCategory => _activeCategory;
  String get searchQuery => _searchQuery;
  ReportModel? get selectedReport => _selectedReport;
  bool get isLocating => _isLocating;
  bool get hasActiveFilter =>
      _activeCategory != null || _searchQuery.isNotEmpty;

  // ── Map controller lifecycle ─────────────────────────────────────

  void disposeController() {
    mapController.dispose();
  }

  // ── Camera helpers ───────────────────────────────────────────────

  /// Animate the camera to a specific report's location.
Future<void> focusOn(ReportLocation location) async {
    mapController.move(
      LatLng(location.latitude, location.longitude),
      16.0,
    );
  }

  /// Animate back to the default city-level view.
void resetCamera() {
    mapController.move(kNouakchottCenter, kDefaultZoom);
  }

  // ── Filtering ────────────────────────────────────────────────────

  void setCategory(ReportCategory? category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
    // Deselect any open preview when filter changes.
    _selectedReport = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    _selectedReport = null;
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilter) return;
    _activeCategory = null;
    _searchQuery = '';
    _selectedReport = null;
    notifyListeners();
  }

  // ── Derive visible reports ───────────────────────────────────────

  /// Returns only the reports that match the active filters.
  /// Called by the View to build the Markers set.
  List<ReportModel> filteredReports(List<ReportModel> all) {
    return all.where((r) {
      final matchesCategory =
          _activeCategory == null || r.category == _activeCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          r.description.toLowerCase().contains(_searchQuery) ||
          (r.location.address
                  ?.toLowerCase()
                  .contains(_searchQuery) ??
              false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ── Selected report (marker tap / sheet) ─────────────────────────

  void selectReport(ReportModel report) {
    _selectedReport = report;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedReport == null) return;
    _selectedReport = null;
    notifyListeners();
  }

  // ── Location button ──────────────────────────────────────────────

  Future<void> goToMyLocation(LatLng? currentPosition) async {
    if (currentPosition == null) return;
    _isLocating = true;
    notifyListeners();
    
    _isLocating = false;
    notifyListeners();
  }

  // ── Marker colour per category ───────────────────────────────────
  // Maps each category to a Google Maps hue value (0-360).

static Color markerColor(ReportCategory? category) {
    switch (category) {
      case ReportCategory.roads:
        return const Color(0xFFEF6C00);
      case ReportCategory.lighting:
        return const Color(0xFFF9A825);
      case ReportCategory.waste:
        return const Color(0xFF6D4C41);
      case ReportCategory.water:
        return const Color(0xFF0277BD);
      case ReportCategory.parks:
        return const Color(0xFF388E3C);
      case ReportCategory.other:
        return const Color(0xFF7B1FA2);
      default:
        return Colors.blue; // Fallback
    }
  }
}
  // @override
  // void dispose() {
  //   disposeController();
  //   super.dispose();
  // }