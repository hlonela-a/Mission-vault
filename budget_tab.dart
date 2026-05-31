// lib/presentation/screens/mission_detail/budget_tab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/expense_model.dart';
import '../../widgets/vault_widgets.dart';

class BudgetTab extends StatelessWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const BudgetTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final expenses = repo.getExpenses(mission.id);
    final spent = expenses.fold<double>(0, (s, e) => s + e.amount);
    final remaining = mission.budgetAllocated - spent;
    final pct = Formatters.budgetUsedPercent(mission.budgetAllocated, spent);

    // Group by category
    final Map<String, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const SizedBox(height: 16),
        // Main budget cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _BudgetCard(
                label: 'Allocated',
                value: Formatters.currency(mission.budgetAllocated),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.textPrimary,
              )),
              const SizedBox(width: 10),
              Expanded(child: _BudgetCard(
                label: 'Spent',
                value: Formatters.currency(spent),
                icon: Icons.payments_outlined,
                color: AppColors.warning,
              )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _BudgetCard(
                label: 'Remaining',
                value: Formatters.currency(remaining),
                icon: Icons.savings_outlined,
                color: remaining < 0 ? AppColors.danger : AppColors.success,
              )),
              const SizedBox(width: 10),
              Expanded(child: _BudgetCard(
                label: 'Per Person',
                value: mission.travelersCount > 0
                    ? Formatters.currency(spent / mission.travelersCount)
                    : '\$0',
                icon: Icons.person_outline,
                color: AppColors.info,
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Utilisation bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Utilisation',
                      style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.dmSans(
                        color: pct > 0.9 ? AppColors.danger : AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 0.9 ? AppColors.danger : pct > 0.7 ? AppColors.warning : AppColors.gold,
                    ),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$0', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11)),
                    Text(
                      Formatters.currency(mission.budgetAllocated),
                      style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (sortedCategories.isNotEmpty) ...[
          VaultSectionHeader(title: 'Spend by Category', icon: Icons.pie_chart_outline),
          if (sortedCategories.length >= 2)
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(sortedCategories, spent),
                  centerSpaceRadius: 48,
                  sectionsSpace: 3,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ...sortedCategories.map((e) => _CategoryRow(
            category: e.key,
            amount: e.value,
            totalSpent: spent,
          )),
        ] else
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No expenses recorded yet.\nAdd expenses in the Expenses tab.',
                style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
      List<MapEntry<String, double>> cats, double total) {
    final colors = [
      AppColors.gold,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      const Color(0xFFAA60FF),
      const Color(0xFF60E0FF),
    ];
    return cats.asMap().entries.map((entry) {
      final idx = entry.key;
      final cat = entry.value;
      return PieChartSectionData(
        value: cat.value,
        color: colors[idx % colors.length],
        radius: 50,
        title: '${(cat.value / total * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.dmSans(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      );
    }).toList();
  }
}

class _BudgetCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BudgetCard({
    required this.label, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSans(color: color, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double totalSpent;

  const _CategoryRow({required this.category, required this.amount, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final pct = totalSpent > 0 ? amount / totalSpent : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  Formatters.currency(amount),
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(pct * 100).toStringAsFixed(1)}% of spend',
                style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
