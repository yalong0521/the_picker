import 'package:flutter/material.dart';
import 'package:the_picker/src/picker/picker_data_generator.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_model.dart';

import 'date_picker.dart';

class DatePickerModel extends PageModel<DatePicker> {
  final DateTimeRange? receivedInitDateTimeRange;
  final DateTime? receivedInitDateTime;
  late DateTimeRange _dateTimeRange;
  late DateTime _initDateTime;
  late Map<int, Map<int, List<int>>> _wheelData;
  late ControllableListData<int> leftCld, middleCld, rightCld;
  int _leftSelectedIndex = 0;
  int _middleSelectedIndex = 0;
  int _rightSelectedIndex = 0;

  DatePickerModel(
    super.context,
    this.receivedInitDateTimeRange,
    this.receivedInitDateTime,
  ) {
    _checkAndInitData();
    _initControllableData();
  }

  void _checkAndInitData() {
    if (receivedInitDateTimeRange != null && receivedInitDateTime != null) {
      _dateTimeRange = receivedInitDateTimeRange!;
      if (receivedInitDateTime!.isBefore(receivedInitDateTimeRange!.start)) {
        _initDateTime = receivedInitDateTimeRange!.start;
      } else if (receivedInitDateTime!
          .isAfter(receivedInitDateTimeRange!.end)) {
        _initDateTime = receivedInitDateTimeRange!.end;
      } else {
        _initDateTime = receivedInitDateTime!;
      }
    } else if (receivedInitDateTimeRange != null) {
      _dateTimeRange = receivedInitDateTimeRange!;
      var now = DateTime.now();
      if (now.isBefore(receivedInitDateTimeRange!.start)) {
        _initDateTime = receivedInitDateTimeRange!.start;
      } else if (now.isAfter(receivedInitDateTimeRange!.end)) {
        _initDateTime = receivedInitDateTimeRange!.end;
      } else {
        _initDateTime = now;
      }
    } else if (receivedInitDateTime != null) {
      _initDateTime = receivedInitDateTime!;
      var start = _initDateTime.subtract(const Duration(days: 365 ~/ 2));
      var end = _initDateTime.add(const Duration(days: 365 ~/ 2));
      _dateTimeRange = DateTimeRange(start: start, end: end);
    } else {
      _initDateTime = DateTime.now();
      var start = _initDateTime.subtract(const Duration(days: 365 ~/ 2));
      var end = _initDateTime.add(const Duration(days: 365 ~/ 2));
      _dateTimeRange = DateTimeRange(start: start, end: end);
    }
    _wheelData = DateRangeGen.genDateData(
      _dateTimeRange.start,
      _dateTimeRange.end,
    );
  }

  void _initControllableData() {
    List<int> initLeftList = _wheelData.keys.toList();
    _leftSelectedIndex = initLeftList.indexOf(_initDateTime.year);
    leftCld = ControllableListData(
      initLeftList,
      FixedExtentScrollController(initialItem: _leftSelectedIndex),
    );

    var selectedLeft = initLeftList[_leftSelectedIndex];
    List<int> initMiddleList = _wheelData[selectedLeft]!.keys.toList();
    _middleSelectedIndex = initMiddleList.indexOf(_initDateTime.month);
    middleCld = ControllableListData(
      initMiddleList,
      FixedExtentScrollController(initialItem: _middleSelectedIndex),
    );

    var selectedMiddle = initMiddleList[_middleSelectedIndex];
    List<int> initRightList = _wheelData[selectedLeft]![selectedMiddle]!;
    _rightSelectedIndex = initRightList.indexOf(_initDateTime.day);
    rightCld = ControllableListData(
      initRightList,
      FixedExtentScrollController(initialItem: _rightSelectedIndex),
    );
  }

  String leftFormatter(int left) => '$left年';

  String middleFormatter(int middle) => '$middle月';

  String rightFormatter(int right) => '$right日';

  int get leftSelectedIndex => _leftSelectedIndex;

  int get middleSelectedIndex => _middleSelectedIndex;

  int get rightSelectedIndex => _rightSelectedIndex;

  /// 滚动结束刷新数据
  void selectedChangedWhenScrollEnd({
    int? leftIndex,
    int? middleIndex,
    int? rightIndex,
  }) {
    // 记录变更之前的数据用于列表改变之后恢复到相应位置（如果新列表中存在该数据）
    var preLeft = leftCld.data[_leftSelectedIndex];
    var preMiddle = middleCld.data[_middleSelectedIndex];
    var preRight = rightCld.data[_rightSelectedIndex];
    // 将所有列表数据填充为新的索引对应的列表数据
    // 年
    List<int> leftList =
        leftIndex == null ? leftCld.data : _wheelData.keys.toList();
    _leftSelectedIndex = leftIndex ?? _leftSelectedIndex;
    _leftSelectedIndex = leftIndex == null
        ? _findOrCloser(leftList, preLeft)
        : _leftSelectedIndex;
    // 月
    List<int> middleList = leftIndex != null
        ? _wheelData[leftList[_leftSelectedIndex]]!.keys.toList()
        : middleCld.data;
    _middleSelectedIndex = middleIndex ?? _middleSelectedIndex;
    _middleSelectedIndex = _middleSelectedIndex > middleList.length - 1
        ? middleList.length - 1
        : _middleSelectedIndex;
    _middleSelectedIndex = middleIndex == null
        ? _findOrCloser(middleList, preMiddle)
        : _middleSelectedIndex;
    // 日
    List<int> rightList = rightIndex != null
        ? rightCld.data
        : _wheelData[leftList[_leftSelectedIndex]]![
            middleList[_middleSelectedIndex]]!;
    _rightSelectedIndex = rightIndex ?? _rightSelectedIndex;
    _rightSelectedIndex = _rightSelectedIndex > rightList.length - 1
        ? rightList.length - 1
        : _rightSelectedIndex;
    _rightSelectedIndex = rightIndex == null
        ? _findOrCloser(rightList, preRight)
        : _rightSelectedIndex;
    // 包装数据
    leftCld = ControllableListData(
      leftList,
      FixedExtentScrollController(initialItem: _leftSelectedIndex),
    );
    middleCld = ControllableListData(
      middleList,
      FixedExtentScrollController(initialItem: _middleSelectedIndex),
    );
    rightCld = ControllableListData(
      rightList,
      FixedExtentScrollController(initialItem: _rightSelectedIndex),
    );
    // 通知刷新
    notifyListeners();
  }

  void confirm() => Navigator.pop<DateTime>(context, _getCurrentTime());

  /// 在列表中找到对应元素，如果没有返回距离最近的一端
  int _findOrCloser(List<int> list, int item) {
    if (list.contains(item)) return list.indexOf(item);
    var toFirst = (list.first - item).abs();
    var toLast = (list.last - item).abs();
    return toFirst > toLast ? list.length - 1 : 0;
  }

  DateTime _getCurrentTime() {
    var left = leftCld.data[_leftSelectedIndex];
    var middle = middleCld.data[_middleSelectedIndex];
    var right = rightCld.data[_rightSelectedIndex];
    return DateTime(left, middle, right);
  }
}
