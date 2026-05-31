// lib/presentation/screens/missions/create_mission_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/mission_repository.dart';
import '../../widgets/vault_widgets.dart';

class CreateMissionScreen extends StatefulWidget {
  final MissionRepository repo;
  const CreateMissionScreen({super.key, required this.repo});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _destCtrl        = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _budgetCtrl      = TextEditingController();

  DateTime? _departure;
  DateTime? _returnDate;
  int _travelers = 1;
  String _currency = 'USD';
  String _emoji = '✈️';
  bool _saving = false;

  final _emojiOptions = ['✈️', '🌸', '🏔️', '🏖️', '🏜️', '🗺️', '🌍', '🎯', '🚀', '⚔️', '🌊', '🏕️'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _destCtrl.dispose();
    _descCtrl.dispose(); _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? (_departure ?? now.add(const Duration(days: 30)))
          : (_returnDate ?? (_departure?.add(const Duration(days: 7)) ?? now.add(const Duration(days: 37)))),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 1825)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.surfaceCard,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) _departure = picked;
        else _returnDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.repo.createMission(
      name: _nameCtrl.text.trim().toUpperCase(),
      destination: _destCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      departureDate: _departure,
      returnDate: _returnDate,
      budgetAllocated: double.parse(_budgetCtrl.text.trim()),
      currency: _currency,
      travelersCount: _travelers,
      coverEmoji: _emoji,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Mission'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    )
                  : Text(
                      'CREATE',
                      style: GoogleFonts.dmSans(
                        color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Emoji picker
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldDim, width: 1.5),
                    ),
                    child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _emojiOptions.map((e) => GestureDetector(
                      onTap: () => setState(() => _emoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _emoji == e ? AppColors.goldSubtle : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _emoji == e ? AppColors.goldDim : AppColors.border,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            VaultSectionHeader(title: 'Mission Identity', icon: Icons.badge_outlined),
            _buildField(
              controller: _nameCtrl,
              label: 'Mission Name',
              hint: 'e.g. OPERATION SAKURA',
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _destCtrl,
              label: 'Destination',
              hint: 'e.g. Tokyo, Japan',
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _descCtrl,
              label: 'Description (optional)',
              hint: 'Brief mission overview...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            VaultSectionHeader(title: 'Dates', icon: Icons.calendar_month_outlined),
            Row(
              children: [
                Expanded(child: _DateButton(
                  label: 'Departure',
                  date: _departure,
                  onTap: () => _pickDate(isDeparture: true),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DateButton(
                  label: 'Return',
                  date: _returnDate,
                  onTap: () => _pickDate(isDeparture: false),
                )),
              ],
            ),
            const SizedBox(height: 24),
            VaultSectionHeader(title: 'Budget & Team', icon: Icons.account_balance_wallet_outlined),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    controller: _budgetCtrl,
                    label: 'Total Budget',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    prefixIcon: Icons.attach_money,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    dropdownColor: AppColors.surfaceCard,
                    style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
                    items: AppConstants.currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Travelers counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'Travelers',
                    style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const Spacer(),
                  _CounterButton(
                    icon: Icons.remove,
                    onTap: () { if (_travelers > 1) setState(() => _travelers--); },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_travelers',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onTap: () { if (_travelers < 20) setState(() => _travelers++); },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                    )
                  : Text(
                      'LAUNCH MISSION',
                      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.textMuted) : null,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppColors.goldDim : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.dmSans(
                color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date!.day} ${_monthShort(date!.month)} ${date!.year}'
                  : 'Select date',
              style: GoogleFonts.dmSans(
                color: date != null ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 13,
                fontWeight: date != null ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 16),
      ),
    );
  }
}
