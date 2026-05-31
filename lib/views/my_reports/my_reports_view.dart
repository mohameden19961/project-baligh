// MVC - View
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/models/report_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/report_controller.dart';
import '../../utils/report_category_meta.dart';
import '../../utils/supabase_config.dart';
import '../../widgets/report_card.dart';
import '../add_report/add_report_view.dart';
import '../report_detail/report_detail_view.dart';

class MyReportsView extends StatefulWidget {
  const MyReportsView({super.key});

  @override
  State<MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<MyReportsView> {
  ReportStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.myReportsTitle),
        actions: [
          if (context.watch<ReportProvider>().filteredReports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: l10n.myReportsFilter,
              onPressed: () => _showFilterSheet(context, l10n),
            ),
        ],
      ),
      body: Consumer2<ReportProvider, AuthProvider>(
        builder: (context, provider, auth, _) {
          final userId = auth.currentUserId;
          final reports = provider.allReports
              .where((r) => r.userId == userId)
              .toList();
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 72,
                        color: theme.colorScheme.primary.withOpacity(0.25)),
                    const SizedBox(height: 16),
                    Text(l10n.myReportsEmpty,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddReportView()),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text('بلاغ جديد'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filtered = _selectedStatus == null
              ? reports
              : reports.where((r) => r.status == _selectedStatus).toList();

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => provider.fetchReports(silent: true),
                color: theme.colorScheme.primary,
                child: Column(
                  children: [
                    if (_selectedStatus != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            Text(_statusLabel(_selectedStatus!, l10n),
                                style: theme.textTheme.labelLarge),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => setState(() => _selectedStatus = null),
                              icon: const Icon(Icons.close, size: 16),
                              label: Text(l10n.myReportsAll),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final report = filtered[index];
                      final isOwner = report.userId == userId;
                      return ReportCard(
                        key: ValueKey(report.id ?? index),
                        report: report,
                        animationDelay: Duration(milliseconds: 60 * index),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDetailView(reportId: report.id!),
                          ),
                        ),
                        trailing: isOwner
                            ? _CardActions(
                                report: report,
                                theme: theme,
                                onEdit: () =>
                                    _showEditSheet(context, report, l10n),
                                onDelete: () =>
                                    _confirmDelete(context, report, l10n),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, ReportModel report, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditReportSheet(report: report, l10n: l10n),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ReportModel report, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف البلاغ'),
        content: const Text('هل أنت متأكد من حذف هذا البلاغ؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteButton,
                style: const TextStyle(color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final provider = context.read<ReportProvider>();
    final success = await provider.deleteReport(report.id!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم حذف البلاغ بنجاح' : 'فشل حذف البلاغ'),
        backgroundColor: success ? const Color(0xFF2E7D32) : Colors.red[700],
      ),
    );
    if (success) provider.fetchReports(silent: true);
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
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
              Text(l10n.myReportsFilter,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...ReportStatus.values.map((status) => ListTile(
                    leading: Icon(_statusIcon(status),
                        color: _statusColor(status)),
                    title: Text(_statusLabel(status, l10n)),
                    trailing: _selectedStatus == status
                        ? Icon(Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedStatus = status);
                      Navigator.pop(ctx);
                    },
                  )),
              if (_selectedStatus != null)
                TextButton(
                  onPressed: () {
                    setState(() => _selectedStatus = null);
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n.myReportsAll),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(ReportStatus status) => switch (status) {
        ReportStatus.pending => Icons.schedule_rounded,
        ReportStatus.validated => Icons.check_circle_rounded,
        ReportStatus.falseReport => Icons.cancel_rounded,
      };

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
}

class _CardActions extends StatelessWidget {
  const _CardActions({
    required this.report,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  final ReportModel report;
  final ThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(
          icon: Icons.edit_rounded,
          color: theme.colorScheme.primary,
          onTap: onEdit,
        ),
        const SizedBox(width: 4),
        _ActionIcon(
          icon: Icons.delete_rounded,
          color: const Color(0xFFC62828),
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _EditReportSheet extends StatefulWidget {
  const _EditReportSheet({required this.report, required this.l10n});

  final ReportModel report;
  final AppLocalizations l10n;

  @override
  State<_EditReportSheet> createState() => _EditReportSheetState();
}

class _EditReportSheetState extends State<_EditReportSheet> {
  late ReportCategory _category;
  late TextEditingController _descCtrl;
  String? _photoUrl;
  bool _photoUploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _category = widget.report.category;
    _descCtrl = TextEditingController(text: widget.report.description);
    _photoUrl = widget.report.photoUrl;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;
      setState(() => _photoUploading = true);
      final url = await SupabaseConfig.uploadReportPhoto(picked.path);
      if (mounted) {
        setState(() {
          _photoUrl = url;
          _photoUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _photoUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الصورة. حاول مرة أخرى.')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final updated = widget.report.copyWith(
      category: _category,
      description: _descCtrl.text.trim(),
      photoUrl: _photoUrl,
    );

    final provider = context.read<ReportProvider>();
    final success = await provider.editReport(widget.report.id!, updated);

    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث البلاغ بنجاح'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل تحديث البلاغ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('تعديل البلاغ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category
            Text('التصنيف',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReportCategory>(
              value: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.12)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: ReportCategory.values.map((c) {
                final meta = ReportCategoryMeta.of(c);
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(meta.icon, size: 20, color: meta.color),
                      const SizedBox(width: 10),
                      Text(ReportCategoryMeta.label(c, widget.l10n)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),

            // Description
            Text('الوصف',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: widget.l10n.reportDescriptionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.12)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Photo
            Row(
              children: [
                Text('الصورة',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                TextButton.icon(
                  onPressed: _photoUploading ? null : () => _pickPhoto(),
                  icon: _photoUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt_rounded, size: 18),
                  label: Text(_photoUrl != null ? 'تغيير الصورة' : 'إضافة صورة'),
                ),
              ],
            ),
            if (_photoUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _photoUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      size: 48),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _photoUrl = null),
                child: const Text('إزالة الصورة',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text('حفظ التعديلات',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
