// lib/presentation/screens/mission_detail/risks_tab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/risk_model.dart';
import '../../widgets/vault_widgets.dart';

class RisksTab extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const RisksTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  State<RisksTab> createState() => _RisksTabState();
}

class _RisksTabState extends State<RisksTab> {
  List<RiskModel> get _risks => widget.repo.getRisks(widget.mission.id);
  void _refresh() => setState(() {});

  Future<void> _addRisk() async {
    final titleCtrl = TextEditingController();
    final mitigationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String impact = 'Medium';
    String status = 'Open';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(
                    width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  )),
                  Text('Log Risk', style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Risk Title'),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: DropdownButtonFormField<String>(
                      value: impact,
                      decoration: const InputDecoration(labelText: 'Impact'),
                      dropdownColor: AppColors.surfaceCard,
                      style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                      items: AppConstants.riskImpacts.map((i) =>
                        DropdownMenuItem(value: i, child: Text(i))).toList(),
                      onChanged: (v) => setModal(() => impact = v!),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      dropdownColor: AppColors.surfaceCard,
                      style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                      items: AppConstants.riskStatuses.map((s) =>
                        DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setModal(() => status = v!),
                    )),
                  ]),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: mitigationCtrl,
                    maxLines: 3,
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Mitigation Plan',
                      hintText: 'How will this risk be managed?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await widget.repo.addRisk(
                        missionId: widget.mission.id,
                        title: titleCtrl.text.trim(),
                        impact: impact,
                        mitigation: mitigationCtrl.text.trim(),
                        status: status,
                        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _refresh();
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: const Text('LOG RISK'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final risks = _risks;
    final openCount = risks.where((r) => r.status == 'Open').length;
    final criticalCount = risks.where((r) => r.impact == 'Critical').length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        VaultSectionHeader(
          title: 'Risk Register (${risks.length})',
          icon: Icons.warning_amber_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
            onPressed: _addRisk,
          ),
        ),
        if (risks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              _RiskStat(label: 'Open', value: openCount.toString(), color: AppColors.danger),
              const SizedBox(width: 10),
              _RiskStat(label: 'Critical', value: criticalCount.toString(), color: const Color(0xFFFF3060)),
              const SizedBox(width: 10),
              _RiskStat(label: 'Total', value: risks.length.toString(), color: AppColors.textMuted),
            ]),
          ),
        ],
        if (risks.isEmpty)
          EmptyStateWidget(
            icon: Icons.shield_outlined,
            title: 'No Risks Logged',
            subtitle: 'Identify and track potential mission risks',
            actionLabel: 'Log Risk',
            onAction: _addRisk,
          )
        else
          ...risks.map((r) => _RiskCard(
            risk: r,
            onStatusChange: (newStatus) async {
              await widget.repo.updateRiskStatus(r.id, newStatus);
              _refresh();
            },
            onDelete: () async {
              final confirm = await showDeleteConfirm(context, 'Risk');
              if (confirm) {
                await widget.repo.deleteRisk(r.id);
                _refresh();
              }
            },
          )),
      ],
    );
  }
}

class _RiskStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _RiskStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.dmSans(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final RiskModel risk;
  final void Function(String) onStatusChange;
  final VoidCallback onDelete;

  const _RiskCard({required this.risk, required this.onStatusChange, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(risk.title, style: GoogleFonts.dmSans(
            color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          ImpactBadge(impact: risk.impact),
          const SizedBox(width: 6),
          StatusBadge(status: risk.status),
        ]),
        if (risk.description != null) ...[
          const SizedBox(height: 6),
          Text(risk.description!, style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 12)),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.shield_outlined, color: AppColors.gold, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MITIGATION', style: GoogleFonts.dmSans(
                color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 3),
              Text(risk.mitigation, style: GoogleFonts.dmSans(
                color: AppColors.textSecondary, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          PopupMenuButton<String>(
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            itemBuilder: (_) => AppConstants.riskStatuses.map((s) =>
              PopupMenuItem(value: s, child: Text(s, style: GoogleFonts.dmSans(
                color: AppColors.textPrimary, fontSize: 13)))).toList(),
            onSelected: onStatusChange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Change Status', style: GoogleFonts.dmSans(
                  color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 16),
              ]),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ]),
      ]),
    );
  }
}
