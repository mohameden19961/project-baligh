// MVC - View
// lib/views/home/home_view.dart
// ─────────────────────────────────────────────────────────────────
// View layer — Home feed screen (Screen 04 - Accueil).
// Consumes ReportProvider via Consumer<ReportProvider>.
// Zero business logic: all actions are delegated to the provider.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models/report_model.dart';
import '../../controllers/report_controller.dart';
import '../../widgets/report_card.dart';
import '../report_detail/report_detail_view.dart';
import '../emergency/emergency_numbers_view.dart';
import '../../utils/report_category_meta.dart';

// ════════════════════════════════════════════════════════════════
// HomeView
// ════════════════════════════════════════════════════════════════
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Trigger the initial data fetch after the first frame so the
    // Provider tree is fully mounted before we call notifyListeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportProvider>().fetchReports();
      }
    });
  }

  Future<void> _onRefresh() =>
      context.read<ReportProvider>().fetchReports(silent: true);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _SosFab(l10n: l10n),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar: static — no provider dependency ───────────
            _HomeAppBar(l10n: l10n, theme: theme),

            // ── Search bar: filters reports in real time ──────────
            SliverToBoxAdapter(
              child: Selector<ReportProvider, String>(
                selector: (_, p) => p.searchQuery,
                builder: (ctx, query, __) => _SearchBar(
                  query: query,
                  onChanged: (q) =>
                      ctx.read<ReportProvider>().setSearchQuery(q),
                  l10n: l10n,
                  theme: theme,
                ),
              ),
            ),

            // ── Stats bar: rebuilds only when counts change ───────
            // Selector extracts (total, pending, resolved) as a
            // record; the widget only repaints when those 3 ints
            // change, not on every status/filter notification.
            SliverToBoxAdapter(
              child: Selector<ReportProvider,
                  (int total, int pending, int validated)>(
                selector: (_, p) => (
                  p.allReports.length,
                  p.pendingReports.length,
                  p.validatedReports.length,
                ),
                builder: (_, counts, __) => _StatsBar(
                  totalCount: counts.$1,
                  pendingCount: counts.$2,
                  validatedCount: counts.$3,
                  l10n: l10n,
                  theme: theme,
                ),
              ),
            ),

            // ── Section header: fully static ──────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(l10n: l10n, theme: theme),
            ),

            // ── Category filter chips: rebuilds on activeCategory ─
            SliverToBoxAdapter(
              child: Selector<ReportProvider, ReportCategory?>(
                selector: (_, p) => p.activeCategory,
                builder: (ctx, activeCategory, __) => _CategoryFilterBar(
                  activeCategory: activeCategory,
                  onCategorySelected: (cat) =>
                      ctx.read<ReportProvider>().filterByCategory(cat),
                  l10n: l10n,
                  theme: theme,
                ),
              ),
            ),

            // ── List body: rebuilds on status + filteredReports ───
            // Consumer is appropriate here because this section
            // genuinely needs to react to every status transition
            // (loading → idle → error → idle).
            Consumer<ReportProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(child: _LoadingBody());
                }
                if (provider.status == ReportProviderStatus.error) {
                  return SliverFillRemaining(
                    child: _ErrorBody(
                      message: provider.errorMessage,
                      onRetry: () => provider.fetchReports(),
                      l10n: l10n,
                      theme: theme,
                    ),
                  );
                }
                if (provider.filteredReports.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyBody(l10n: l10n, theme: theme),
                  );
                }
                return _ReportList(
                  reports: provider.filteredReports,
                  l10n: l10n,
                );
              },
            ),

            // ── Bottom padding so last card clears the FAB ────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _HomeAppBar — SliverAppBar with gradient header
// ════════════════════════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return SliverAppBar(
      expandedHeight: 56,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGreen,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        l10n.appName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.30)),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _StatsBar — 3 stat pills: total / pending / resolved
