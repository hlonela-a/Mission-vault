// lib/presentation/screens/mission_detail/quotations_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/quotation_model.dart';
import '../../widgets/vault_widgets.dart';

class QuotationsTab extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const QuotationsTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  State<QuotationsTab> createState() => _QuotationsTabState();
}

class _QuotationsTabState extends State<QuotationsTab> {
  List<QuotationModel> get _quotes => widget.repo.getQuotations(widget.mission.id);

  void _refresh() => setState(() {});

  Future<void> _addQuotation() async {
    final titleCtrl = TextEditingController();
    final vendorCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetHandle(),
                Text('Add Quotation', style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _Field(ctrl: titleCtrl, label: 'Title', hint: 'e.g. Hotel Package A',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _Field(ctrl: vendorCtrl, label: 'Vendor / Supplier', hint: 'e.g. Marriott Hotels',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                _Field(ctrl: amountCtrl, label: 'Quote Amount', hint: '0.00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid amount' : null),
                const SizedBox(height: 10),
                _Field(ctrl: descCtrl, label: 'Description (optional)', maxLines: 2),
                const SizedBox(height: 10),
                _Field(ctrl: contactCtrl, label: 'Contact Info (optional)'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await widget.repo.addQuotation(
                      missionId: widget.mission.id,
                      title: titleCtrl.text.trim(),
                      vendor: vendorCtrl.text.trim(),
                      amount: double.parse(amountCtrl.text.trim()),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      contactInfo: contactCtrl.text.trim().isEmpty ? null : contactCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refresh();
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('ADD QUOTATION'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quotes = _quotes;
    final winner = quotes.where((q) => q.isWinner).firstOrNull;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        VaultSectionHeader(
          title: 'Quotations (${quotes.length})',
          icon: Icons.receipt_long_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
            onPressed: _addQuotation,
          ),
        ),
        if (winner != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C1608), Color(0xFF141208)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldDim),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppColors.gold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WINNING QUOTE', style: GoogleFonts.dmSans(
                          color: AppColors.goldDim, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                        Text(winner.vendor, style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(winner.title, style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(Formatters.currency(winner.amount), style: GoogleFonts.dmSans(
                    color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
        if (quotes.isEmpty)
          EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No Quotations',
            subtitle: 'Add quotes to compare vendors',
            actionLabel: 'Add Quotation',
            onAction: _addQuotation,
          )
        else
          ...quotes.map((q) => QuotationCard(
            quotation: q,
            onSetWinner: () async {
              await widget.repo.setQuotationWinner(widget.mission.id, q.id);
              _refresh();
            },
            onDelete: () async {
              final confirm = await showDeleteConfirm(context, 'Quotation');
              if (confirm) {
                await widget.repo.deleteQuotation(q.id);
                _refresh();
              }
            },
          )),
      ],
    );
  }
}

class QuotationCard extends StatelessWidget {
  final QuotationModel quotation;
  final VoidCallback onSetWinner;
  final VoidCallback onDelete;

  const QuotationCard({super.key, required this.quotation, required this.onSetWinner, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return VaultCard(
      highlighted: quotation.isWinner,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quotation.vendor, style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(quotation.title, style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.currency(quotation.amount), style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  if (quotation.isWinner)
                    const StatusBadge(status: 'Winner'),
                ],
              ),
            ],
          ),
          if (quotation.description != null) ...[
            const SizedBox(height: 8),
            Text(quotation.description!, style: GoogleFonts.dmSans(
              color: AppColors.textMuted, fontSize: 12)),
          ],
          if (quotation.contactInfo != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 12),
                const SizedBox(width: 4),
                Text(quotation.contactInfo!, style: GoogleFonts.dmSans(
                  color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (!quotation.isWinner)
                OutlinedButton.icon(
                  onPressed: onSetWinner,
                  icon: const Icon(Icons.emoji_events_outlined, size: 14),
                  label: const Text('Set as Winner'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: GoogleFonts.dmSans(fontSize: 12),
                  ),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper sheet widgets
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl, required this.label, this.hint,
    this.maxLines = 1, this.keyboardType, this.inputFormatters, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
