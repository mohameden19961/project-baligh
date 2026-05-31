// lib/widgets/empty_state.dart
// ─────────────────────────────────────────────────────────────────
// Shared empty-state placeholder for tab views that have no data
// yet. Renders a centred decorative icon, a localized headline,
// and an optional supporting message inside the available space.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Decorative icon medallion ─────────────────────────
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.08),
                  border: Border.all(
                    color: primary.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 52, color: primary),
              ),
              const SizedBox(height: 20),

              // ── Title ──────────────────────────────────────────────
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              // ── Supporting message ─────────────────────────────────
              if (message != null) ...[
                const SizedBox(height: 10),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.60),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
