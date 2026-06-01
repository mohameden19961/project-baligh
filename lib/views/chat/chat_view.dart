import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/app_localizations.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.reportId,
    required this.otherUserId,
    this.otherUsername,
  });

  final int reportId;
  final String otherUserId;
  final String? otherUsername;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = context.read<AuthProvider>().currentUserId!;
      context
          .read<ChatProvider>()
          .loadConversation(widget.reportId, userId, widget.otherUserId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final userId = context.read<AuthProvider>().currentUserId!;
    await context
        .read<ChatProvider>()
        .sendMessage(widget.reportId, userId, widget.otherUserId, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername ?? ''),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          final messages = chat.messages;
          if (chat.isLoading && messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.chatNoMessages,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.45),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) =>
                            _MessageBubble(message: messages[i], theme: theme),
                      ),
              ),
              _InputBar(
                controller: _controller,
                onSend: _send,
                l10n: l10n,
                theme: theme,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.theme});
  final dynamic message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUserId;
    final isMe = message.senderId == userId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
            ),
            child: Text(message.content,
                style: TextStyle(color: textColor, fontSize: 14)),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.l10n,
    required this.theme,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  filled: true,
                  fillColor:
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
