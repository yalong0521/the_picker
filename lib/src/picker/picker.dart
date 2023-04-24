import 'package:flutter/material.dart';

import 'date/date_picker.dart';
import 'date_range/date_range_picker.dart';
import 'date_time/date_time_picker.dart';
import 'option1/option1_picker.dart';
import 'time/time_picker.dart';

class Picker {
  Picker._();

  /// 日期选择器弹窗
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    String? title,
    DateTimeRange? initDateTimeRange,
    DateTime? initDateTime,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => DatePicker(
        title: title,
        initDateTimeRange: initDateTimeRange,
        initDateTime: initDateTime,
      ).page(),
    );
  }

  /// 时间选择器弹窗
  static Future<TimeOfDay?> showTimePicker(
    BuildContext context, {
    String? title,
    TimeOfDay? initTime,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => TimePicker(
        title: title,
        initTime: initTime,
      ).page(),
    );
  }

  /// 日期时间选择器弹窗
  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    String? title,
    DateTimeRange? initDateTimeRange,
    DateTime? initDateTime,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => DateTimePicker(
        title: title,
        initDateTimeRange: initDateTimeRange,
        initDateTime: initDateTime,
      ).page(),
    );
  }

  /// 日期范围选择器弹窗
  static Future<DateTimeRange?> showDateRangePicker(
    BuildContext context, {
    String? title,
    DateTimeRange? initDateTimeRange,
    DateTime? initDateTime,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => DateRangePicker(
        title: title,
        initDateTimeRange: initDateTimeRange,
        initDateTime: initDateTime,
      ).page(),
    );
  }

  /// 单个选项选择器弹窗
  static Future<T?> showOption1Picker<T>(
    BuildContext context, {
    required String title,
    required List<T> wheelData,
    int? initSelectedIndex,
    String Function(T t)? formatter,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => Option1Picker<T>(
        title: title,
        wheelData: wheelData,
        initSelectedIndex: initSelectedIndex,
        formatter: formatter,
      ).page(),
    );
  }
}
