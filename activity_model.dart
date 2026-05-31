// lib/data/models/activity_model.dart

import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 5)
class ActivityModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String missionId;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime? scheduledDate;

  @HiveField(4)
  String? time;

  @HiveField(5)
  double? cost;

  @HiveField(6)
  String? location;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isCompleted;

  ActivityModel({
    required this.id,
    required this.missionId,
    required this.title,
    this.scheduledDate,
    this.time,
    this.cost,
    this.location,
    this.notes,
    this.isCompleted = false,
  });
}
