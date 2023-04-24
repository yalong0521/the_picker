import 'package:flutter/material.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_model.dart';

import 'option1_picker.dart';

class Option1PickerModel<T> extends PageModel<Option1Picker<T>> {
  final int? initSelectedIndex;
  final List<T> wheelData;
  late ControllableListData<T> cld;
  int _selectedIndex = 0;

  Option1PickerModel(
    super.context,
    this.initSelectedIndex,
    this.wheelData,
  ) {
    _checkAndInitData();
  }

  void _checkAndInitData() {
    _selectedIndex = initSelectedIndex ?? 0;
    if (_selectedIndex > wheelData.length - 1) {
      _selectedIndex = wheelData.length - 1;
    } else if (_selectedIndex < 0) {
      _selectedIndex = 0;
    }
    cld = ControllableListData(
      wheelData,
      FixedExtentScrollController(initialItem: _selectedIndex),
    );
  }

  int get selectedIndex => _selectedIndex;

  /// 滚动结束刷新数据
  void selectedChangedWhenScrollEnd(int index) {
    _selectedIndex = index;
    // 包装数据
    cld = ControllableListData(
      wheelData,
      FixedExtentScrollController(initialItem: _selectedIndex),
    );
    // 通知刷新
    notifyListeners();
  }

  void confirm() => Navigator.pop<T>(context, _getCurrent());

  T _getCurrent() => wheelData[_selectedIndex];
}
