// lib/presentation/screens/missions/missions_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../mission_detail/mission_detail_screen.dart';
import '../../widgets/vault_widgets.dart';

class MissionsScreen extends StatefulWidget {
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const MissionsScreen({super.key, required this.repo, required this.onRefresh});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Planning', 'Active', 'Completed', 'Cancelled'];

  List<MissionModel> get _filtered {
    final all = widget.repo.getAllMissions();
    if (_filter == 'All') return all;
    return all.where((m) => m.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final missions = _filtered;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            'Missions',
            style: GoogleFonts.cormorantGaramond(
              color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${missions.length} mission${missions.length != 1 ? 's' : ''}',
                style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _buildFilterChips(),
          ),
        ),
        if (missions.isEmpty)
          SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.explore_outlined,
              title: 'No Missions Found',
              subtitle: 'Create your first mission using the + button',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MissionCard(
                mission: missions[i],
                repo: widget.repo,
                onRefresh: () => setState(() {}),
              ),
              childCount: missions.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _filters.map((f) {
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: selected,
              onSelected: (_) => setState(() => _filter = f),
              backgroundColor: AppColors.surfaceElevated,
              selectedColor: AppColors.goldSubtle,
              checkmarkColor: AppColors.gold,
              labelStyle: GoogleFonts.dmSans(
                color: selected ? AppColors.gold : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: selected ? AppColors.goldDim : AppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Mission Card ──────────────────────────────────────────────────────────────

class MissionCard extends StatelessWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const MissionCard({
    super.key,
    required this.mission,
    required this.repo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final spent = repo.getTotalSpent(mission.id);
    final remaining = mission.budgetAllocated - spent;
    final pct = Formatters.budgetUsedPercent(mission.budgetAllocated, spent);

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(mission.coverEmoji ?? '✈️', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.name,
                          style: GoogleFonts.cormorantGaramond(
                            color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 13),
                            const SizedBox(width: 3),
                            Text(
                              mission.destination,
                              style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: mission.status),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 14),
              // Dates
              if (mission.departureDate != null)
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: Formatters.dateRange(mission.departureDate, mission.returnDate),
                  trailing: Text(
                    Formatters.daysRemaining(mission.departureDate),
                    style: GoogleFonts.dmSans(
                      color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.people_outline,
                text: '${mission.travelersCount} traveler${mission.travelersCount > 1 ? 's' : ''}',
              ),
              const SizedBox(height: 14),
              // Budget bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget',
                    style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.5),
                  ),
                  Text(
                    '${Formatters.currency(spent)} spent',
                    style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct > 0.9 ? AppColors.danger : AppColors.gold,
                  ),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Allocated: ${Formatters.currency(mission.budgetAllocated)}',
                    style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    'Remaining: ${Formatters.currency(remaining)}',
                    style: GoogleFonts.dmSans(
                      color: remaining < 0 ? AppColors.danger : AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _InfoRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
