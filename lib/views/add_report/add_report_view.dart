// MVC - View
// lib/views/add_report/add_report_view.dart
// ─────────────────────────────────────────────────────────────────
// View layer — Step 1 of the "Add Report" multi-step wizard.
// (Screen 05 - Étape 1: Catégorie & Description)
//
// Design direction: Clean civic utility — structured, trustworthy,
// approachable. Bold category tiles on a light canvas; the selected
// tile "blooms" with a category-specific colour accent. The step
// progress bar at the top gives the user a sense of forward motion.
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models/report_model.dart';
import '../../controllers/add_report_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/map_provider.dart' show kNouakchottLatLng;
import '../../controllers/report_controller.dart';
import '../../utils/app_constants.dart';
import '../../utils/report_category_meta.dart';
import '../../utils/supabase_config.dart';

// ════════════════════════════════════════════════════════════════
// AddReportView  — the Navigator route pushed by the FAB
// ════════════════════════════════════════════════════════════════
class AddReportView extends StatelessWidget {
  const AddReportView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scope AddReportProvider to this route's lifetime only.
    return ChangeNotifierProvider(
      create: (_) => AddReportProvider(),
      child: const _AddReportScaffold(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _AddReportScaffold — the outer shell with AppBar + step routing
// ════════════════════════════════════════════════════════════════
class _AddReportScaffold extends StatelessWidget {
  const _AddReportScaffold();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // ── Audit Step 4: removed global context.watch<AddReportProvider>().
    // Only the two widgets that actually depend on provider state are
    // wrapped in Consumer below — the AppBar title, leading icon, and
    // backgroundColor never change so they don't need to rebuild.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => _confirmDiscard(context, l10n),
        ),
        title: Text(
          l10n.reportTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        // ── Consumer #1: only _StepProgressBar needs currentStepIndex ──
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<AddReportProvider>(
            builder: (_, provider, __) => _StepProgressBar(
              currentStep: provider.currentStepIndex,
              totalSteps: FormStep.values.length,
              theme: theme,
            ),
          ),
        ),
      ),
      // ── Consumer #2: AnimatedSwitcher body needs currentStep ───────
      body: Consumer<AddReportProvider>(
        builder: (_, provider, __) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(provider.currentStep),
            child: switch (provider.currentStep) {
              FormStep.category => const _Step1CategoryBody(),
              FormStep.location => const _LocationPickerBody(),
              FormStep.photo    => _Step3PhotoBody(),
              FormStep.review   => const _Step4ReviewBody(),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDiscard(
      BuildContext context, AppLocalizations l10n) async {
    final provider = context.read<AddReportProvider>();
    // If nothing selected yet, pop without confirmation.
    if (!provider.hasCategory && !provider.hasDescription) {
      Navigator.of(context).pop();
      return;
    }
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.reportTitle),
        content: Text(l10n.reportValidationCategory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.deleteButton,
              style: const TextStyle(color: Color(0xFFC62828)),
            ),
          ),
        ],
      ),
    );
    if (shouldDiscard == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

// ════════════════════════════════════════════════════════════════
// _StepProgressBar — 4-segment progress indicator in the AppBar
// ════════════════════════════════════════════════════════════════
class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.theme,
  });

  final int currentStep;
  final int totalSteps;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          // Even indices → segment, odd indices → spacer between segments
          if (i.isOdd) return const SizedBox(width: 6);
          final stepIndex = i ~/ 2;
          final isDone = stepIndex <= currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 4,
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.white
                    : Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _Step1CategoryBody — scrollable form body for Step 1
