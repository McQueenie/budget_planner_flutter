# Budget Planner Flutter

A budget management application built with Flutter, converted from an Electron app.

## Features

- **Dashboard**: Overview of monthly income, expenses, balance, and transaction count
- **Transaction Management**: Add and view income/expense transactions
- **Budget Planning**: Set monthly budgets and track usage
- **Monthly Navigation**: Navigate between different months and years
- **Dark Theme**: Modern dark UI matching the original Electron app
- **Charts**: Visual representation of daily expenses
- **Cross-Platform**: Runs on Web, Windows, macOS, Linux, iOS, and Android

## Original Electron App Features Recreated

✅ **Dashboard Tab**
- Monthly statistics (income, expenses, balance, transaction count)
- Budget status with progress bar
- Recent transactions list
- Daily expenses chart

✅ **Transactions Tab**
- Add new transactions (income/expense)
- Transaction list with filtering by month/year
- Form validation and date selection

✅ **Budget Tab**
- Set/update monthly budget
- Budget overview with usage statistics
- Progress tracking and budget tips

✅ **Month Selector**
- Navigate between months and years
- Automatic data loading for selected period

✅ **Dark Theme**
- Consistent dark UI matching original design
- Modern Material Design 3 components

## Getting Started

### Prerequisites
- Flutter SDK (3.1.0 or higher)
- Dart SDK
- For web: Any modern browser
- For desktop: Platform-specific requirements

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Get dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

**Web (for debugging):**
```bash
flutter run -d web-server --web-port 8080
```

**Windows:**
```bash
flutter build windows
```

**macOS:**
```bash
flutter build macos
```

**Linux:**
```bash
flutter build linux
```

## Database

The app uses SQLite for local data storage with the following tables:
- `transactions`: Stores all income/expense transactions
- `budgets`: Stores monthly budget data

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── transaction.dart
│   ├── budget.dart
│   └── monthly_stats.dart
├── services/                 # Business logic
│   └── database_service.dart
├── screens/                  # Main screens
│   └── home_screen.dart
└── widgets/                  # Reusable components
    ├── dashboard_tab.dart
    ├── transactions_tab.dart
    ├── budget_tab.dart
    ├── transaction_form.dart
    ├── transaction_list.dart
    ├── month_selector.dart
    └── spending_chart.dart
```

## Key Dependencies

- `sqflite`: Local SQLite database
- `fl_chart`: Charts and graphs
- `intl`: Internationalization and date formatting
- `path`: File path utilities

## Differences from Original Electron App

- Uses SQLite instead of Electron's SQLite integration
- Flutter's Material Design instead of custom CSS
- Built-in form validation instead of JavaScript alerts
- Flutter's date picker instead of HTML date inputs
- FL Chart instead of Chart.js for graphs

## Build for Production

**Web:**
```bash
flutter build web
```

**Windows:**
```bash
flutter build windows --release
```

**macOS:**
```bash
flutter build macos --release
```

The built applications will be in the respective `build/` directories.