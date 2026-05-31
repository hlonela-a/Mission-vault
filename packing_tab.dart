// lib/presentation/screens/mission_detail/packing_tab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/packing_item_model.dart';
import '../../widgets/vault_widgets.dart';

class PackingTab extends StatefulWidget {
  final MissionModel mission;
  final MissionRepository repo;
  final VoidCallback onRefresh;

  const PackingTab({super.key, required this.mission, required this.repo, required this.onRefresh});

  @override
  State<PackingTab> createState() => _PackingTabState();
}

class _PackingTabState extends State<PackingTab> {
  List<PackingItemModel> get _items => widget.repo.getPackingItems(widget.mission.id);
  void _refresh() => setState(() {});

  static const _categories = [
    'Documents', 'Electronics', 'Clothing', 'Toiletries',
    'Equipment', 'Medical', 'Food & Snacks', 'General',
  ];

  Future<void> _addItem() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String category = 'General';
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
                Text('Add Packing Item', style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  autofocus: true,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    dropdownColor: AppColors.surfaceCard,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    items: _categories.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setModal(() => category = v!),
                  )),
                  const SizedBox(width: 10),
                  SizedBox(width: 80, child: TextFormField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Qty'),
                  )),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await widget.repo.addPackingItem(
                      missionId: widget.mission.id,
                      name: nameCtrl.text.trim(),
                      category: category,
                      quantity: int.tryParse(qtyCtrl.text) ?? 1,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _refresh();
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('ADD ITEM'),
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
    final items = _items;
    final packed = items.where((i) => i.isPacked).length;
    final progress = items.isEmpty ? 0.0 : packed / items.length;

    // Group by category
    final Map<String, List<PackingItemModel>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        VaultSectionHeader(
          title: 'Packing List ($packed/${items.length})',
          icon: Icons.luggage_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
            onPressed: _addItem,
          ),
        ),
        if (items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Pack progress', style: GoogleFonts.dmSans(
                  color: AppColors.textMuted, fontSize: 11)),
                Text('${(progress * 100).toStringAsFixed(0)}%', style: GoogleFonts.dmSans(
                  color: progress == 1.0 ? AppColors.success : AppColors.gold,
                  fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    progress == 1.0 ? AppColors.success : AppColors.gold),
                  minHeight: 6,
                ),
              ),
            ]),
          ),
        ],
        if (items.isEmpty)
          EmptyStateWidget(
            icon: Icons.luggage_outlined,
            title: 'Packing List Empty',
            subtitle: 'Add items to track your packing progress',
            actionLabel: 'Add Item',
            onAction: _addItem,
          )
        else ...[
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                Text(entry.key.toUpperCase(), style: GoogleFonts.dmSans(
                  color: AppColors.textMuted, fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(width: 8),
                Text('${entry.value.where((i) => i.isPacked).length}/${entry.value.length}',
                  style: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 10)),
              ]),
            ),
            ...entry.value.map((item) => _PackingItemTile(
              item: item,
              onToggle: () async {
                await widget.repo.togglePackingItem(item.id);
                _refresh();
              },
              onDelete: () async {
                await widget.repo.deletePackingItem(item.id);
                _refresh();
              },
            )),
          ],
        ],
      ],
    );
  }
}

class _PackingItemTile extends StatelessWidget {
  final PackingItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PackingItemTile({required this.item, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: item.isPacked ? AppColors.surfaceElevated : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isPacked ? AppColors.success.withOpacity(0.3) : AppColors.border),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isPacked ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: item.isPacked ? AppColors.success : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: item.isPacked
                ? const Icon(Icons.check, color: Colors.white, size: 13)
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Row(children: [
              Expanded(child: Text(item.name, style: GoogleFonts.dmSans(
                color: item.isPacked ? AppColors.textMuted : AppColors.textPrimary,
                fontSize: 14,
                decoration: item.isPacked ? TextDecoration.lineThrough : null,
              ))),
              if (item.quantity > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('×${item.quantity}', style: GoogleFonts.dmSans(
                    color: AppColors.textMuted, fontSize: 11)),
                ),
              ],
            ])),
          ]),
        ),
      ),
    );
  }
}
