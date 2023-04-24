import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_picker/src/picker/picker_date_component.dart';
import 'package:the_picker/src/state/page_widget.dart';
import 'package:the_picker/src/util/date_format.dart';
import 'package:the_picker/src/widget/app_text.dart';
import 'package:the_picker/src/widget/divider.dart';
import 'package:the_picker/src/widget/icon_rrect.dart';
import 'package:the_picker/src/widget/spacer.dart';
import 'package:the_picker/src/widget/tap_wrapper.dart';

import 'date_range_picker_model.dart';

/// 日期范围选择器
class DateRangePicker extends PageWidget<DateRangePickerModel> {
  final String? title;

  DateRangePicker({
    super.key,
    this.title,
    DateTimeRange? initDateTimeRange,
    DateTimeRange? initSelectedDateTimeRange,
    DateTime? initDateTime,
  }) : super((context) => DateRangePickerModel(context, initDateTimeRange,
            initSelectedDateTimeRange, initDateTime));

  @override
  State<StatefulWidget> createState() => _DateRangePickerState();
}

class _DateRangePickerState
    extends PageWidgetState<DateRangePicker, DateRangePickerModel> {
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
          AppText(
            widget.title ?? '时间范围',
            color: const Color(0xFF232323),
            size: 16,
          ),
          const HSpacer(10),
          _getTimeCheckBox(
            (model) => model.startStateTime,
            () => model.changeStartTimeCheckState(),
            '请选择开始时间',
          ),
          const HSpacer(3),
          const SizedBox(width: 10, child: HDivider(1, Color(0xFF979797))),
          const HSpacer(3),
          _getTimeCheckBox(
            (model) => model.endStateTime,
            () => model.changeEndTimeCheckState(),
            '请选择结束时间',
          ),
        ],
      ),
    );
  }

  Widget _getTimeCheckBox(
    CheckStateDateTime Function(DateRangePickerModel model) selector,
    VoidCallback onTap,
    String hint,
  ) {
    return Selector<DateRangePickerModel, CheckStateDateTime>(
      selector: (context, model) => selector(model),
      builder: (context, value, child) {
        String timeStr;
        if (value.dateTime == null) {
          timeStr = hint;
        } else {
          timeStr = formatDate(value.dateTime!, [yyyy, '.', mm, '.', dd]);
        }
        BoxDecoration decoration;
        Color textColor;
        if (value.checked) {
          decoration = BoxDecoration(
            color: const Color(0xFF1378FE),
            borderRadius: BorderRadius.circular(2),
          );
          textColor = Colors.white;
        } else {
          decoration = BoxDecoration(
            border: Border.all(color: const Color(0xFFDBDBDB), width: 1),
            borderRadius: BorderRadius.circular(2),
          );
          textColor = const Color(0xFFDBDBDB);
        }
        return TapWrapper(
          onTap: onTap,
          child: Container(
            width: 110,
            height: 30,
            alignment: Alignment.center,
            decoration: decoration,
            child: AppText(
              timeStr,
              size: timeStr == hint ? 14 : 16,
              color: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget _wheel() {
    return SizedBox(
      height: 190,
      child: Row(
        children: [
          _wheelItem<int>(
            (m) => m.leftCld,
            model.leftFormatter,
            (index) => model.selectedChangedWhenScrollEnd(leftIndex: index),
            (index) => index == model.leftSelectedIndex,
          ),
          _wheelItem<int>(
            (m) => m.middleCld,
            model.middleFormatter,
            (index) => model.selectedChangedWhenScrollEnd(middleIndex: index),
            (index) => index == model.middleSelectedIndex,
          ),
          _wheelItem<int>(
            (m) => m.rightCld,
            model.rightFormatter,
            (index) => model.selectedChangedWhenScrollEnd(rightIndex: index),
            (index) => index == model.rightSelectedIndex,
          ),
        ],
      ),
    );
  }

  Widget _wheelItem<T>(
    ControllableListData<T> Function(DateRangePickerModel model) selector,
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
        child: Selector<DateRangePickerModel, ControllableListData<T>>(
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
      child: Row(
        children: [
          Expanded(
            child: TapWrapper(
              onTap: model.reset,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsetsDirectional.only(start: 20),
                child: const AppText(
                  '重置',
                  size: 16,
                  color: Color(0xFF747474),
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: TapWrapper(
              onTap: model.confirm,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsetsDirectional.only(end: 20),
                child: const AppText(
                  '确认',
                  size: 16,
                  color: Color(0xFF232323),
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