// Audit Step 4: accepts pre-extracted int counts, not the full
// provider, so the Selector above controls rebuild granularity.
// ════════════════════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.totalCount,
    required this.pendingCount,
    required this.validatedCount,
    required this.l10n,
    required this.theme,
  });

  final int totalCount;
  final int pendingCount;
  final int validatedCount;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatPill(
              value: totalCount,
              label: l10n.myReportsAll,
              color: theme.colorScheme.primary,
            ),
            VerticalDivider(
              color: theme.colorScheme.outline.withOpacity(0.15),
              thickness: 1,
            ),
            _StatPill(
              value: pendingCount,
              label: l10n.statusPending,
              color: const Color(0xFFF9A825),
            ),
            VerticalDivider(
              color: theme.colorScheme.outline.withOpacity(0.15),
              thickness: 1,
            ),
            _StatPill(
              value: validatedCount,
              label: l10n.statusValidated,
              color: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.50),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _SectionHeader
// ════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        l10n.homeRecentReports,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CategoryFilterBar — horizontally scrollable filter chips
// Audit Step 4: accepts activeCategory + callback, not the full
// provider, so the Selector above controls rebuild granularity.
// ════════════════════════════════════════════════════════════════
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.activeCategory,
    required this.onCategorySelected,
    required this.l10n,
    required this.theme,
  });

  final ReportCategory? activeCategory;
  final ValueChanged<ReportCategory?> onCategorySelected;
  final AppLocalizations l10n;
  final ThemeData theme;

  String _label(ReportCategory? cat) =>
      cat == null ? l10n.myReportsAll : ReportCategoryMeta.label(cat, l10n);

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...ReportCategory.values];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = activeCategory == cat;

          return FilterChip(
            label: Text(_label(cat)),
            selected: isSelected,
            onSelected: (_) => onCategorySelected(cat),
            selectedColor: theme.colorScheme.primary.withOpacity(0.15),
            checkmarkColor: theme.colorScheme.primary,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.60),
            ),
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.40)
                  : theme.colorScheme.outline.withOpacity(0.15),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ReportList — SliverList with staggered entrance animation
// ════════════════════════════════════════════════════════════════
class _ReportList extends StatelessWidget {
  const _ReportList({required this.reports, required this.l10n});
  final List<ReportModel> reports;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final report = reports[index];
          return ReportCard(
            key: ValueKey(report.id ?? index),
            report: report,
            animationDelay: Duration(milliseconds: 60 * index),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailView(reportId: report.id!),
                ),
              );
            },
          );
        },
        childCount: reports.length,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LoadingBody — shimmer skeleton cards
// ════════════════════════════════════════════════════════════════
class _LoadingBody extends StatefulWidget {
  const _LoadingBody();

  @override
  State<_LoadingBody> createState() => _LoadingBodyState();
}

class _LoadingBodyState extends State<_LoadingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: 4,
        itemBuilder: (_, __) => _SkeletonCard(shimmerValue: _ctrl.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.shimmerValue});
  final double shimmerValue;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = Color.lerp(
          onSurface.withOpacity(0.06),
          onSurface.withOpacity(0.12),
          shimmerValue,
        ) ??
        onSurface.withOpacity(0.06);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _EmptyBody
// ════════════════════════════════════════════════════════════════
class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.l10n, required this.theme});
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            l10n.homeNoReports,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ErrorBody
// ════════════════════════════════════════════════════════════════
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.l10n,
    required this.theme,
  });

  final String? message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64,
                color: theme.colorScheme.error.withOpacity(0.45)),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.networkError,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _SearchBar — glass-morphism search field that filters reports
// ════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.l10n,
    required this.theme,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: query,
            selection: TextSelection.collapsed(offset: query.length),
          ),
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: l10n.homeSearchHint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.40),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.45),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                  onPressed: () => onChanged(''),
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.12),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.40),
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _SosFab — red floating action button for emergency numbers
// ════════════════════════════════════════════════════════════════
class _SosFab extends StatelessWidget {
  const _SosFab({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'sos_fab',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EmergencyNumbersView(),
          ),
        );
      },
      backgroundColor: const Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      tooltip: l10n.emergencyFabTooltip,
      child: const Icon(Icons.phone_rounded, size: 24),
    );
  }
}
