// lib/core/constants/app_constants.dart

class AppConstants {
  // Hive box names
  static const missionBox     = 'missions';
  static const expenseBox     = 'expenses';
  static const quotationBox   = 'quotations';
  static const riskBox        = 'risks';
  static const packingBox     = 'packing_items';
  static const activityBox    = 'activities';

  // Hive type IDs
  static const missionTypeId    = 0;
  static const expenseTypeId    = 1;
  static const quotationTypeId  = 2;
  static const riskTypeId       = 3;
  static const packingTypeId    = 4;
  static const activityTypeId   = 5;

  // Status values
  static const missionStatuses = ['Planning', 'Active', 'Completed', 'Cancelled'];
  static const riskStatuses    = ['Open', 'Mitigated', 'Accepted', 'Closed'];
  static const riskImpacts     = ['Low', 'Medium', 'High', 'Critical'];

  // Expense categories
  static const expenseCategories = [
    'Flights',
    'Accommodation',
    'Transport',
    'Food & Dining',
    'Activities',
    'Shopping',
    'Insurance',
    'Visas & Permits',
    'Equipment',
    'Communication',
    'Miscellaneous',
  ];

  // Currency symbols
  static const currencies = ['USD', 'EUR', 'GBP', 'AED', 'SGD', 'JPY', 'AUD'];
}
