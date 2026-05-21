// lib/providers/map_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller layer — owns all state for the Map screen.
// Stack: flutter_map + latlong2  (OSM — no Google Maps API key)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show IconData, Color;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';
import '../utils/report_category_meta.dart';

// ════════════════════════════════════════════════════════════════
// Default centre: Nouakchott, Mauritania
// ════════════════════════════════════════════════════════════════
const LatLng kNouakchottLatLng = LatLng(18.0735, -15.9582);

class MapProvider extends ChangeNotifier {
  // ── flutter_map controller ───────────────────────────────────────
  // Created eagerly — passed to FlutterMap via mapController parameter.
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

  // ── Camera helpers ───────────────────────────────────────────────

  /// Animate the camera to a specific report's location.
  void focusOn(ReportLocation location) {
    mapController.move(
      LatLng(location.latitude, location.longitude),
      16.0,
    );
  }

  /// Animate back to the default city-level view.
  void resetCamera() {
    mapController.move(kNouakchottLatLng, 13.0);
  }

  // ── Filtering ────────────────────────────────────────────────────

  void setCategory(ReportCategory? category) {
    if (_activeCategory == category) return;
    _activeCategory = category;
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

  List<ReportModel> filteredReports(List<ReportModel> all) {
    return all.where((r) {
      final matchesCategory =
          _activeCategory == null || r.category == _activeCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          r.description.toLowerCase().contains(_searchQuery) ||
          (r.location.address?.toLowerCase().contains(_searchQuery) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ── Selected report ──────────────────────────────────────────────

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
    mapController.move(currentPosition, 15.5);
    _isLocating = false;
    notifyListeners();
  }

  // ── Marker visuals delegate to the shared ReportCategoryMeta ─────

  static Color markerColor(ReportCategory cat) =>
      ReportCategoryMeta.of(cat).color;

  static IconData markerIcon(ReportCategory cat) =>
      ReportCategoryMeta.of(cat).icon;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}

