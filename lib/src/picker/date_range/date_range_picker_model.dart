import 'package:flutter/material.dart';
import 'package:the_picker/src/picker/picker_data_generator.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_model.dart';
import 'package:the_picker/src/util/toast_util.dart';

import 'date_range_picker.dart';

class DateRangePickerModel extends PageModel<DateRangePicker> {
  final DateTimeRange? receivedInitDateTimeRange;
  final DateTimeRange? _receivedInitSelectedDateTimeRange;
  final DateTime? receivedInitDateTime;
  late DateTimeRange _dateTimeRange;
  late DateTime _initDateTime;
  late Map<int, Map<int, List<int>>> _wheelData;
  late CheckStateDateTime startStateTime, endStateTime;
  late ControllableListData<int> leftCld, middleCld, rightCld;
  int _leftSelectedIndex = 0;
  int _middleSelectedIndex = 0;
  int _rightSelectedIndex = 0;

  DateRangePickerModel(
    super.context,
    this.receivedInitDateTimeRange,
    this._receivedInitSelectedDateTimeRange,
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
    if (_receivedInitSelectedDateTimeRange != null) {
      if (_receivedInitSelectedDateTimeRange!.start
          .isBefore(_dateTimeRange.start)) {
        startStateTime = CheckStateDateTime(_dateTimeRange.start, false);
      } else {
        startStateTime = CheckStateDateTime(
            _receivedInitSelectedDateTimeRange!.start, false);
      }
      if (_receivedInitSelectedDateTimeRange!.end.isAfter(_dateTimeRange.end)) {
        endStateTime = CheckStateDateTime(_dateTimeRange.end, false);
      } else {
        endStateTime =
            CheckStateDateTime(_receivedInitSelectedDateTimeRange!.end, false);
      }
    } else {
      startStateTime = CheckStateDateTime(null, false);
      endStateTime = CheckStateDateTime(null, false);
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
    // 同步时间到顶部显示区域
    if (startStateTime.checked) {
      var currentTime = _getCurrentTime();
      startStateTime = CheckStateDateTime(currentTime, true);
    }
    if (endStateTime.checked) {
      var currentTime = _getCurrentTime();
      endStateTime = CheckStateDateTime(currentTime, true);
    }
    // 通知刷新
    notifyListeners();
  }

  void changeStartTimeCheckState() {
    if (!startStateTime.checked) {
      // 选中时联动列表
      var time = startStateTime.dateTime;
      if (time != null) {
        // 之前已经选择过，恢复到之前选择的开始时间
        _recoverTime(time);
      } else {
        // 之前没选过把当前时间设置为开始时间
        startStateTime.dateTime = _getCurrentTime();
      }
      if (endStateTime.checked) {
        // 同时只能选择一个，如果开始时间也是选中的话就取消选中
        endStateTime = CheckStateDateTime(endStateTime.dateTime, false);
      }
    }
    startStateTime = CheckStateDateTime(
      startStateTime.dateTime,
      !startStateTime.checked,
    );
    notifyListeners();
  }

  void changeEndTimeCheckState() {
    if (!endStateTime.checked) {
      // 选中时联动列表
      var time = endStateTime.dateTime;
      if (time != null) {
        // 之前已经选择过，恢复到之前选择的结束时间
        _recoverTime(time);
      } else {
        // 之前没选过把当前时间设置为结束时间
        endStateTime.dateTime = _getCurrentTime();
      }
      if (startStateTime.checked) {
        // 同时只能选择一个，如果开始时间也是选中的话就取消选中
        startStateTime = CheckStateDateTime(startStateTime.dateTime, false);
      }
    }
    endStateTime = CheckStateDateTime(
      endStateTime.dateTime,
      !endStateTime.checked,
    );
    notifyListeners();
  }

  void reset() {
    startStateTime = CheckStateDateTime(null, false);
    endStateTime = CheckStateDateTime(null, false);
    notifyListeners();
  }

  void confirm() {
    var startTime = startStateTime.dateTime;
    if (startTime == null) {
      ToastUtil.show(context, '请选择开始时间');
      return;
    }
    var endTime = endStateTime.dateTime;
    if (endTime == null) {
      ToastUtil.show(context, '请选择结束时间');
      return;
    }
    if (startTime.isAfter(endTime)) {
      ToastUtil.show(context, '开始时间不能大于结束时间');
      return;
    }
    Navigator.pop<DateTimeRange>(
      context,
      DateTimeRange(start: startTime, end: endTime),
    );
  }

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

  void _recoverTime(DateTime time) {
    _leftSelectedIndex = leftCld.data.indexOf(time.year);
    leftCld = ControllableListData(
      leftCld.data,
      FixedExtentScrollController(initialItem: _leftSelectedIndex),
    );
    var selectedLeft = leftCld.data[_leftSelectedIndex];
    List<int> newMiddleList = _wheelData[selectedLeft]!.keys.toList();
    _middleSelectedIndex = newMiddleList.indexOf(time.month);
    middleCld = ControllableListData(
      newMiddleList,
      FixedExtentScrollController(initialItem: _middleSelectedIndex),
    );
    var selectedMiddle = newMiddleList[_middleSelectedIndex];
    List<int> newRightList = _wheelData[selectedLeft]![selectedMiddle]!;
    _rightSelectedIndex = newRightList.indexOf(time.day);
    rightCld = ControllableListData(
      newRightList,
      FixedExtentScrollController(initialItem: _rightSelectedIndex),
    );
  }
}
