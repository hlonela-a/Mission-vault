// lib/data/models/mission_model.dart

import 'package:hive/hive.dart';

part 'mission_model.g.dart';

@HiveType(typeId: 0)
class MissionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String destination;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DateTime? departureDate;

  @HiveField(5)
  DateTime? returnDate;

  @HiveField(6)
  double budgetAllocated;

  @HiveField(7)
  String currency;

  @HiveField(8)
  int travelersCount;

  @HiveField(9)
  String status; // Planning, Active, Completed, Cancelled

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  String? coverEmoji;

  MissionModel({
    required this.id,
    required this.name,
    required this.destination,
    this.description,
    this.departureDate,
    this.returnDate,
    required this.budgetAllocated,
    this.currency = 'USD',
    this.travelersCount = 1,
    this.status = 'Planning',
    required this.createdAt,
    this.coverEmoji,
  });

  MissionModel copyWith({
    String? name,
    String? destination,
    String? description,
    DateTime? departureDate,
    DateTime? returnDate,
    double? budgetAllocated,
    String? currency,
    int? travelersCount,
    String? status,
    String? coverEmoji,
  }) {
    return MissionModel(
      id: id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      description: description ?? this.description,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      budgetAllocated: budgetAllocated ?? this.budgetAllocated,
      currency: currency ?? this.currency,
      travelersCount: travelersCount ?? this.travelersCount,
      status: status ?? this.status,
      createdAt: createdAt,
      coverEmoji: coverEmoji ?? this.coverEmoji,
    );
  }
}
