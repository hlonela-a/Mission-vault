# 🔐 MISSION VAULT
## Luxury Travel & Planning Operations App

A premium, offline-first Flutter application for strategic travel planning. Built with a military-inspired "Mission" metaphor, luxury dark UI, and full local persistence via Hive.

---

## ✅ Quick Start

### Prerequisites
- Flutter SDK 3.x (`flutter --version`)
- Dart SDK 3.x (included with Flutter)
- Android Studio / Xcode for device emulation

### Setup & Run

```bash
# 1. Navigate to project folder
cd mission_vault

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run

# 4. Build release APK (Android)
flutter build apk --release

# 5. Build release IPA (iOS)
flutter build ipa --release
```

> **No build_runner needed.** All Hive adapters are hand-written `.g.dart` files — no code generation step required.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, Hive init, seed data
├── core/
│   ├── constants/app_constants.dart   # Box names, categories, status values
│   ├── theme/app_theme.dart           # Full luxury dark theme + color palette
│   └── utils/formatters.dart         # Currency, date, percentage formatters
├── data/
│   ├── datasources/hive_datasource.dart  # Hive init & box accessors
│   ├── models/
│   │   ├── mission_model.dart + .g.dart
│   │   ├── expense_model.dart + .g.dart
│   │   ├── quotation_model.dart + .g.dart
│   │   ├── risk_model.dart + .g.dart
│   │   ├── packing_item_model.dart + .g.dart
│   │   └── activity_model.dart + .g.dart
│   └── repositories/mission_repository.dart  # All CRUD + seed data
└── presentation/
    ├── screens/
    │   ├── home/home_screen.dart              # Dashboard + nav
    │   ├── missions/
    │   │   ├── missions_screen.dart           # Mission list + filter chips
    │   │   └── create_mission_screen.dart     # Create/edit form
    │   └── mission_detail/
    │       ├── mission_detail_screen.dart     # Tabbed detail view
    │       ├── budget_tab.dart                # Budget overview + pie chart
    │       ├── quotations_tab.dart            # Vendor quotes + winner selection
    │       ├── expenses_tab.dart              # Expense log with categories
    │       ├── risks_tab.dart                 # Risk register + mitigation
    │       ├── packing_tab.dart               # Packing checklist + progress
    │       └── activities_tab.dart            # Activity planner + schedule
    └── widgets/vault_widgets.dart             # Reusable UI components
```

---

## 🗄️ Data Storage

All data is stored **100% locally** using [Hive](https://pub.dev/packages/hive_flutter).

| Box Name        | Model           | TypeId |
|----------------|-----------------|--------|
| `missions`     | MissionModel    | 0      |
| `expenses`     | ExpenseModel    | 1      |
| `quotations`   | QuotationModel  | 2      |
| `risks`        | RiskModel       | 3      |
| `packing_items`| PackingItemModel| 4      |
| `activities`   | ActivityModel   | 5      |

- Data **persists after app restart** automatically
- **No internet required**, no authentication
- Cascade deletes when a mission is removed

---

## 🌟 Features

### Dashboard (Command Centre)
- Total treasury overview with gold progress bar
- Active / Planning / Completed mission counts
- Next upcoming mission highlight card
- Mini mission grid for quick access

### Missions
- Create with name, destination, dates, budget, travelers, emoji
- Filter by status: All / Planning / Active / Completed / Cancelled
- Budget progress bar per mission
- Swipe-to-delete with confirmation

### Mission Detail (6 Tabs)
1. **Budget** — Allocated / Spent / Remaining / Per-Person + pie chart by category
2. **Quotations** — Vendor quotes, price comparison, winner selection
3. **Expenses** — Log entries with category, date, paid-by; dismissible delete
4. **Risks** — Impact levels (Low → Critical), mitigation plans, status updates
5. **Packing** — Grouped checklist with pack progress bar, swipe-to-delete
6. **Activities** — Date-grouped itinerary with time, location, cost, completion toggle

---

## 🎨 Design System

- **Color palette:** Deep navy/black backgrounds + gold/amber accents
- **Typography:** Cormorant Garamond (display) + DM Sans (body) + Space Mono (code/labels)
- **Components:** VaultCard, StatusBadge, ImpactBadge, StatTile, EmptyStateWidget
- **Motion:** Animated check states, shimmer progress, swipe gestures

---

## 🚀 Future-Ready Architecture

The repository pattern and clean layer separation make it straightforward to add:
- Cloud sync (Firebase / Supabase)
- Authentication
- Push notifications for departure countdowns
- Multi-currency conversion
- PDF/CSV export of missions