// ════════════════════════════════════════════════════════════════
class _Step1CategoryBody extends StatelessWidget {
  const _Step1CategoryBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Scrollable content ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section: Category ──────────────────────────
                _SectionLabel(
                  text: l10n.reportCategory,
                  isRequired: true,
                  theme: theme,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.reportSelectCategory,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Validation error banner ────────────────────
                Consumer<AddReportProvider>(
                  builder: (_, p, __) => AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: p.showCategoryError
                        ? _ErrorBanner(
                            message: l10n.reportValidationCategory,
                            theme: theme,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                // ── 12-category grid ───────────────────────────
                const _CategoryGrid(),

                const SizedBox(height: 28),

                // ── Section: Description ───────────────────────
                _SectionLabel(
                  text: l10n.reportDescription,
                  isRequired: false,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                const _DescriptionField(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ── Sticky bottom action bar ────────────────────────────
        const _BottomActionBar(),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CategoryGrid — 3-column grid of 6 category tiles.
// All icon/colour/label data is pulled from ReportCategoryMeta —
// the single source of truth shared with MapView and ReportCard.
// ════════════════════════════════════════════════════════════════
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AddReportProvider>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: ReportCategory.values.length,
      itemBuilder: (context, i) {
        final category = ReportCategory.values[i];
        final meta = ReportCategoryMeta.of(category);
        final label = ReportCategoryMeta.label(category, l10n);
        final isSelected = provider.selectedCategory == category;

        return _CategoryTile(
          meta: meta,
          label: label,
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            provider.selectCategory(category);
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CategoryTile — animated individual category button
// ════════════════════════════════════════════════════════════════
class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    required this.meta,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final ReportCategoryMeta meta;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.meta.color;
    final isSelected = widget.isSelected;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.colorScheme.outline.withOpacity(0.12),
              width: isSelected ? 2.0 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon container ────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.20)
                      : color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.meta.icon,
                  size: 26,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 10),
              // ── Label ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.75),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // ── Selected check dot ────────────────────────────
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _DescriptionField — multi-line text input with character counter
// ════════════════════════════════════════════════════════════════
class _DescriptionField extends StatefulWidget {
  const _DescriptionField();

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;
  int _charCount = 0;
  static const int _maxChars = 280;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final provider = context.read<AddReportProvider>();
      provider.setDescription(_controller.text);
      if (_controller.text.length != _charCount) {
        setState(() => _charCount = _controller.text.length);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isNearLimit = _charCount > _maxChars * 0.85;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          maxLength: _maxChars,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null, // We build our own counter below.
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: l10n.reportDescriptionHint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.35),
              fontSize: 14,
              height: 1.6,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 6),
        Text(
          '$_charCount / $_maxChars',
          style: TextStyle(
            fontSize: 11,
            color: isNearLimit
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withOpacity(0.35),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _BottomActionBar — sticky Next / Back buttons
// ════════════════════════════════════════════════════════════════
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<AddReportProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isFirstStep = provider.currentStepIndex == 0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Back button (hidden on step 1) ──────────────────
          if (!isFirstStep) ...[
            _OutlineActionButton(
              label: l10n.backButton,
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                HapticFeedback.selectionClick();
                provider.previousStep();
              },
              theme: theme,
            ),
            const SizedBox(width: 12),
          ],

          // ── Next / Continue button ──────────────────────────
          Expanded(
            child: _PrimaryActionButton(
              label: l10n.continueButton,
              onTap: () {
                HapticFeedback.mediumImpact();
                final advanced = provider.nextStep();
                if (!advanced) {
                  // Validation failed — shake the button.
                }
              },
              theme: theme,
              isEnabled: provider.hasCategory,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    required this.theme,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.primary;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.55)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.65),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _SectionLabel — labelled field header with optional asterisk
// ════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.text,
    required this.theme,
    this.isRequired = false,
  });

  final String text;
  final ThemeData theme;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ErrorBanner — red inline validation message
// ════════════════════════════════════════════════════════════════
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.theme});
  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LocationPickerBody — Step 2: full-screen OSM map with a centre
// pin. User drags the map; the pin stays fixed in the middle.
// Tapping "Confirm" reads the map centre and saves it to the
// AddReportProvider. Uses the FMTC-cached TileLayer (Audit Step 2).
// ════════════════════════════════════════════════════════════════
class _LocationPickerBody extends StatefulWidget {
  const _LocationPickerBody();

  @override
  State<_LocationPickerBody> createState() => _LocationPickerBodyState();
}

class _LocationPickerBodyState extends State<_LocationPickerBody> {
  late final MapController _mapController;
  LatLng _pickedPoint = kNouakchottLatLng;
  String? _detectedAddress;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoLocate());
  }

  Future<void> _autoLocate() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      _pickedPoint = LatLng(position.latitude, position.longitude);
      _mapController.move(_pickedPoint, 15.5);
      _resolveAddress();
    } catch (e) {
      debugPrint('[LocationPicker] autoLocate failed: $e');
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  bool _isLocating = false;

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _pickedPoint = LatLng(position.latitude, position.longitude);
      _mapController.move(_pickedPoint, 15.5);
      _resolveAddress();
    } catch (e) {
      debugPrint('[LocationPicker] goToMyLocation failed: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _pickedPoint = camera.center;
      _resolveAddress();
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=ar',
    );
    final client = HttpClient();
    client.userAgent = 'BalighApp/1.0';
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['display_name'] as String?;
    } catch (e) {
      debugPrint('[Nominatim] reverse geocode failed: $e');
      return null;
    } finally {
      client.close();
    }
  }

  Future<void> _resolveAddress() async {
    if (_isResolving) return;
    setState(() => _isResolving = true);
    final address = await _reverseGeocode(
      _pickedPoint.latitude,
      _pickedPoint.longitude,
    );
    if (mounted) {
      setState(() {
        _detectedAddress = address;
        _isResolving = false;
      });
    }
  }

  void _confirmLocation() {
    context.read<AddReportProvider>().setLocation(
          ReportLocation(
            latitude: _pickedPoint.latitude,
            longitude: _pickedPoint.longitude,
            address: _detectedAddress,
          ),
        );
    context.read<AddReportProvider>().nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Instruction banner ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: theme.colorScheme.primary.withOpacity(0.07),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.mapSelectLocation,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Map + centre pin ────────────────────────────────────
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: kNouakchottLatLng,
                  initialZoom: 14.0,
                  minZoom: 5.0,
                  maxZoom: 19.0,
                  onPositionChanged: _onPositionChanged,
                  onTap: (tapPosition, point) {
                    _mapController.move(point, _mapController.camera.zoom);
                  },
                ),
                children: [
                  // ── FMTC-cached OSM TileLayer (Audit Step 2) ──
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.baligh.app',
                    tileProvider: kIsWeb
                        ? NetworkTileProvider()
                        : const FMTCStore(AppConstants.osmCacheStoreName)
                            .getTileProvider(
                            loadingStrategy: BrowseLoadingStrategy.cacheFirst,
                            cachedValidDuration: Duration(days: 30),
                          ),
                    maxNativeZoom: 19,
                    errorTileCallback: (tile, error, stackTrace) {
                      debugPrint('[TileLayer] tile error: $error');
                    },
                  ),
                ],
              ),

              // ── Fixed centre pin ──────────────────────────────
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.primary.withOpacity(0.40),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: Colors.white, size: 22),
                    ),
                    // Pin shadow dot
                    Container(
                      width: 10,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              // ── My location button ────────────────────────────
              Positioned(
                right: 16,
                bottom: 24,
                child: GestureDetector(
                  onTap: _goToMyLocation,
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
                    child: _isLocating
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Detected address ───────────────────────────────────
        if (_detectedAddress != null || _isResolving)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: theme.colorScheme.primary.withOpacity(0.04),
            child: Row(
              children: [
                Icon(
                  _isResolving ? Icons.hourglass_top_rounded : Icons.location_on_rounded,
                  size: 16,
                  color: theme.colorScheme.primary.withOpacity(0.60),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isResolving ? 'جاري تحديد العنوان…' : _detectedAddress!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // ── Confirm button ──────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
              20, 14, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.08)),
            ),
          ),
          child: Row(
            children: [
              _OutlineActionButton(
                label: l10n.backButton,
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.read<AddReportProvider>().previousStep(),
                theme: theme,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryActionButton(
                  label: l10n.reportLocation,
                  onTap: _confirmLocation,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _Step3PhotoBody — Step 3: Photo (optional, skippable)
// Pick from gallery → upload to Supabase Storage → store URL.
// ════════════════════════════════════════════════════════════════
class _Step3PhotoBody extends StatefulWidget {
  @override
  State<_Step3PhotoBody> createState() => _Step3PhotoBodyState();
}

class _Step3PhotoBodyState extends State<_Step3PhotoBody> {
  Future<void> _pickFromSource(AddReportProvider provider, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      provider.setPhotoUploading(true);

      final path = picked.path;
      if (path.isEmpty) {
        provider.setPhotoUploading(false);
        return;
      }

      final url = await SupabaseConfig.uploadReportPhoto(path);
      if (url != null) {
        provider.setPhotoUrl(url);
      } else {
        provider.setPhotoUploading(false);
      }
    } catch (e) {
      provider.setPhotoUploading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التقاط الصورة. حاول مرة أخرى.')),
        );
      }
    }
  }

  void _showSourceSheet(AddReportProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, size: 28),
                title: const Text('📷 Caméra', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromSource(provider, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, size: 28),
                title: const Text('🖼️ Galerie', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromSource(provider, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<AddReportProvider>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Column(
              children: [
                if (provider.hasPhoto) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      provider.photoUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_rounded,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Change photo button ───────────────────────
                  GestureDetector(
                    onTap: provider.photoUploading
                        ? null
                        : () => _showSourceSheet(provider),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded,
                              size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            l10n.reportChangePhoto,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Remove photo ──────────────────────────────
                  TextButton(
                    onPressed: () => provider.removePhoto(),
                    child: const Text(
                      'إزالة الصورة',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ] else ...[
                  // ── Camera icon ───────────────────────────────
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 46,
                      color: theme.colorScheme.primary.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.reportPhoto,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── Add Photo button ──────────────────────────
                  GestureDetector(
                    onTap: provider.photoUploading
                        ? null
                        : () => _showSourceSheet(provider),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: provider.photoUploading
                              ? theme.colorScheme.outline
                              : theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (provider.photoUploading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          else ...[
                            Icon(Icons.camera_alt_rounded,
                                size: 20,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.reportAddPhoto,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const _BottomActionBar(),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _Step4ReviewBody — Step 4: Summary + Submit
// Shows a read-only summary of the draft and wires the submit
// button to AddReportProvider.buildDraft() → ReportProvider.addReport().
// ════════════════════════════════════════════════════════════════
class _Step4ReviewBody extends StatefulWidget {
  const _Step4ReviewBody();

  @override
  State<_Step4ReviewBody> createState() => _Step4ReviewBodyState();
}

class _Step4ReviewBodyState extends State<_Step4ReviewBody> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Capture context-dependent refs before the async gap.
    final addProvider = context.read<AddReportProvider>();
    final reportProvider = context.read<ReportProvider>();
    final authProvider = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final draft = addProvider.buildDraft().copyWith(
      userId: authProvider.currentUserId,
    );
    final success = await reportProvider.addReport(draft);

    if (!mounted) return;

    if (success) {
      // addReport()'s final notifyListeners() marks HomeView dirty in the
      // current frame. Calling navigator.pop() in that same frame causes
      // MouseTracker.updateAllDevices (scheduled by the route change) to
      // hit-test _BottomAppBarClipper.getClip() before ScaffoldGeometry is
      // set → "must only be accessed during the paint phase" assertion.
      // addPostFrameCallback lets frame N flush all pending rebuilds and
      // repaint the Scaffold; frame N+1 then pops into a clean geometry.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.reportSubmitSuccess),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        navigator.pop();
      });
    } else {
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.reportSubmitError),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<AddReportProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final reviewCategory =
        provider.selectedCategory ?? ReportCategory.infrastructure;
    final reviewMeta = ReportCategoryMeta.of(reviewCategory);

    return Column(
      children: [
        // ── Scrollable summary ──────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reportDetailTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                _ReviewRow(
                  icon: reviewMeta.icon,
                  iconColor: reviewMeta.color,
                  label: l10n.reportCategory,
                  value: ReportCategoryMeta.label(reviewCategory, l10n),
                  theme: theme,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.12),
                ),
                _ReviewRow(
                  icon: Icons.description_outlined,
                  iconColor: theme.colorScheme.primary,
                  label: l10n.reportDescription,
                  value: provider.description.isEmpty
                      ? '—'
                      : provider.description,
                  theme: theme,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.12),
                ),
                _ReviewRow(
                  icon: Icons.location_on_rounded,
                  iconColor: theme.colorScheme.primary,
                  label: l10n.reportLocation,
                  value: provider.selectedLocation != null
                      ? '${provider.selectedLocation!.latitude.toStringAsFixed(4)}, '
                          '${provider.selectedLocation!.longitude.toStringAsFixed(4)}'
                      : '—',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        // ── Submit bottom bar ───────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              _OutlineActionButton(
                label: l10n.backButton,
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _isSubmitting
                    ? () {}
                    : () {
                        HapticFeedback.selectionClick();
                        context.read<AddReportProvider>().previousStep();
                      },
                theme: theme,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SubmitButton(
                  label: l10n.reportSubmit,
                  isLoading: _isSubmitting,
                  onTap: _submit,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ReviewRow — single labelled row in the Step 4 summary card
// ════════════════════════════════════════════════════════════════
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.theme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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
// _SubmitButton — primary action button with loading state
// ════════════════════════════════════════════════════════════════
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.primary;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}

