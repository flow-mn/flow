class MoneyFlow<T> implements Comparable<MoneyFlow> {
  final T? associatedData;

  double totalExpense;
  double totalIncome;

  double get flow => totalExpense + totalIncome;

  bool get isEmpty => totalExpense.abs() == 0.0 && totalIncome.abs() == 0.0;

  MoneyFlow({
    this.associatedData,
    this.totalExpense = 0.0,
    this.totalIncome = 0.0,
  });

  @override
  int compareTo(MoneyFlow other) {
    return flow.compareTo(other.flow);
  }

  void addExpense(double expense) => totalExpense += expense;
  void addIncome(double income) => totalIncome += income;
  void add(double amount) =>
      amount.isNegative ? addExpense(amount) : addIncome(amount);
  void addAll(Iterable<double> amounts) => amounts.forEach(add);

  operator +(MoneyFlow other) {
    return MoneyFlow(
      totalExpense: totalExpense + other.totalExpense,
      totalIncome: totalIncome + other.totalIncome,
    );
  }

  operator -(MoneyFlow other) {
    return MoneyFlow(
      totalExpense: totalExpense - other.totalExpense,
      totalIncome: totalIncome - other.totalIncome,
    );
  }

  operator -() {
    return MoneyFlow(
      totalExpense: -totalExpense,
      totalIncome: -totalIncome,
    );
  }
}
