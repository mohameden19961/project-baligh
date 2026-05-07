// lib/views/map/map_view.dart
// ─────────────────────────────────────────────────────────────────
// View layer — Map screen (Screen 13 - Carte des Signalements).
//
// Layout (back to front):
//   [1] Full-screen GoogleMap
//   [2] Floating top bar: search field + active-filter pill
//   [3] Horizontally-scrollable category filter chips
//   [4] My-location FAB (bottom-right)
//   [5] Sliding report preview sheet (appears on marker tap)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../providers/map_provider.dart';
import '../../widgets/report_card.dart';

// ════════════════════════════════════════════════════════════════
// MapView
// ════════════════════════════════════════════════════════════════
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with AutomaticKeepAliveClientMixin {
  // Keep tab alive so the map doesn't reload on every switch.
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Build flutter_map Marker list from the current report list ───
  List<Marker> _buildMarkers({
    required List<ReportModel> reports,
    required MapProvider mapProvider,
  }) {
    return reports.map((report) {
      final isSelected = mapProvider.selectedReport?.id == report.id;
      final color = MapProvider.markerColor(report.category);

      return Marker(
        point: LatLng(
          report.location.latitude,
          report.location.longitude,
        ),
        width: isSelected ? 48 : 38,
        height: isSelected ? 48 : 38,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            mapProvider.selectReport(report);
            mapProvider.focusOn(report.location);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: isSelected ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              MapProvider.markerIcon(report.category),
              color: Colors.white,
              size: isSelected ? 22 : 17,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      // MapProvider is scoped to this tab — not global.
      create: (_) => MapProvider(),
      child: Consumer2<ReportProvider, MapProvider>(
        builder: (context, reportProvider, mapProvider, _) {
          final visibleReports =
              mapProvider.filteredReports(reportProvider.allReports);
          final markers = _buildMarkers(
            reports: visibleReports,
            mapProvider: mapProvider,
          );

          return Scaffold(
            // No AppBar — the search bar floats over the map.
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              // Dismiss keyboard + sheet when tapping the map background.
              onTap: () {
                _searchFocus.unfocus();
                mapProvider.clearSelection();
              },
              child: Stack(
                children: [
                  // ── [1] Full-screen GoogleMap ─────────────────────
                  _BalighMap(
                    markers: markers,
                    mapProvider: mapProvider,
                  ),

                  // ── [2] Floating top search bar ───────────────────
                  _FloatingSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    mapProvider: mapProvider,
                    reportProvider: reportProvider,
                    l10n: l10n,
                    theme: theme,
                    visibleCount: visibleReports.length,
                  ),

                  // ── [3] Category filter chips ─────────────────────
                  _FilterChipRow(
                    mapProvider: mapProvider,
                    l10n: l10n,
                    theme: theme,
                  ),

                  // ── [4] My-location button ────────────────────────
                  _LocationButton(mapProvider: mapProvider, l10n: l10n),

                  // ── [5] Report preview bottom sheet ──────────────
                  if (mapProvider.selectedReport != null)
                    _ReportPreviewSheet(
                      report: mapProvider.selectedReport!,
                      onClose: mapProvider.clearSelection,
                      l10n: l10n,
                      theme: theme,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _BalighMap — flutter_map widget with FMTC-cached OSM TileLayer
// (Audit Step 2: maxConcurrent: 12, retries: 3)
// ════════════════════════════════════════════════════════════════
class _BalighMap extends StatelessWidget {
  const _BalighMap({required this.markers, required this.mapProvider});

  final List<Marker> markers;
  final MapProvider mapProvider;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapProvider.mapController,
      options: MapOptions(
        initialCenter: kNouakchottLatLng,
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 19.0,
        // Dismiss the preview sheet when the user pans the map.
        onTap: (_, __) => mapProvider.clearSelection(),
      ),
      children: [
        // ── FMTC-cached OSM tile layer (Audit Step 2) ─────────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.baligh.app',
          tileProvider: const FMTCStore('osm_cache').getTileProvider(
            loadingStrategy: BrowseLoadingStrategy.cacheFirst,
            cachedValidDuration: Duration(days: 30),
          ),
          maxNativeZoom: 19,
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('[TileLayer] tile error: $error');
          },
        ),
        // ── Report markers ────────────────────────────────────────
        MarkerLayer(
          markers: markers,
          rotate: false,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _FloatingSearchBar — glass-morphism search bar with result count
// ════════════════════════════════════════════════════════════════
class _FloatingSearchBar extends StatelessWidget {
  const _FloatingSearchBar({
    required this.controller,
    required this.focusNode,
    required this.mapProvider,
    required this.reportProvider,
    required this.l10n,
    required this.theme,
    required this.visibleCount,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final MapProvider mapProvider;
  final ReportProvider reportProvider;
  final AppLocalizations l10n;
  final ThemeData theme;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final hasQuery = mapProvider.searchQuery.isNotEmpty;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search field ──────────────────────────────────────────
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.97),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: mapProvider.setSearchQuery,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.mapSelectLocation,
                      hintStyle: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.40),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                if (hasQuery) ...[
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      mapProvider.setSearchQuery('');
                      focusNode.unfocus();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Result count pill
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$visibleCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _FilterChipRow — floats below the search bar
// ════════════════════════════════════════════════════════════════
class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.mapProvider,
    required this.l10n,
    required this.theme,
  });

  final MapProvider mapProvider;
  final AppLocalizations l10n;
  final ThemeData theme;

  // ── Category metadata for chips ────────────────────────────────
  static const _chips = [
    (null, Icons.layers_rounded),
    (ReportCategory.roads, Icons.construction_rounded),
    (ReportCategory.lighting, Icons.lightbulb_outline_rounded),
    (ReportCategory.waste, Icons.delete_outline_rounded),
    (ReportCategory.water, Icons.water_drop_outlined),
    (ReportCategory.parks, Icons.park_outlined),
    (ReportCategory.other, Icons.report_problem_outlined),
  ];

  String _label(ReportCategory? cat) => switch (cat) {
        null                    => l10n.mapFilterAll,
        ReportCategory.roads    => l10n.categoryRoads,
        ReportCategory.lighting => l10n.categoryLighting,
        ReportCategory.waste    => l10n.categoryWaste,
        ReportCategory.water    => l10n.categoryWater,
        ReportCategory.parks    => l10n.categoryParks,
        ReportCategory.other    => l10n.categoryOther,
      };

  Color _chipColor(ReportCategory? cat) => switch (cat) {
        null                    => theme.colorScheme.primary,
        ReportCategory.roads    => const Color(0xFFEF6C00),
        ReportCategory.lighting => const Color(0xFFF9A825),
        ReportCategory.waste    => const Color(0xFF6D4C41),
        ReportCategory.water    => const Color(0xFF0277BD),
        ReportCategory.parks    => const Color(0xFF388E3C),
        ReportCategory.other    => const Color(0xFF7B1FA2),
      };

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 76, // directly below the 52px search bar + 12 gap
      left: 0,
      right: 0,
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final (cat, icon) = _chips[i];
            final isSelected = mapProvider.activeCategory == cat;
            final chipColor = _chipColor(cat);

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                mapProvider.setCategory(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor
                      : theme.colorScheme.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? chipColor
                        : theme.colorScheme.outline.withOpacity(0.20),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : chipColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _label(cat),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LocationButton — bottom-right "go to my location" FAB
// ════════════════════════════════════════════════════════════════
class _LocationButton extends StatelessWidget {
  const _LocationButton({
    required this.mapProvider,
    required this.l10n,
  });

  final MapProvider mapProvider;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 180,
      right: 16,
      child: Column(
        children: [
          // ── Reset camera ─────────────────────────────────────────
          _MapIconButton(
            icon: Icons.my_location_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: pass real device location from a location service.
              mapProvider.resetCamera();
            },
            theme: theme,
            isLoading: mapProvider.isLocating,
          ),
          const SizedBox(height: 10),
          // ── Clear filters (only when active) ─────────────────────
          if (mapProvider.hasActiveFilter)
            _MapIconButton(
              icon: Icons.filter_alt_off_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                mapProvider.clearFilters();
              },
              theme: theme,
              accent: theme.colorScheme.error,
            ),
        ],
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.isLoading = false,
    this.accent,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isLoading;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.10),
          ),
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, size: 22, color: color),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ReportPreviewSheet — slides up from the bottom on marker tap.
// Uses AnimatedPositioned so it animates in/out smoothly.
// ════════════════════════════════════════════════════════════════
class _ReportPreviewSheet extends StatelessWidget {
  const _ReportPreviewSheet({
    required this.report,
    required this.onClose,
    required this.l10n,
    required this.theme,
  });

  final ReportModel report;
  final VoidCallback onClose;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: _SheetEntrance(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header: category + close button ───────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      l10n.mapTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Report card (reusing the shared widget) ───────────
              ReportCard(
                report: report,
                onTap: () {
                  // TODO: Navigate to ReportDetailView once built.
                },
              ),

              // ── Action buttons ────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding + 16),
                child: Row(
                  children: [
                    // Confirm vote
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.check_circle_outline_rounded,
                        label: '${l10n.statusResolved} (${report.credibilityScore.confirmations})',
                        color: const Color(0xFF2E7D32),
                        onTap: () {
                          // TODO: wire to reportProvider.updateCredibility
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Reject vote
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.cancel_outlined,
                        label: '${l10n.statusRejected} (${report.credibilityScore.rejections})',
                        color: const Color(0xFFC62828),
                        onTap: () {
                          // TODO: wire to reportProvider.updateCredibility
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slide-up entrance animation for the preview sheet ─────────────
class _SheetEntrance extends StatefulWidget {
  const _SheetEntrance({required this.child});
  final Widget child;

  @override
  State<_SheetEntrance> createState() => _SheetEntranceState();
}

class _SheetEntranceState extends State<_SheetEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Vote button used inside the preview sheet ──────────────────────
class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
