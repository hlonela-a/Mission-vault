// lib/presentation/screens/mission_detail/activities_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/activity_model.dart';
import '../../widgets/vault_widgets.dart';

class ActivitiesTab extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const ActivitiesTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  State<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<ActivitiesTab> {
  List<ActivityModel> get _activities => widget.repo.getActivities(widget.mission.id);
  void _refresh() => setState(() {});

  Future<void> _addActivity() async {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? scheduledDate;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                )),
                Text('Add Activity', style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleCtrl,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Activity Title'),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: scheduledDate ?? widget.mission.departureDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(
                            primary: AppColors.gold, surface: AppColors.surfaceCard,
                            onSurface: AppColors.textPrimary)),
                          child: child!,
                        ),
                      );
                      if (d != null) setModal(() => scheduledDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Date', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(scheduledDate != null ? Formatters.date(scheduledDate) : 'Pick date',
                          style: GoogleFonts.dmSans(
                            color: scheduledDate != null ? AppColors.textPrimary : AppColors.textMuted,
                            fontSize: 13)),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 10),
                  SizedBox(width: 100, child: TextFormField(
                    controller: timeCtrl,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Time', hintText: '09:00'),
                  )),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: locationCtrl,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 16)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Cost (optional)',
                    prefixIcon: Icon(Icons.attach_money, size: 16)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await widget.repo.addActivity(
                      missionId: widget.mission.id,
                      title: titleCtrl.text.trim(),
                      scheduledDate: scheduledDate,
                      time: timeCtrl.text.trim().isEmpty ? null : timeCtrl.text.trim(),
                      cost: double.tryParse(costCtrl.text.trim()),
                      location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refresh();
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('ADD ACTIVITY'),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _activities;
    final completed = activities.where((a) => a.isCompleted).length;
    final totalCost = activities.fold<double>(0, (s, a) => s + (a.cost ?? 0));

    // Group by date
    final Map<String, List<ActivityModel>> grouped = {};
    for (final a in activities) {
      final key = a.scheduledDate != null ? Formatters.date(a.scheduledDate) : 'Unscheduled';
      grouped.putIfAbsent(key, () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        VaultSectionHeader(
          title: 'Activities ($completed/${activities.length})',
          icon: Icons.event_note_outlined,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (totalCost > 0)
              Text(Formatters.currency(totalCost), style: GoogleFonts.dmSans(
                color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
              onPressed: _addActivity,
            ),
          ]),
        ),
        if (activities.isEmpty)
          EmptyStateWidget(
            icon: Icons.event_note_outlined,
            title: 'No Activities Planned',
            subtitle: 'Build your mission itinerary',
            actionLabel: 'Add Activity',
            onAction: _addActivity,
          )
        else ...[
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldDim.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.goldDim.withOpacity(0.3)),
                  ),
                  child: Text(entry.key, style: GoogleFonts.dmSans(
                    color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            ...entry.value.map((a) => _ActivityCard(
              activity: a,
              onToggle: () async {
                await widget.repo.toggleActivity(a.id);
                _refresh();
              },
              onDelete: () async {
                await widget.repo.deleteActivity(a.id);
                _refresh();
              },
            )),
          ],
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActivityCard({required this.activity, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: activity.isCompleted ? AppColors.surfaceElevated : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activity.isCompleted ? AppColors.success.withOpacity(0.3) : AppColors.border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activity.isCompleted ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: activity.isCompleted ? AppColors.success : AppColors.border,
                    width: 1.5),
                ),
                child: activity.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (activity.time != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldDim.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(activity.time!, style: GoogleFonts.spaceMono(
                    color: AppColors.gold, fontSize: 10)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(activity.title, style: GoogleFonts.dmSans(
                color: activity.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 14, fontWeight: FontWeight.w500,
                decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
              ))),
            ]),
            if (activity.location != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 12),
                const SizedBox(width: 4),
                Text(activity.location!, style: GoogleFonts.dmSans(
                  color: AppColors.textMuted, fontSize: 11)),
              ]),
            ],
            if (activity.notes != null) ...[
              const SizedBox(height: 4),
              Text(activity.notes!, style: GoogleFonts.dmSans(
                color: AppColors.textMuted, fontSize: 11)),
            ],
          ])),
          if (activity.cost != null && activity.cost! > 0) ...[
            const SizedBox(width: 8),
            Text(Formatters.currency(activity.cost!), style: GoogleFonts.dmSans(
              color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ]),
      ),
    );
  }
}
