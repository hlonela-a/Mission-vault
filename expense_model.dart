// lib/data/models/expense_model.dart

import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String missionId;

  @HiveField(2)
  String title;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  String paidBy;

  ExpenseModel({
    required this.id,
    required this.missionId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.paidBy = 'Me',
  });
}
