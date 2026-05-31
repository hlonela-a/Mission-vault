// lib/data/datasources/hive_datasource.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/mission_model.dart';
import '../models/expense_model.dart';
import '../models/quotation_model.dart';
import '../models/risk_model.dart';
import '../models/packing_item_model.dart';
import '../models/activity_model.dart';
import '../../core/constants/app_constants.dart';

class HiveDatasource {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MissionModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(QuotationModelAdapter());
    Hive.registerAdapter(RiskModelAdapter());
    Hive.registerAdapter(PackingItemModelAdapter());
    Hive.registerAdapter(ActivityModelAdapter());

    await Hive.openBox<MissionModel>(AppConstants.missionBox);
    await Hive.openBox<ExpenseModel>(AppConstants.expenseBox);
    await Hive.openBox<QuotationModel>(AppConstants.quotationBox);
    await Hive.openBox<RiskModel>(AppConstants.riskBox);
    await Hive.openBox<PackingItemModel>(AppConstants.packingBox);
    await Hive.openBox<ActivityModel>(AppConstants.activityBox);
  }

  static Box<MissionModel>     get missions    => Hive.box<MissionModel>(AppConstants.missionBox);
  static Box<ExpenseModel>     get expenses    => Hive.box<ExpenseModel>(AppConstants.expenseBox);
  static Box<QuotationModel>   get quotations  => Hive.box<QuotationModel>(AppConstants.quotationBox);
  static Box<RiskModel>        get risks       => Hive.box<RiskModel>(AppConstants.riskBox);
  static Box<PackingItemModel> get packingItems=> Hive.box<PackingItemModel>(AppConstants.packingBox);
  static Box<ActivityModel>    get activities  => Hive.box<ActivityModel>(AppConstants.activityBox);
}
