// lib/widgets/report_card.dart
// ─────────────────────────────────────────────────────────────────
// Reusable widget layer — a single report card for the Home feed.
// Displays: category icon + colour, title, elapsed time,
// location, description excerpt, status chip, credibility score.
// Zero business logic — pure presentation.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../l10n/app_localizations.dart';
import '../utils/report_category_meta.dart';

// ════════════════════════════════════════════════════════════════
// PUBLIC: ReportCard
// ════════════════════════════════════════════════════════════════
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.trailing,
    this.animationDelay = Duration.zero,
  });

  final ReportModel report;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Stagger delay for the entrance animation driven by the list builder.
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    return _AnimatedReportCard(
      report: report,
      onTap: onTap,
      trailing: trailing,
      animationDelay: animationDelay,
    );
  }
}

// ── Animated wrapper keeps entrance logic out of the card itself ──
class _AnimatedReportCard extends StatefulWidget {
  const _AnimatedReportCard({
    required this.report,
    required this.onTap,
    this.trailing,
    required this.animationDelay,
  });

  final ReportModel report;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Duration animationDelay;

  @override
  State<_AnimatedReportCard> createState() => _AnimatedReportCardState();
}

class _AnimatedReportCardState extends State<_AnimatedReportCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.animationDelay, () {
      if (mounted) _ctrl.forward();
    });
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
      child: SlideTransition(
        position: _slide,
        child: _ReportCardBody(
          report: widget.report,
          onTap: widget.onTap,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ReportCardBody — the actual card UI
// ════════════════════════════════════════════════════════════════
class _ReportCardBody extends StatelessWidget {
  const _ReportCardBody({required this.report, this.onTap, this.trailing});

  final ReportModel report;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final meta = ReportCategoryMeta.of(report.category);
    final categoryLabel = ReportCategoryMeta.label(report.category, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: meta.color.withOpacity(0.08),
          highlightColor: meta.color.withOpacity(0.04),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.08),
              ),
              // Subtle left accent stripe using the category colour.
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  meta.color.withOpacity(0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.25],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: icon + header + status chip ───────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryIcon(meta: meta),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category label + status chip on same row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    categoryLabel,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusChip(
                                  status: report.status,
                                  l10n: l10n,
                                ),
                                if (trailing != null) ...[
                                  const SizedBox(width: 6),
                                  trailing!,
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Elapsed time
                            _ElapsedTime(
                              createdAt: report.createdAt,
                              l10n: l10n,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Description excerpt ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.70),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const _CardDivider(),

                // ── Bottom row: location + credibility ────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    children: [
                      // Location
                      Expanded(
                        child: _LocationRow(
                          location: report.location,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Credibility score
                      _CredibilityBadge(
                        score: report.credibilityScore,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CategoryIcon — coloured circle with category icon inside
// ════════════════════════════════════════════════════════════════
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.meta});
  final ReportCategoryMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: meta.color.withOpacity(0.25), width: 1),
      ),
      child: Icon(meta.icon, color: meta.color, size: 24),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _StatusChip — coloured pill for report status
// ════════════════════════════════════════════════════════════════
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});
  final ReportStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ReportStatus.pending     => (l10n.statusPending,     const Color(0xFFFFF8E1), const Color(0xFFF9A825)),
      ReportStatus.validated   => (l10n.statusValidated,   const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      ReportStatus.falseReport => (l10n.statusFalseReport, const Color(0xFFFFEBEE), const Color(0xFFC62828)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _ElapsedTime — "3 hours ago" / "منذ 3 ساعات"
// ════════════════════════════════════════════════════════════════
class _ElapsedTime extends StatelessWidget {
  const _ElapsedTime({
    required this.createdAt,
    required this.l10n,
    required this.theme,
  });

  final DateTime createdAt;
  final AppLocalizations l10n;
  final ThemeData theme;

  String _format() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes < 1 ? 1 : diff.inMinutes;
      return l10n.timeAgoMinutes(m);
    } else if (diff.inHours < 24) {
      return l10n.timeAgoHours(diff.inHours);
    } else {
      return l10n.timeAgoDays(diff.inDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.40),
        ),
        const SizedBox(width: 4),
        Text(
          _format(),
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _LocationRow — pin icon + address or coordinates
// ════════════════════════════════════════════════════════════════
class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location, required this.theme});
  final ReportLocation location;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final label = location.address ??
        '${location.latitude.toStringAsFixed(4)}, '
            '${location.longitude.toStringAsFixed(4)}';

    return Row(
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 14,
          color: theme.colorScheme.primary.withOpacity(0.70),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CredibilityBadge — green checks + red X votes display
// ════════════════════════════════════════════════════════════════
class _CredibilityBadge extends StatelessWidget {
  const _CredibilityBadge({required this.score});
  final CredibilityScore score;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    const red = Color(0xFFC62828);
    const unverifiedGrey = Color(0xFF9E9E9E);

    if (score.totalVotes == 0) {
      return _VotePill(
        icon: Icons.help_outline_rounded,
        count: 0,
        color: unverifiedGrey,
        showCount: false,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VotePill(
          icon: Icons.check_circle_rounded,
          count: score.confirmations,
          color: green,
        ),
        const SizedBox(width: 6),
        _VotePill(
          icon: Icons.cancel_rounded,
          count: score.rejections,
          color: red,
        ),
      ],
    );
  }
}

class _VotePill extends StatelessWidget {
  const _VotePill({
    required this.icon,
    required this.count,
    required this.color,
    this.showCount = true,
  });

  final IconData icon;
  final int count;
  final Color color;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          if (showCount) ...[
            const SizedBox(width: 3),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// _CardDivider — subtle separator above the bottom info row
// ════════════════════════════════════════════════════════════════
class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.07),
      ),
    );
  }
}

