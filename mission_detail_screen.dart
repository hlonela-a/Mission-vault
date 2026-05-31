// lib/presentation/screens/mission_detail/mission_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../widgets/vault_widgets.dart';
import 'budget_tab.dart';
import 'quotations_tab.dart';
import 'expenses_tab.dart';
import 'risks_tab.dart';
import 'packing_tab.dart';
import 'activities_tab.dart';

class MissionDetailScreen extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;

  const MissionDetailScreen({super.key, required this.mission, required this.repo});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MissionModel _mission;

  final _tabs = [
    ('Budget',     Icons.account_balance_wallet_outlined),
    ('Quotes',     Icons.receipt_long_outlined),
    ('Expenses',   Icons.payments_outlined),
    ('Risks',      Icons.warning_amber_outlined),
    ('Packing',    Icons.luggage_outlined),
    ('Activities', Icons.event_note_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {
    _mission = widget.repo.getMission(_mission.id) ?? _mission;
  });

  Future<void> _deleteMission() async {
    final confirm = await showDeleteConfirm(context, 'Mission');
    if (confirm && mounted) {
      await widget.repo.deleteMission(_mission.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _changeStatus() async {
    final statuses = ['Planning', 'Active', 'Completed', 'Cancelled'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Change Status', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...statuses.map((s) => ListTile(
            title: Text(s, style: GoogleFonts.dmSans(color: AppColors.textPrimary)),
            trailing: _mission.status == s ? const Icon(Icons.check, color: AppColors.gold) : null,
            onTap: () => Navigator.pop(ctx, s),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (picked != null) {
      final updated = _mission.copyWith(status: picked);
      await widget.repo.updateMission(updated);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spent = widget.repo.getTotalSpent(_mission.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                onPressed: _changeStatus,
                tooltip: 'Change status',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: _deleteMission,
                tooltip: 'Delete mission',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(spent),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.gold,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
                dividerColor: AppColors.border,
                tabs: _tabs.map((t) => Tab(
                  child: Row(
                    children: [
                      Icon(t.$2, size: 14),
                      const SizedBox(width: 6),
                      Text(t.$1),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            BudgetTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
            QuotationsTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
            ExpensesTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
            RisksTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
            PackingTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
            ActivitiesTab(mission: _mission, repo: widget.repo, onRefresh: _refresh),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(double spent) {
    final remaining = _mission.budgetAllocated - spent;
    final pct = Formatters.budgetUsedPercent(_mission.budgetAllocated, spent);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0F18), Color(0xFF080A0F)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_mission.coverEmoji ?? '✈️', style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mission.name,
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 4),
                        Text(_mission.destination,
                          style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: _mission.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Allocated',
                  value: Formatters.compactCurrency(_mission.budgetAllocated),
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _HeroStat(
                  label: 'Spent',
                  value: Formatters.compactCurrency(spent),
                  color: AppColors.warning,
                ),
              ),
              Expanded(
                child: _HeroStat(
                  label: 'Remaining',
                  value: Formatters.compactCurrency(remaining),
                  color: remaining < 0 ? AppColors.danger : AppColors.success,
                ),
              ),
              Expanded(
                child: _HeroStat(
                  label: 'Depart',
                  value: Formatters.daysRemaining(_mission.departureDate),
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(pct > 0.9 ? AppColors.danger : AppColors.gold),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HeroStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.dmSans(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
      ],
    );
  }
}

// ── Tab bar persistent header delegate ───────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override double get minExtent => tabBar.preferredSize.height + 1;
  @override double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => old.tabBar != tabBar;
}
