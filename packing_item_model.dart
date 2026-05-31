// lib/data/models/packing_item_model.dart

import 'package:hive/hive.dart';

part 'packing_item_model.g.dart';

@HiveType(typeId: 4)
class PackingItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String missionId;

  @HiveField(2)
  String name;

  @HiveField(3)
  bool isPacked;

  @HiveField(4)
  String category;

  @HiveField(5)
  int quantity;

  PackingItemModel({
    required this.id,
    required this.missionId,
    required this.name,
    this.isPacked = false,
    this.category = 'General',
    this.quantity = 1,
  });
}
