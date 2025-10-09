# Account-Based Goals Feature

## Overview

The Goals feature allows users to set financial targets for their accounts and receive notifications when those targets are reached.

## How It Works

### Goal Types

1. **Positive Goals** - For saving money
   - Example: Save $10,000 in Cash account
   - Notification triggered when balance >= target

2. **Negative Goals** - For credit limits or spending alerts
   - Example: Credit Card reaches -$15,000
   - Notification triggered when balance <= target (more negative)

### Key Features

- **Automatic Monitoring**: Goals are automatically checked whenever transactions change
- **Smart Notifications**: Users receive a notification once when a goal is achieved
- **Persistent State**: Notification state is saved to avoid duplicate alerts
- **Account-Linked**: Each goal is linked to a specific account

## Usage Examples

### Creating a Savings Goal

```dart
// Create a goal to save $10,000 in a savings account
final savingsAccount = Account(
  name: "Savings",
  currency: "USD",
  iconCode: "savings_icon",
);

final goal = Goal(
  name: "House Down Payment",
  targetBalance: 10000.0,
  currency: "USD",
  range: null,
);

goal.setAccount(savingsAccount);
await GoalsService().upsertGoal(goal);
```

### Creating a Credit Card Limit Goal

```dart
// Create a goal to alert when credit card reaches limit
final creditCard = Account(
  name: "Apple Card",
  currency: "USD",
  iconCode: "credit_card_icon",
);

final goal = Goal(
  name: "Credit Card Alert",
  targetBalance: -15000.0, // Negative for credit cards
  currency: "USD",
  range: null,
);

goal.setAccount(creditCard);
await GoalsService().upsertGoal(goal);
```

### How Notifications Work

When a transaction is added to an account:
1. GoalsService automatically checks all goals
2. If an account balance reaches the goal target:
   - A notification is shown to the user
   - The goal is marked as "notified" to prevent duplicate alerts
3. If the goal target is updated, the notification state is reset

### API Methods

#### GoalsService

- `getAll()` - Get all goals
- `getOne(int id)` - Get a specific goal by ID
- `findOne(dynamic identifier)` - Find goal by ID or UUID
- `upsertGoal(Goal goal)` - Create or update a goal (resets notification if target changes)
- `deleteGoal(int goalId)` - Delete a goal and clean up its state
- `checkGoalAchievement(Goal goal, Account account)` - Check if a goal is achieved
- `resetGoalNotification(int goalId)` - Reset notification state for a goal
- `checkGoalsNow()` - Manually trigger goal checking

## Technical Details

### Architecture

- **Service Pattern**: GoalsService is a singleton that monitors transactions
- **ObjectBox Integration**: Uses ObjectBox queries and watchers for real-time monitoring
- **Notification System**: Integrates with flutter_local_notifications
- **State Persistence**: Uses SharedPreferences to track notified goals

### Transaction Monitoring

The service watches the Transaction box for changes:

```dart
ObjectBox().box<Transaction>().query().watch().listen((_) {
  _checkAllGoalsForAchievement();
});
```

When transactions change, all goals are checked and notifications are sent for newly achieved goals.

### Notification State

To avoid duplicate notifications:
- Notified goals are tracked in memory (`_notifiedGoals` Set)
- State is persisted to SharedPreferences
- When a goal's target balance changes, its notification state is reset

## Testing

Tests are available in `test/goals_test.dart` covering:
- Goal creation and retrieval
- Achievement checking for positive and negative targets
- Account relationship validation
- Notification state management
- Goal update and deletion

Run tests with:
```bash
flutter test test/goals_test.dart
```
