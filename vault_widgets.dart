// lib/presentation/widgets/vault_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ── Section Header ────────────────────────────────────────────────────────────

class VaultSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final IconData? icon;

  const VaultSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Gold Divider ──────────────────────────────────────────────────────────────

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, AppColors.goldDim, Colors.transparent],
        ),
      ),
    );
  }
}

// ── Vault Card ────────────────────────────────────────────────────────────────

class VaultCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool highlighted;

  const VaultCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.goldDim : AppColors.border,
          width: highlighted ? 1.5 : 1,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.goldGlow, blurRadius: 12, spreadRadius: 0)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.goldSubtle,
          highlightColor: AppColors.goldSubtle,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Stat Tile ─────────────────────────────────────────────────────────────────

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final String? subValue;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                label.toUpperCase(),
                style: GoogleFonts.dmSans(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: GoogleFonts.dmSans(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'active': return AppColors.success;
      case 'completed': return AppColors.info;
      case 'cancelled': return AppColors.danger;
      case 'planning': return AppColors.gold;
      case 'open': return AppColors.danger;
      case 'mitigated': return AppColors.success;
      case 'accepted': return AppColors.warning;
      case 'closed': return AppColors.textMuted;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.dmSans(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Impact Badge ──────────────────────────────────────────────────────────────

class ImpactBadge extends StatelessWidget {
  final String impact;

  const ImpactBadge({super.key, required this.impact});

  Color get _color {
    switch (impact.toLowerCase()) {
      case 'low': return AppColors.success;
      case 'medium': return AppColors.warning;
      case 'high': return AppColors.danger;
      case 'critical': return const Color(0xFFFF3060);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        impact.toUpperCase(),
        style: GoogleFonts.dmSans(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Confirm Delete Dialog ─────────────────────────────────────────────────────

Future<bool> showDeleteConfirm(BuildContext context, String itemName) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        'Delete $itemName?',
        style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
      content: Text(
        'This action cannot be undone.',
        style: GoogleFonts.dmSans(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Cancel', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  ) ?? false;
}
