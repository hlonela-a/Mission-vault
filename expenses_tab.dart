// lib/presentation/screens/mission_detail/expenses_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/expense_model.dart';
import '../../widgets/vault_widgets.dart';

class ExpensesTab extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const ExpensesTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  List<ExpenseModel> get _expenses => widget.repo.getExpenses(widget.mission.id);

  void _refresh() => setState(() {});

  Future<void> _addExpense() async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final paidByCtrl = TextEditingController(text: 'Me');
    String selectedCategory = AppConstants.expenseCategories.first;
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  Text('Log Expense', style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                          style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                          validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                          decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money, size: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.gold, surface: AppColors.surfaceCard, onSurface: AppColors.textPrimary)),
                                child: child!,
                              ),
                            );
                            if (d != null) setModalState(() => selectedDate = d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date', style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10)),
                                const SizedBox(height: 2),
                                Text(Formatters.dateShort(selectedDate),
                                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    dropdownColor: AppColors.surfaceCard,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    items: AppConstants.expenseCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: paidByCtrl,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Paid By'),
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
                      await widget.repo.addExpense(
                        missionId: widget.mission.id,
                        title: titleCtrl.text.trim(),
                        amount: double.parse(amountCtrl.text.trim()),
                        category: selectedCategory,
                        date: selectedDate,
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                        paidBy: paidByCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      widget.onRefresh();
                      _refresh();
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: const Text('LOG EXPENSE'),
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
    final expenses = _expenses;
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        VaultSectionHeader(
          title: 'Expenses (${expenses.length})',
          icon: Icons.payments_outlined,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Formatters.currency(total),
                style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
                onPressed: _addExpense,
              ),
            ],
          ),
        ),
        if (expenses.isEmpty)
          EmptyStateWidget(
            icon: Icons.payments_outlined,
            title: 'No Expenses',
            subtitle: 'Track your spending by logging expenses',
            actionLabel: 'Log Expense',
            onAction: _addExpense,
          )
        else
          ...expenses.map((e) => _ExpenseCard(
            expense: e,
            onDelete: () async {
              final confirm = await showDeleteConfirm(context, 'Expense');
              if (confirm) {
                await widget.repo.deleteExpense(e.id);
                widget.onRefresh();
                _refresh();
              }
            },
          )),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;

  const _ExpenseCard({required this.expense, required this.onDelete});

  Color get _categoryColor {
    switch (expense.category) {
      case 'Flights': return AppColors.info;
      case 'Accommodation': return AppColors.gold;
      case 'Food & Dining': return AppColors.warning;
      case 'Activities': return AppColors.success;
      case 'Transport': return const Color(0xFF60D0FF);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.dangerDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      confirmDismiss: (_) async {
        final confirm = await showDeleteConfirm(context, 'Expense');
        return confirm;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt_outlined, color: _categoryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(expense.category, style: GoogleFonts.dmSans(
                          color: _categoryColor, fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 6),
                      Text(Formatters.date(expense.date), style: GoogleFonts.dmSans(
                        color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  if (expense.paidBy.isNotEmpty)
                    Text('Paid by ${expense.paidBy}', style: GoogleFonts.dmSans(
                      color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Text(
              Formatters.currency(expense.amount),
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
