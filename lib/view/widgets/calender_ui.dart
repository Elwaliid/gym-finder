// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/view/widgets/month_tile_widget.dart';

// ignore: must_be_immutable
class CalenderUI extends StatefulWidget {
  int? monthIndex;
  List<DateTime>? subscribedDates;
  Function? selectDate;
  Function? getSelectedDates;
  CalenderUI({
    super.key,
    this.getSelectedDates,
    this.selectDate,
    this.monthIndex,
    this.subscribedDates,
  });
  @override
  State<CalenderUI> createState() => _CalenderUIState();
}

class _CalenderUIState extends State<CalenderUI> {
  // ignore: prefer_final_fields
  List<DateTime> _selectedDates = [];
  List<MonthTileWidget> _monthTiles = [];
  int? _currentMonthInt;
  int? _currentYearInt;

  _setUpMonthTiles() {
    _monthTiles = [];
    int daysInMonth = AppConstants.daysInMonths[_currentMonthInt]!;
    DateTime firstDayOfMonth = DateTime(_currentYearInt!, _currentMonthInt!, 1);
    int firstWeekOfMonth = firstDayOfMonth.weekday;
    if (firstWeekOfMonth != 7) {
      for (int i = 0; i < firstWeekOfMonth; i++) {
        _monthTiles.add(const MonthTileWidget(dateTime: null));
      }
    }
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_currentYearInt!, _currentMonthInt!, i);
      _monthTiles.add(MonthTileWidget(dateTime: date));
    }
  }

  _selectDate(DateTime date) {
    if (_selectedDates.contains(date)) {
      _selectedDates.remove(date);
    } else {
      _selectedDates.add(date);
    }
    widget.selectDate!(date);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _currentMonthInt = (DateTime.now().month + (widget.monthIndex ?? 0)) % 12;

    if (_currentMonthInt == 0) {
      _currentMonthInt = 12;
    }
    _currentYearInt = DateTime.now().year;
    if (_currentMonthInt! < DateTime.now().month) {
      _currentYearInt = _currentYearInt! + 1;
    }
    _selectedDates.sort();
    _selectedDates.addAll(widget.getSelectedDates!());
    _setUpMonthTiles();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            "${AppConstants.monthDict[_currentMonthInt]} - ${_currentYearInt}",
          ), // Text
        ), // Padding
        GridView.builder(
          itemCount: _monthTiles.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1 / 1,
          ), // Sliver GridDelegateWithFixed Cross Axis Count
          itemBuilder: (context, index) {
            MonthTileWidget monthTile = _monthTiles[index];
            if (monthTile.dateTime == null) {
              return const MaterialButton(
                onPressed: null,
                child: Text(""),
              ); // MaterialButton
            }
            DateTime now = DateTime.now();
            DateTime date = monthTile.dateTime!;

            if (date.isBefore(DateTime(now.year, now.month, now.day))) {
              // Disable dates before current day
              return MaterialButton(
                onPressed: null,
                disabledColor: const Color.fromARGB(255, 223, 242, 255),
                child: monthTile,
              );
            }

            return MaterialButton(
              onPressed: () {
                _selectDate(monthTile.dateTime!);
              },
              color: (_selectedDates.contains(monthTile.dateTime))
                  ? Colors.blue
                  : Colors.white,
              child: monthTile,
            ); // MaterialButton
          },
        ), // GridView.builder
      ],
    );
  }
}
