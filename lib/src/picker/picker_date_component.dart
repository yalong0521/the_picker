import 'package:flutter/widgets.dart';

class CheckStateDateTime {
  DateTime? dateTime;
  bool checked;

  CheckStateDateTime(this.dateTime, this.checked);
}

class ControllableListData<T> {
  List<T> data;
  FixedExtentScrollController controller;

  ControllableListData(this.data, this.controller);
}
