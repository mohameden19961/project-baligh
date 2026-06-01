// MVC - View
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/vote_model.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/report_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/report_controller.dart';
import '../../utils/report_category_meta.dart';
import '../chat/chat_view.dart';
import '../chat/conversations_view.dart';

class ReportDetailView extends StatefulWidget {
  const ReportDetailView({super.key, required this.reportId});

  final int reportId;

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  bool _voteFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_voteFetched) {
      _voteFetched = true;
      final userId = context.read<AuthProvider>().currentUserId;
      if (userId != null) {
        context.read<ReportProvider>().fetchUserVote(widget.reportId, userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        final report = provider.getById(widget.reportId);
        if (report == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.reportDetailTitle)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64,
                      color: theme.colorScheme.error.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.unknownError,
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          );
        }

        final meta = ReportCategoryMeta.of(report.category);
        final categoryLabel = ReportCategoryMeta.label(report.category, l10n);
        final statusColor = _statusColor(report.status);
        final statusLabel = _statusLabel(report.status, l10n);
        final currentUserId =
            context.read<AuthProvider>().currentUserId;
        final isOwner = currentUserId != null && report.userId == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.reportDetailTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: () {
                  final currentUserId =
                      context.read<AuthProvider>().currentUserId;
                  if (report.userId == currentUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ConversationsView(reportId: report.id!),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatView(
                          reportId: report.id!,
                          otherUserId: report.userId!,
                        ),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareReport(report, l10n),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _HeaderSection(
                report: report,
                meta: meta,
                categoryLabel: categoryLabel,
                statusColor: statusColor,
                statusLabel: statusLabel,
                theme: theme,
              ),
              if (report.photoUrl != null)
                _PhotoCard(photoUrl: report.photoUrl!, theme: theme),
              _InfoSection(report: report, l10n: l10n, theme: theme),
              _DescriptionSection(
                  description: report.description, theme: theme),
              _CredibilitySection(
                  report: report, l10n: l10n, theme: theme),
              _ActionButtons(
                report: report,
                l10n: l10n,
                theme: theme,
                userVote: provider.userVoteFor(widget.reportId),
                isOwner: isOwner,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(ReportStatus status) => switch (status) {
        ReportStatus.pending => const Color(0xFFF9A825),
        ReportStatus.validated => const Color(0xFF2E7D32),
        ReportStatus.falseReport => const Color(0xFFC62828),
      };

  String _statusLabel(ReportStatus status, AppLocalizations l10n) =>
      switch (status) {
        ReportStatus.pending => l10n.statusPending,
        ReportStatus.validated => l10n.statusValidated,
        ReportStatus.falseReport => l10n.statusFalseReport,
      };

  void _shareReport(ReportModel report, AppLocalizations l10n) {
    final category = ReportCategoryMeta.label(report.category, l10n);
    final address = report.location.address ??
        '${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}';
    final date =
        '${report.createdAt.year}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.day.toString().padLeft(2, '0')}';
    final total = report.confirmCount + report.denyCount;
    final cred = total > 0 ? (report.confirmCount / total * 100).round() : 0;
    final lat = report.location.latitude.toStringAsFixed(6);
    final lng = report.location.longitude.toStringAsFixed(6);
    final text = '🚨 تنبيه من تطبيق بلّغ\n'
        '━━━━━━━━━━━━━━\n'
        '📌 النوع: $category\n'
        '📍 الموقع: $address\n'
        '🗓️ التاريخ: $date\n'
        '━━━━━━━━━━━━━━\n'
        '✅ ${report.confirmCount} تأكيد | ❌ ${report.denyCount} رفض\n'
        '🔵 المصداقية: $cred%\n'
        '━━━━━━━━━━━━━━\n'
        '🗺️ افتح على الخريطة:\n'
        'https://www.google.com/maps?q=$lat,$lng\n'
        '\n'
        'حمّل تطبيق بلّغ وساهم في حماية مجتمعك 🇲🇷';
    Share.share(text);
  }
}

Future<void> openGoogleMaps(double lat, double lng) async {
  final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.report,
    required this.meta,
    required this.categoryLabel,
    required this.statusColor,
    required this.statusLabel,
    required this.theme,
  });

  final ReportModel report;
  final ReportCategoryMeta meta;
  final String categoryLabel;
  final Color statusColor;
  final String statusLabel;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: meta.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: meta.color.withOpacity(0.25), width: 1.5),
            ),
            child: Icon(meta.icon, color: meta.color, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            categoryLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: _formatDate(report.createdAt, theme),
            theme: theme,
          ),
          if (report.location.address != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.location_on_rounded,
              text: report.location.address!,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt, ThemeData theme) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.45)),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photoUrl, required this.theme});

  final String photoUrl;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        photoUrl,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 240,
          color: theme.colorScheme.error.withOpacity(0.05),
          child: Center(
            child: Icon(Icons.broken_image_rounded,
                size: 48, color: theme.colorScheme.error.withOpacity(0.35)),
          ),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 240,
            color: theme.colorScheme.surface,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.l10n,
    required this.theme,
    required this.report,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoField(
            label: l10n.reportDetailCategory,
            value: ReportCategoryMeta.label(report.category, l10n),
            icon: ReportCategoryMeta.of(report.category).icon,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoField(
            label: l10n.reportDetailDate,
            value:
                '${report.createdAt.year}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.day.toString().padLeft(2, '0')}',
            icon: Icons.calendar_today_rounded,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoField(
            label: l10n.reportDetailLocation,
            value: report.location.address ??
                '${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}',
            icon: Icons.location_on_rounded,
            theme: theme,
            onTap: () => openGoogleMaps(report.location.latitude, report.location.longitude),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(icon, size: 20,
            color: theme.colorScheme.primary.withOpacity(0.70)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: onTap != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    decoration:
                        onTap != null ? TextDecoration.underline : null,
                  )),
            ],
          ),
        ),
      ],
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.description,
    required this.theme,
  });

  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 20,
                  color: theme.colorScheme.primary.withOpacity(0.70)),
              const SizedBox(width: 10),
              Text(l10n.reportDetailDescription,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.60),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CredibilitySection extends StatelessWidget {
  const _CredibilitySection({
    required this.report,
    required this.l10n,
    required this.theme,
  });

  final ReportModel report;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final score = report.credibilityScore;
    final confidence = score.confidenceRatio;
    final barColor = confidence > 0.70
        ? const Color(0xFF16A34A)
        : confidence > 0.40
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 20,
                  color: theme.colorScheme.primary.withOpacity(0.70)),
              const SizedBox(width: 10),
              Text(l10n.reportDetailCredibility,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.60),
                  )),
              const Spacer(),
              Text(
                '${score.confirmations}/${score.rejections}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.totalVotes > 0 ? confidence : null,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _VoteChip(
                icon: Icons.check_circle_rounded,
                count: score.confirmations,
                color: const Color(0xFF2E7D32),
                label: l10n.reportDetailVoteConfirm,
              ),
              const SizedBox(width: 8),
              _VoteChip(
                icon: Icons.cancel_rounded,
                count: score.rejections,
                color: const Color(0xFFC62828),
                label: l10n.reportDetailVoteReject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteChip extends StatelessWidget {
  const _VoteChip({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.report,
    required this.l10n,
    required this.theme,
    required this.userVote,
    required this.isOwner,
  });

  final ReportModel report;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoteType? userVote;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: theme.colorScheme.outline.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.45)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.reportDetailVoteOwnReport,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _VoteButton(
                icon: Icons.check_circle_rounded,
                label: l10n.reportDetailVoteConfirm,
                color: const Color(0xFF2E7D32),
                isActive: userVote == VoteType.confirm,
                onTap: () => _vote(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VoteButton(
                icon: Icons.cancel_rounded,
                label: l10n.reportDetailVoteReject,
                color: const Color(0xFFC62828),
                isActive: userVote == VoteType.deny,
                onTap: () => _vote(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => openGoogleMaps(report.location.latitude, report.location.longitude),
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(l10n.reportDetailOpenMap),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _vote(BuildContext context, bool isConfirmation) async {
    final provider = context.read<ReportProvider>();
    final userId = context.read<AuthProvider>().currentUserId ?? '';
    final success = await provider.updateCredibility(
      reportId: report.id!,
      isConfirmation: isConfirmation,
      userId: userId,
    );
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(success
                ? l10n.reportDetailVoteSuccess
                : l10n.reportDetailVoteError),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : color.withOpacity(0.12),
        foregroundColor: isActive ? Colors.white : color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isActive
              ? BorderSide.none
              : BorderSide(color: color.withOpacity(0.35)),
        ),
        elevation: isActive ? 2 : 0,
        shadowColor: isActive ? color.withOpacity(0.4) : Colors.transparent,
      ),
    );
  }
}
