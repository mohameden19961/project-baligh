// lib/controllers/map_provider.dart
// ─────────────────────────────────────────────────────────────────
// Controller layer — owns all state for the Map screen.
// Stack: flutter_map + latlong2  (OSM — no Google Maps API key)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show IconData, Color;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/models/report_model.dart';
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
  // Queries the native device GPS via `geolocator`. Permission flow:
  //   1. checkPermission()  → existing grant status
  //   2. requestPermission() if still denied
  //   3. abort gracefully on denied / deniedForever (no crash)
  //   4. mapController.move() to the resolved coordinates
  // All async waits are wrapped between `_isLocating = true/false`
  // so the FAB shows a spinner while resolution is in flight.

  Future<void> goToMyLocation() async {
    _isLocating = true;
    notifyListeners();
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint(
            '[MapProvider] location permission $permission — aborting goToMyLocation');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      mapController.move(
        LatLng(position.latitude, position.longitude),
        15.5,
      );
    } catch (e, stack) {
      debugPrint('[MapProvider] goToMyLocation failed: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      _isLocating = false;
      notifyListeners();
    }
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

