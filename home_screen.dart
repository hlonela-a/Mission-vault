// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../missions/missions_screen.dart';
import '../missions/create_mission_screen.dart';
import '../mission_detail/mission_detail_screen.dart';
import '../../widgets/vault_widgets.dart';

class HomeScreen extends StatefulWidget {
  final MissionRepository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final missions = widget.repo.getAllMissions();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(repo: widget.repo, missions: missions, onRefresh: _refresh),
          MissionsScreen(repo: widget.repo, onRefresh: _refresh),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateMissionScreen(repo: widget.repo)),
                );
                _refresh();
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        indicatorColor: AppColors.goldSubtle,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.dashboard, color: AppColors.gold),
            label: 'Command',
            tooltip: '',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined, color: AppColors.textMuted),
            selectedIcon: const Icon(Icons.explore, color: AppColors.gold),
            label: 'Missions',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Tab ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final MissionRepository repo;
  final List<MissionModel> missions;
  final VoidCallback onRefresh;

  const _DashboardTab({required this.repo, required this.missions, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final active = missions.where((m) => m.status == 'Active').toList();
    final planning = missions.where((m) => m.status == 'Planning').toList();
    final completed = missions.where((m) => m.status == 'Completed').toList();

    final totalBudget = missions.fold<double>(0, (s, m) => s + m.budgetAllocated);
    final totalSpent = missions.fold<double>(0, (s, m) => s + repo.getTotalSpent(m.id));

    final upcoming = missions
        .where((m) => m.departureDate != null && m.departureDate!.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.departureDate!.compareTo(b.departureDate!));

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(child: _buildHeroStats(active.length, planning.length, totalBudget, totalSpent)),
        if (upcoming.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: VaultSectionHeader(
              title: 'Next Mission',
              icon: Icons.rocket_launch_outlined,
            ),
          ),
          SliverToBoxAdapter(
            child: _NextMissionCard(mission: upcoming.first, repo: repo, onRefresh: onRefresh),
          ),
        ],
        SliverToBoxAdapter(
          child: VaultSectionHeader(title: 'All Missions', icon: Icons.grid_view_rounded),
        ),
        SliverToBoxAdapter(
          child: _MissionGrid(
            missions: missions.take(4).toList(),
            repo: repo,
            onRefresh: onRefresh,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildFooterStats(active.length, planning.length, completed.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      collapsedHeight: 60,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0F18), Color(0xFF080A0F)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION VAULT',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'Command Centre',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldDim, width: 1.5),
                    gradient: const RadialGradient(
                      colors: [AppColors.goldSubtle, Colors.transparent],
                    ),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStats(int active, int planning, double budget, double spent) {
    final pct = budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          // Budget overview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1608), Color(0xFF141208)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldDim, width: 1),
              boxShadow: [
                BoxShadow(color: AppColors.goldGlow, blurRadius: 20, spreadRadius: 0),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL TREASURY',
                          style: GoogleFonts.dmSans(
                            color: AppColors.goldDim,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.compactCurrency(budget),
                          style: GoogleFonts.cormorantGaramond(
                            color: AppColors.gold,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DEPLOYED',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.compactCurrency(spent),
                          style: GoogleFonts.dmSans(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${pct.toStringAsFixed(0)}% utilised',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 90 ? AppColors.danger : AppColors.gold,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Quick stats row
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Active',
                  value: active.toString(),
                  valueColor: AppColors.success,
                  icon: Icons.play_arrow_rounded,
                  subValue: 'missions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  label: 'Planning',
                  value: planning.toString(),
                  valueColor: AppColors.gold,
                  icon: Icons.edit_note_rounded,
                  subValue: 'missions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  label: 'Total',
                  value: missions.length.toString(),
                  icon: Icons.folder_outlined,
                  subValue: 'missions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStats(int active, int planning, int completed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterStat(value: active.toString(), label: 'Active', color: AppColors.success),
            _FooterStat(value: planning.toString(), label: 'Planning', color: AppColors.gold),
            _FooterStat(value: completed.toString(), label: 'Completed', color: AppColors.info),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _FooterStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(color: color, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Next Mission Card ─────────────────────────────────────────────────────────

class _NextMissionCard extends StatelessWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const _NextMissionCard({required this.mission, required this.repo, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final spent = repo.getTotalSpent(mission.id);
    final pct = Formatters.budgetUsedPercent(mission.budgetAllocated, spent);
    final days = Formatters.daysRemaining(mission.departureDate);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionDetailScreen(mission: mission, repo: repo),
          ),
        );
        onRefresh();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(mission.coverEmoji ?? '✈️', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.name,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        mission.destination,
                        style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldSubtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.goldDim),
                  ),
                  child: Text(
                    days,
                    style: GoogleFonts.dmSans(
                      color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget',
                            style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                          ),
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.dmSans(
                              color: pct > 0.9 ? AppColors.danger : AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            pct > 0.9 ? AppColors.danger : AppColors.gold,
                          ),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Formatters.currency(spent)} of ${Formatters.currency(mission.budgetAllocated)}',
                        style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${mission.travelersCount}',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'traveler${mission.travelersCount > 1 ? 's' : ''}',
                      style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mission Grid ──────────────────────────────────────────────────────────────

class _MissionGrid extends StatelessWidget {
  final List<MissionModel> missions;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const _MissionGrid({required this.missions, required this.repo, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No missions yet. Create your first mission.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: missions.length,
        itemBuilder: (ctx, i) {
          final m = missions[i];
          final spent = repo.getTotalSpent(m.id);
          final pct = Formatters.budgetUsedPercent(m.budgetAllocated, spent);
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => MissionDetailScreen(mission: m, repo: repo),
                ),
              );
              onRefresh();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.coverEmoji ?? '✈️', style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  Text(
                    m.name,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.destination,
                    style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        pct > 0.9 ? AppColors.danger : AppColors.gold,
                      ),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StatusBadge(status: m.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
