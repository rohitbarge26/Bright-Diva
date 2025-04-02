import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarJobFilterDialog extends StatefulWidget {
  final DateTime currentDate;
  final DateTime startDate;

  const CalendarJobFilterDialog(
      {super.key, required this.currentDate, required this.startDate});

  @override
  State<CalendarJobFilterDialog> createState() =>
      _CalendarJobFilterDialogState();
}

class _CalendarJobFilterDialogState extends State<CalendarJobFilterDialog> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    setState(() {
      _focusedDay = widget.currentDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFFFFFFF)),
        width: MediaQuery.of(context).size.width - 32,
        constraints: const BoxConstraints(maxHeight: double.infinity),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 0,
              child: TableCalendar(
                currentDay: widget.currentDate,
                availableGestures: AvailableGestures.all,
                firstDay: widget.startDate,
                lastDay: DateTime.utc(9999),
                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  Navigator.of(context).pop(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                selectedDayPredicate: (day) {
                  String dayStr = DateFormat('yyyy-MM-dd').format(day);
                  String todayStr =
                      DateFormat('yyyy-MM-dd').format(DateTime.now());
                  return dayStr == todayStr;
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (date, locale) {
                    var dateFormat = DateFormat.MMMM();
                    return dateFormat.format(date);
                  },
                  titleTextStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  rightChevronIcon: Container(
                    padding: const EdgeInsets.all(8.89),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/icon/chevron_right.svg',
                      width: 14.2,
                      height: 14.2,
                    ),
                  ),
                  leftChevronIcon: Container(
                    padding: const EdgeInsets.all(8.89),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/icon/chevron_left.svg',
                      width: 14.2,
                      height: 14.2,
                    ),
                  ),
                ),
                calendarFormat: CalendarFormat.month,
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Color(0xFF9C9D9F),
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: Color(0xFF9C9D9F),
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    shape: BoxShape.rectangle,
                    color: const Color(0xFFF85A5A),
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Color(0xFFF85A5A),
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  cellMargin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  isTodayHighlighted: true,
                  defaultTextStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  disabledTextStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9C9D9F),
                  ),
                  selectedDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(width: 1, color: const Color(0xFFF85A5A)),
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
