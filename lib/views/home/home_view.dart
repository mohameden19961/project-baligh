// lib/views/home/home_view.dart
// ─────────────────────────────────────────────────────────────────
// View layer — Home feed screen (Screen 04 - Accueil).
// Consumes ReportProvider via Consumer<ReportProvider>.
// Zero business logic: all actions are delegated to the provider.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card.dart';

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
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Collapsing App Bar ────────────────────────────
                _HomeAppBar(l10n: l10n, theme: theme),

                // ── Stats summary bar ─────────────────────────────
                SliverToBoxAdapter(
                  child: _StatsBar(provider: provider, l10n: l10n, theme: theme),
                ),

                // ── Section header ────────────────────────────────
                SliverToBoxAdapter(
                  child: _SectionHeader(l10n: l10n, theme: theme),
                ),

                // ── Category filter chips ─────────────────────────
                SliverToBoxAdapter(
                  child: _CategoryFilterBar(
                      provider: provider, l10n: l10n, theme: theme),
                ),

                // ── Main content ──────────────────────────────────
                if (provider.isLoading)
                  const SliverFillRemaining(child: _LoadingBody())
                else if (provider.status == ReportProviderStatus.error)
                  SliverFillRemaining(
                    child: _ErrorBody(
                      message: provider.errorMessage,
                      onRetry: () => provider.fetchReports(),
                      l10n: l10n,
                      theme: theme,
                    ),
                  )
                else if (provider.filteredReports.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyBody(l10n: l10n, theme: theme),
                  )
                else
                  _ReportList(
                    reports: provider.filteredReports,
                    l10n: l10n,
                  ),

                // ── Bottom padding so last card clears the FAB ────
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
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
    const lightGreen = Color(0xFF388E3C);

    return SliverAppBar(
      expandedHeight: 148,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryGreen,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen, lightGreen],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.homeSubtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.30)),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _StatsBar — 3 stat pills: total / pending / resolved
// ════════════════════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.provider,
    required this.l10n,
    required this.theme,
  });

  final ReportProvider provider;
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
              value: provider.allReports.length,
              label: l10n.myReportsAll,
              color: theme.colorScheme.primary,
            ),
            VerticalDivider(
              color: theme.colorScheme.outline.withOpacity(0.15),
              thickness: 1,
            ),
            _StatPill(
              value: provider.pendingReports.length,
              label: l10n.statusPending,
              color: const Color(0xFFF9A825),
            ),
            VerticalDivider(
              color: theme.colorScheme.outline.withOpacity(0.15),
              thickness: 1,
            ),
            _StatPill(
              value: provider.resolvedReports.length,
              label: l10n.statusResolved,
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
// ════════════════════════════════════════════════════════════════
class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.provider,
    required this.l10n,
    required this.theme,
  });

  final ReportProvider provider;
  final AppLocalizations l10n;
  final ThemeData theme;

  String _label(ReportCategory? cat) => switch (cat) {
        null                    => l10n.myReportsAll,
        ReportCategory.roads    => l10n.categoryRoads,
        ReportCategory.lighting => l10n.categoryLighting,
        ReportCategory.waste    => l10n.categoryWaste,
        ReportCategory.water    => l10n.categoryWater,
        ReportCategory.parks    => l10n.categoryParks,
        ReportCategory.other    => l10n.categoryOther,
      };

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
          final isSelected = provider.activeCategory == cat;

          return FilterChip(
            label: Text(_label(cat)),
            selected: isSelected,
            onSelected: (_) => provider.filterByCategory(cat),
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
              // TODO: Navigator.push to ReportDetailView once built.
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
