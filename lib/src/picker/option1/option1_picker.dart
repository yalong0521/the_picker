import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_widget.dart';
import 'package:the_picker/src/widget/app_text.dart';
import 'package:the_picker/src/widget/divider.dart';
import 'package:the_picker/src/widget/icon_rrect.dart';
import 'package:the_picker/src/widget/spacer.dart';
import 'package:the_picker/src/widget/tap_wrapper.dart';

import 'option1_picker_model.dart';

/// 单个选项选择器
class Option1Picker<T> extends PageWidget<Option1PickerModel<T>> {
  final List<T> wheelData;
  final String title;
  final int? initSelectedIndex;
  final String Function(T t)? formatter;

  Option1Picker({
    required this.title,
    required this.wheelData,
    super.key,
    this.initSelectedIndex,
    this.formatter,
  }) : super((context) =>
            Option1PickerModel<T>(context, initSelectedIndex, wheelData));

  @override
  State<StatefulWidget> createState() => _Option1PickerState<T>();
}

class _Option1PickerState<T>
    extends PageWidgetState<Option1Picker<T>, Option1PickerModel<T>> {
  @override
  Widget layout() {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(child: _layout()),
    );
  }

  Widget _layout() {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          _title(),
          const HDivider(1, Color(0xFFEDEDED)),
          _wheel(),
          const HDivider(9, Color(0xFFF6F6F6)),
          _button(),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          const IconRRect(),
          const HSpacer(6),
          AppText(widget.title, color: const Color(0xFF232323), size: 16),
          const HSpacer(10),
        ],
      ),
    );
  }

  Widget _wheel() {
    return SizedBox(
      height: 190,
      child: Row(
        children: [
          _wheelItem(
            (m) => m.cld,
            widget.formatter ?? (t) => t.toString(),
            (index) => model.selectedChangedWhenScrollEnd(index),
            (index) => index == model.selectedIndex,
          ),
        ],
      ),
    );
  }

  Widget _wheelItem(
    ControllableListData<T> Function(Option1PickerModel<T> model) selector,
    String Function(T t) formatter,
    ValueChanged<int> selectedChangedWhenScrollEnd,
    bool Function(int index) selected,
  ) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollEndNotification) return false;
          if (notification.metrics is! FixedExtentMetrics) return false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            var index = (notification.metrics as FixedExtentMetrics).itemIndex;
            selectedChangedWhenScrollEnd(index);
          });
          return false;
        },
        child: Selector<Option1PickerModel<T>, ControllableListData<T>>(
          selector: (context, model) => selector(model),
          builder: (context, value, child) {
            return CupertinoPicker.builder(
              key: ValueKey(DateTime.now().millisecond),
              itemExtent: 35,
              useMagnifier: true,
              magnification: 1.1,
              onSelectedItemChanged: null,
              selectionOverlay: null,
              itemBuilder: (_, index) => Center(
                child: AppText(
                  formatter(value.data[index]),
                  size: 16,
                  color: selected(index)
                      ? const Color(0xFF1378FE)
                      : const Color(0xFF747474),
                  weight: selected(index) ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              childCount: value.data.length,
              scrollController: value.controller,
            );
          },
        ),
      ),
    );
  }

  Widget _button() {
    return SizedBox(
      height: 50,
      child: TapWrapper(
        onTap: model.confirm,
        child: Container(
          alignment: Alignment.center,
          child: const AppText(
            '确认',
            size: 16,
            color: Color(0xFF232323),
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
