import 'package:flutter/material.dart';
import 'package:the_picker/src/picker/picker_data_generator.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_model.dart';
import 'package:the_picker/src/util/date_util.dart';

import 'time_picker.dart';

class TimePickerModel extends PageModel<TimePicker> {
  final TimeOfDay? receivedInitTime;
  late TimeOfDay _initTime;
  late Map<int, List<int>> _wheelData;
  late ControllableListData<int> leftCld, rightCld;
  int _leftSelectedIndex = 0;
  int _rightSelectedIndex = 0;

  TimePickerModel(
    super.context,
    this.receivedInitTime,
  ) {
    _checkAndInitData();
    _initControllableData();
  }

  void _checkAndInitData() {
    _initTime = receivedInitTime ?? TimeOfDay.now();
    _wheelData = DateRangeGen.genTimeData();
  }

  void _initControllableData() {
    List<int> initLeftList = _wheelData.keys.toList();
    _leftSelectedIndex = initLeftList.indexOf(_initTime.hour);
    leftCld = ControllableListData(
      initLeftList,
      FixedExtentScrollController(initialItem: _leftSelectedIndex),
    );

    var selectedLeft = initLeftList[_leftSelectedIndex];
    List<int> initRightList = _wheelData[selectedLeft]!;
    _rightSelectedIndex = initRightList.indexOf(_initTime.minute);
    rightCld = ControllableListData(
      initRightList,
      FixedExtentScrollController(initialItem: _rightSelectedIndex),
    );
  }

  String leftFormatter(int left) => DateUtil.digits(left);

  String rightFormatter(int right) => DateUtil.digits(right);

  int get leftSelectedIndex => _leftSelectedIndex;

  int get rightSelectedIndex => _rightSelectedIndex;

  /// 滚动结束刷新数据
  void selectedChangedWhenScrollEnd({
    int? leftIndex,
    int? rightIndex,
  }) {
    _leftSelectedIndex = leftIndex ?? _leftSelectedIndex;
    _rightSelectedIndex = rightIndex ?? _rightSelectedIndex;
    // 包装数据
    leftCld = ControllableListData(
      leftCld.data,
      FixedExtentScrollController(initialItem: _leftSelectedIndex),
    );
    rightCld = ControllableListData(
      rightCld.data,
      FixedExtentScrollController(initialItem: _rightSelectedIndex),
    );
    // 通知刷新
    notifyListeners();
  }

  void confirm() => Navigator.pop<TimeOfDay>(context, _getCurrentTime());

  TimeOfDay _getCurrentTime() {
    var left = leftCld.data[_leftSelectedIndex];
    var right = rightCld.data[_rightSelectedIndex];
    return TimeOfDay(hour: left, minute: right);
  }
}
