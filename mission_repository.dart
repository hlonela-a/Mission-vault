// lib/data/repositories/mission_repository.dart

import 'package:uuid/uuid.dart';
import '../datasources/hive_datasource.dart';
import '../models/mission_model.dart';
import '../models/expense_model.dart';
import '../models/quotation_model.dart';
import '../models/risk_model.dart';
import '../models/packing_item_model.dart';
import '../models/activity_model.dart';

const _uuid = Uuid();

class MissionRepository {
  // ── Missions ──────────────────────────────────────────────────

  List<MissionModel> getAllMissions() {
    return HiveDatasource.missions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  MissionModel? getMission(String id) {
    return HiveDatasource.missions.values
        .where((m) => m.id == id)
        .firstOrNull;
  }

  Future<MissionModel> createMission({
    required String name,
    required String destination,
    String? description,
    DateTime? departureDate,
    DateTime? returnDate,
    required double budgetAllocated,
    String currency = 'USD',
    int travelersCount = 1,
    String? coverEmoji,
  }) async {
    final mission = MissionModel(
      id: _uuid.v4(),
      name: name,
      destination: destination,
      description: description,
      departureDate: departureDate,
      returnDate: returnDate,
      budgetAllocated: budgetAllocated,
      currency: currency,
      travelersCount: travelersCount,
      createdAt: DateTime.now(),
      coverEmoji: coverEmoji,
    );
    await HiveDatasource.missions.put(mission.id, mission);
    return mission;
  }

  Future<void> updateMission(MissionModel mission) async {
    await HiveDatasource.missions.put(mission.id, mission);
  }

  Future<void> deleteMission(String id) async {
    await HiveDatasource.missions.delete(id);
    // Cascade delete
    final expKeys = HiveDatasource.expenses.values
        .where((e) => e.missionId == id).map((e) => e.id).toList();
    for (final k in expKeys) await HiveDatasource.expenses.delete(k);

    final qKeys = HiveDatasource.quotations.values
        .where((q) => q.missionId == id).map((q) => q.id).toList();
    for (final k in qKeys) await HiveDatasource.quotations.delete(k);

    final rKeys = HiveDatasource.risks.values
        .where((r) => r.missionId == id).map((r) => r.id).toList();
    for (final k in rKeys) await HiveDatasource.risks.delete(k);

    final pKeys = HiveDatasource.packingItems.values
        .where((p) => p.missionId == id).map((p) => p.id).toList();
    for (final k in pKeys) await HiveDatasource.packingItems.delete(k);

    final aKeys = HiveDatasource.activities.values
        .where((a) => a.missionId == id).map((a) => a.id).toList();
    for (final k in aKeys) await HiveDatasource.activities.delete(k);
  }

  // ── Expenses ──────────────────────────────────────────────────

  List<ExpenseModel> getExpenses(String missionId) {
    return HiveDatasource.expenses.values
        .where((e) => e.missionId == missionId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalSpent(String missionId) {
    return getExpenses(missionId).fold(0, (sum, e) => sum + e.amount);
  }

  Future<void> addExpense({
    required String missionId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
    String paidBy = 'Me',
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      missionId: missionId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      paidBy: paidBy,
    );
    await HiveDatasource.expenses.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await HiveDatasource.expenses.delete(id);
  }

  // ── Quotations ────────────────────────────────────────────────

  List<QuotationModel> getQuotations(String missionId) {
    return HiveDatasource.quotations.values
        .where((q) => q.missionId == missionId)
        .toList()
      ..sort((a, b) => a.amount.compareTo(b.amount));
  }

  Future<void> addQuotation({
    required String missionId,
    required String title,
    required String vendor,
    required double amount,
    String? description,
    String? contactInfo,
  }) async {
    final q = QuotationModel(
      id: _uuid.v4(),
      missionId: missionId,
      title: title,
      vendor: vendor,
      amount: amount,
      description: description,
      contactInfo: contactInfo,
      createdAt: DateTime.now(),
    );
    await HiveDatasource.quotations.put(q.id, q);
  }

  Future<void> setQuotationWinner(String missionId, String quotationId) async {
    final quotes = HiveDatasource.quotations.values
        .where((q) => q.missionId == missionId);
    for (final q in quotes) {
      q.isWinner = q.id == quotationId;
      await q.save();
    }
  }

  Future<void> deleteQuotation(String id) async {
    await HiveDatasource.quotations.delete(id);
  }

  // ── Risks ─────────────────────────────────────────────────────

  List<RiskModel> getRisks(String missionId) {
    return HiveDatasource.risks.values
        .where((r) => r.missionId == missionId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addRisk({
    required String missionId,
    required String title,
    required String impact,
    required String mitigation,
    String status = 'Open',
    String? description,
  }) async {
    final r = RiskModel(
      id: _uuid.v4(),
      missionId: missionId,
      title: title,
      impact: impact,
      mitigation: mitigation,
      status: status,
      createdAt: DateTime.now(),
      description: description,
    );
    await HiveDatasource.risks.put(r.id, r);
  }

  Future<void> updateRiskStatus(String id, String status) async {
    final r = HiveDatasource.risks.get(id);
    if (r != null) {
      r.status = status;
      await r.save();
    }
  }

  Future<void> deleteRisk(String id) async {
    await HiveDatasource.risks.delete(id);
  }

  // ── Packing Items ─────────────────────────────────────────────

  List<PackingItemModel> getPackingItems(String missionId) {
    return HiveDatasource.packingItems.values
        .where((p) => p.missionId == missionId)
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));
  }

  Future<void> addPackingItem({
    required String missionId,
    required String name,
    String category = 'General',
    int quantity = 1,
  }) async {
    final p = PackingItemModel(
      id: _uuid.v4(),
      missionId: missionId,
      name: name,
      category: category,
      quantity: quantity,
    );
    await HiveDatasource.packingItems.put(p.id, p);
  }

  Future<void> togglePackingItem(String id) async {
    final p = HiveDatasource.packingItems.get(id);
    if (p != null) {
      p.isPacked = !p.isPacked;
      await p.save();
    }
  }

  Future<void> deletePackingItem(String id) async {
    await HiveDatasource.packingItems.delete(id);
  }

  // ── Activities ────────────────────────────────────────────────

  List<ActivityModel> getActivities(String missionId) {
    return HiveDatasource.activities.values
        .where((a) => a.missionId == missionId)
        .toList()
      ..sort((a, b) {
        if (a.scheduledDate == null && b.scheduledDate == null) return 0;
        if (a.scheduledDate == null) return 1;
        if (b.scheduledDate == null) return -1;
        return a.scheduledDate!.compareTo(b.scheduledDate!);
      });
  }

  Future<void> addActivity({
    required String missionId,
    required String title,
    DateTime? scheduledDate,
    String? time,
    double? cost,
    String? location,
    String? notes,
  }) async {
    final a = ActivityModel(
      id: _uuid.v4(),
      missionId: missionId,
      title: title,
      scheduledDate: scheduledDate,
      time: time,
      cost: cost,
      location: location,
      notes: notes,
    );
    await HiveDatasource.activities.put(a.id, a);
  }

  Future<void> toggleActivity(String id) async {
    final a = HiveDatasource.activities.get(id);
    if (a != null) {
      a.isCompleted = !a.isCompleted;
      await a.save();
    }
  }

  Future<void> deleteActivity(String id) async {
    await HiveDatasource.activities.delete(id);
  }

  // ── Seed data ─────────────────────────────────────────────────

  Future<void> seedDemoData() async {
    if (HiveDatasource.missions.isNotEmpty) return;

    // Mission 1
    final m1 = await createMission(
      name: 'OPERATION SAKURA',
      destination: 'Tokyo, Japan',
      description: 'Cherry blossom season expedition across Tokyo, Kyoto & Osaka.',
      departureDate: DateTime.now().add(const Duration(days: 45)),
      returnDate: DateTime.now().add(const Duration(days: 59)),
      budgetAllocated: 8500,
      currency: 'USD',
      travelersCount: 2,
      coverEmoji: '🌸',
    );

    await addExpense(missionId: m1.id, title: 'Return Flights SIN-NRT', amount: 1840, category: 'Flights', date: DateTime.now().subtract(const Duration(days: 5)));
    await addExpense(missionId: m1.id, title: 'Shinjuku Hotel 7 nights', amount: 1260, category: 'Accommodation', date: DateTime.now().subtract(const Duration(days: 3)));
    await addExpense(missionId: m1.id, title: 'JR Pass (14-day)', amount: 580, category: 'Transport', date: DateTime.now().subtract(const Duration(days: 2)));

    await addQuotation(missionId: m1.id, title: 'Budget Hotel Package', vendor: 'Booking.com', amount: 980, description: '7 nights shared room, breakfast excluded');
    await addQuotation(missionId: m1.id, title: 'Premium Ryokan Stay', vendor: 'Ryokan Direct', amount: 2100, description: '5 nights with kaiseki dinner, onsen access');
    await setQuotationWinner(m1.id, HiveDatasource.quotations.values.first.id);

    await addRisk(missionId: m1.id, title: 'Typhoon Season Overlap', impact: 'High', mitigation: 'Travel insurance with cancellation cover. Monitor JMA forecasts 7 days prior.', status: 'Mitigated');
    await addRisk(missionId: m1.id, title: 'Cherry Blossom Timing', impact: 'Medium', mitigation: 'Booked flexible hotel. Have backup Osaka itinerary if Tokyo blooms early.', status: 'Open');

    await addPackingItem(missionId: m1.id, name: 'Passport', category: 'Documents', quantity: 1);
    await addPackingItem(missionId: m1.id, name: 'Japan Rail Pass', category: 'Documents', quantity: 2);
    await addPackingItem(missionId: m1.id, name: 'Travel Insurance Certificate', category: 'Documents', quantity: 1);
    await addPackingItem(missionId: m1.id, name: 'Universal Adapter (Type A)', category: 'Electronics', quantity: 1);
    await addPackingItem(missionId: m1.id, name: 'Portable WiFi Device', category: 'Electronics', quantity: 1);
    await addPackingItem(missionId: m1.id, name: 'Lightweight Raincoat', category: 'Clothing', quantity: 2);
    await addPackingItem(missionId: m1.id, name: 'Comfortable Walking Shoes', category: 'Clothing', quantity: 1);

    await addActivity(missionId: m1.id, title: 'Tsukiji Fish Market Morning Tour', scheduledDate: m1.departureDate?.add(const Duration(days: 1)), time: '06:00', cost: 0, location: 'Tsukiji, Tokyo');
    await addActivity(missionId: m1.id, title: 'TeamLab Borderless Digital Art', scheduledDate: m1.departureDate?.add(const Duration(days: 2)), time: '14:00', cost: 90, location: 'Odaiba, Tokyo');
    await addActivity(missionId: m1.id, title: 'Bullet Train to Kyoto', scheduledDate: m1.departureDate?.add(const Duration(days: 4)), time: '09:30', cost: 0, location: 'Tokyo Station');

    // Mission 2
    final m2 = await createMission(
      name: 'ALPINE DIRECTIVE',
      destination: 'Zermatt, Switzerland',
      description: 'Winter skiing expedition to the Matterhorn region.',
      departureDate: DateTime.now().add(const Duration(days: 120)),
      returnDate: DateTime.now().add(const Duration(days: 128)),
      budgetAllocated: 12000,
      currency: 'USD',
      travelersCount: 4,
      coverEmoji: '🏔️',
    );

    await addExpense(missionId: m2.id, title: 'Business Class Flights x4', amount: 6400, category: 'Flights', date: DateTime.now().subtract(const Duration(days: 10)));
    await addRisk(missionId: m2.id, title: 'Avalanche Risk on Off-Piste Routes', impact: 'Critical', mitigation: 'Stay on marked pistes. Hire certified guide for any off-piste. All carry avalanche beacon.', status: 'Mitigated');

    await addPackingItem(missionId: m2.id, name: 'Ski Boots', category: 'Equipment', quantity: 4);
    await addPackingItem(missionId: m2.id, name: 'Thermal Base Layers', category: 'Clothing', quantity: 8);
    await addPackingItem(missionId: m2.id, name: 'Ski Goggles', category: 'Equipment', quantity: 4);

    // Mission 3 (completed)
    final m3 = await createMission(
      name: 'DESERT PROTOCOL',
      destination: 'Dubai, UAE',
      description: 'Luxury desert and city experience.',
      departureDate: DateTime.now().subtract(const Duration(days: 60)),
      returnDate: DateTime.now().subtract(const Duration(days: 54)),
      budgetAllocated: 5000,
      currency: 'USD',
      travelersCount: 2,
      coverEmoji: '🏜️',
    );
    final m3Saved = HiveDatasource.missions.get(m3.id)!;
    m3Saved.status = 'Completed';
    await m3Saved.save();

    await addExpense(missionId: m3.id, title: 'Return Flights', amount: 800, category: 'Flights', date: DateTime.now().subtract(const Duration(days: 70)));
    await addExpense(missionId: m3.id, title: 'Burj Al Arab Stay 2N', amount: 2400, category: 'Accommodation', date: DateTime.now().subtract(const Duration(days: 68)));
    await addExpense(missionId: m3.id, title: 'Desert Safari Private', amount: 480, category: 'Activities', date: DateTime.now().subtract(const Duration(days: 60)));
    await addExpense(missionId: m3.id, title: 'Fine Dining x3', amount: 620, category: 'Food & Dining', date: DateTime.now().subtract(const Duration(days: 58)));
  }
}
