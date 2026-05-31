// lib/data/models/quotation_model.dart

import 'package:hive/hive.dart';

part 'quotation_model.g.dart';

@HiveType(typeId: 2)
class QuotationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String missionId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String vendor;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String? description;

  @HiveField(6)
  bool isWinner;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? contactInfo;

  QuotationModel({
    required this.id,
    required this.missionId,
    required this.title,
    required this.vendor,
    required this.amount,
    this.description,
    this.isWinner = false,
    required this.createdAt,
    this.contactInfo,
  });
}
