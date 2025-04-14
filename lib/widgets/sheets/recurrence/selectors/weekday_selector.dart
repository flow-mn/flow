import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class WeekdaySelector extends StatefulWidget {
  final Function(Set<int>) onChanged;
  final Set<int> initialValue;

  const WeekdaySelector({
    super.key,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  late Set<int> selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final Moment monday = Moment.now().startOfLocalWeek();

    return Align(
      alignment: Alignment.topCenter,
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: List.generate(
          7,
          (int index) => IconButton(
            onPressed: () => toggle(index + 1),
            icon: Text(monday.add(Duration(days: index)).format("dd")),
            isSelected: selectedDays.contains(index + 1),
          ),
        ),
      ),
    );
  }

  void toggle(int weekday) {
    setState(() {
      if (selectedDays.contains(weekday)) {
        selectedDays.remove(weekday);
      } else {
        selectedDays.add(weekday);
      }
    });

    widget.onChanged(selectedDays);
  }
}
