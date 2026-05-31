// lib/data/models/risk_model.dart

import 'package:hive/hive.dart';

part 'risk_model.g.dart';

@HiveType(typeId: 3)
class RiskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String missionId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String impact; // Low, Medium, High, Critical

  @HiveField(4)
  String mitigation;

  @HiveField(5)
  String status; // Open, Mitigated, Accepted, Closed

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? description;

  RiskModel({
    required this.id,
    required this.missionId,
    required this.title,
    required this.impact,
    required this.mitigation,
    required this.status,
    required this.createdAt,
    this.description,
  });
}
