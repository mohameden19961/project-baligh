import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../core/models/report_model.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/report_category_meta.dart';
import 'chat_view.dart';

class ConversationsView extends StatefulWidget {
  const ConversationsView({super.key, this.reportId});

  final int? reportId;

  @override
  State<ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<ConversationsView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = context.read<AuthProvider>().currentUserId;
      if (userId != null) {
        context.read<ChatProvider>().loadConversations(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final chat = context.watch<ChatProvider>();

    final filtered = widget.reportId != null
        ? chat.conversations
            .where((c) => c.reportId == widget.reportId)
            .toList()
        : chat.conversations;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reportId != null
            ? l10n.chatMessagesForReport
            : l10n.chatTitle),
      ),
      body: chat.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.chatNoConversations,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final conv = filtered[i];
                    final cat = conv.reportCategory.isEmpty
                        ? ReportCategory.infrastructure
                        : ReportCategory.fromJson(conv.reportCategory);
                    final meta = ReportCategoryMeta.of(cat);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: meta.color.withOpacity(0.12),
                        child: Icon(meta.icon, color: meta.color, size: 22),
                      ),
                      title: Text(
                        conv.otherUsername,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        conv.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: conv.unreadCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatView(
                              reportId: conv.reportId,
                              otherUserId: conv.otherUserId,
                              otherUsername: conv.otherUsername,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
