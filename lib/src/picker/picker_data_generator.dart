import '../util/date_util.dart';

class DateRangeGen {
  DateRangeGen._();

  /// 生成日期数据
  static Map<int, Map<int, List<int>>> genDateData(
      DateTime minTime, DateTime maxTime) {
    Map<int, Map<int, List<int>>> data = {};
    if (minTime.isAfter(maxTime)) return data;
    for (int year = minTime.year; year <= maxTime.year; year++) {
      data[year] = {};
      if (year == minTime.year && year == maxTime.year) {
        for (int month = minTime.month; month <= maxTime.month; month++) {
          data[year]![month] = [];
          if (month == minTime.month && month == maxTime.month) {
            for (int day = minTime.day; day <= maxTime.day; day++) {
              data[year]![month]!.add(day);
            }
          } else if (month == minTime.month && month != maxTime.month) {
            var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
            for (int day = minTime.day; day <= maxDayOfMonth; day++) {
              data[year]![month]!.add(day);
            }
          } else if (month != minTime.month && month == maxTime.month) {
            for (int day = 1; day <= maxTime.day; day++) {
              data[year]![month]!.add(day);
            }
          } else {
            var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
            for (int day = 1; day <= maxDayOfMonth; day++) {
              data[year]![month]!.add(day);
            }
          }
        }
      } else if (year == minTime.year && year != maxTime.year) {
        for (int month = minTime.month; month <= 12; month++) {
          data[year]![month] = [];
          if (month == minTime.month) {
            var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
            for (int day = minTime.day; day <= maxDayOfMonth; day++) {
              data[year]![month]!.add(day);
            }
          } else {
            var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
            for (int day = 1; day <= maxDayOfMonth; day++) {
              data[year]![month]!.add(day);
            }
          }
        }
      } else if (year != minTime.year && year == maxTime.year) {
        for (int month = 1; month <= maxTime.month; month++) {
          data[year]![month] = [];
          if (month == maxTime.month) {
            for (int day = 1; day <= maxTime.day; day++) {
              data[year]![month]!.add(day);
            }
          } else {
            var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
            for (int day = 1; day <= maxDayOfMonth; day++) {
              data[year]![month]!.add(day);
            }
          }
        }
      } else {
        for (int month = 1; month <= 12; month++) {
          data[year]![month] = [];
          var maxDayOfMonth = DateUtil.daysOfMonth(year, month);
          for (int day = 1; day <= maxDayOfMonth; day++) {
            data[year]![month]!.add(day);
          }
        }
      }
    }
    return data;
  }

  /// 生成时间数据
  static Map<int, List<int>> genTimeData() {
    Map<int, List<int>> data = {};
    for (int hour = 0; hour < 24; hour++) {
      List<int> minutes = [];
      for (int minute = 0; minute < 60; minute++) {
        minutes.add(minute);
      }
      data[hour] = minutes;
    }
    return data;
  }

  /// 生成日期时间数据
  static Map<DateTime, Map<int, List<int>>> genDateTimeData(
    DateTime minTime,
    DateTime maxTime,
  ) {
    Map<DateTime, Map<int, List<int>>> data = {};
    if (DateUtil.isAtSameDay(minTime, maxTime)) {
      // 最大日期和最小日期是同一天
      _whenAtSameDay(minTime, maxTime, data);
    } else {
      for (DateTime date = minTime;
          !date.isAfter(maxTime);
          date = DateTime(date.year, date.month, date.day + 1)) {
        if (DateUtil.isAtSameDay(date, minTime)) {
          // 第一天
          _whenAtSameDay(
              date, DateTime(date.year, date.month, date.day, 23, 59), data);
        } else if (DateUtil.isAtSameDay(date, maxTime)) {
          // 最后一天
          _whenAtSameDay(
              DateTime(date.year, date.month, date.day, 00, 00), maxTime, data);
        } else {
          Map<int, List<int>> map = {};
          for (int hour = 0; hour <= 23; hour++) {
            List<int> minutes = [];
            for (int minute = 0; minute <= 59; minute++) {
              minutes.add(minute);
            }
            map[hour] = minutes;
          }
          data[date] = map;
        }
      }
    }
    return data;
  }

  static void _whenAtSameDay(
    DateTime minTime,
    DateTime maxTime,
    Map<DateTime, Map<int, List<int>>> data,
  ) {
    if (DateUtil.isAtSameHour(minTime, maxTime)) {
      List<int> minutes = [];
      for (int minute = minTime.minute; minute <= maxTime.minute; minute++) {
        minutes.add(minute);
      }
      data[minTime] = {minTime.hour: minutes};
    } else {
      Map<int, List<int>> hours = {};
      for (int hour = minTime.hour; hour <= maxTime.hour; hour++) {
        List<int> minutes = [];
        if (hour == minTime.hour) {
          for (int minute = minTime.minute; minute <= 59; minute++) {
            minutes.add(minute);
          }
        } else if (hour == maxTime.hour) {
          for (int minute = 0; minute <= maxTime.minute; minute++) {
            minutes.add(minute);
          }
        } else {
          for (int minute = 0; minute <= 59; minute++) {
            minutes.add(minute);
          }
        }
        hours[hour] = minutes;
      }
      data[minTime] = hours;
    }
  }
}
