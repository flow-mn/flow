/// A single net-worth datapoint: the total at a point in time.
class NetWorthSample {
  final DateTime anchor;
  final double amount;

  const NetWorthSample(this.anchor, this.amount);
}
