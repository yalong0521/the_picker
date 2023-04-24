import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:the_picker/src/widget/app_text.dart';

class ToastUtil {
  ToastUtil._();

  /// toast动画时长，单程300，一进一出600
  static const _animDuration = Duration(milliseconds: 300);

  /// toast显示时长，加上动画时长总共1800
  static const _showDuration = Duration(milliseconds: 1500);

  /// 存放待显示的消息
  static final Queue<Toast> _msgQueue = ListQueue();

  /// 用来复用
  static Toast? _previous;

  /// 最常用的方式，单独提供一个方法
  static void show(BuildContext context, String text) =>
      showImmediately(context, Toast(text));

  /// 按顺序显示，即等待前面的都显示完(如果有的话)再显示当前的
  static void showInOrder(BuildContext context, Toast toast) =>
      _showByYourself(context, toast, false);

  /// 立即显示，即清除之前没有显示的(如果有的话)立即显示当前的
  static void showImmediately(BuildContext context, Toast toast) =>
      _showByYourself(context, toast, true);

  static void _showByYourself(
    BuildContext context,
    Toast toast,
    bool isImmediately,
  ) {
    if (_previous != null) {
      if (isImmediately) {
        if (_msgQueue.isNotEmpty) {
          _msgQueue.clear();
        }
        if (_previous!.toastState != null) {
          Toast reuse = _previous!;
          reuse.text = toast.text;
          reuse.gravity = toast.gravity;
          var state = reuse.toastState!;
          state.dismissTimer?.cancel();
          state.animController.value = 0;
          _realShow(context, reuse);
          state.animController.value = 1;
        } else {
          _realShow(context, toast);
        }
      } else {
        _msgQueue.add(toast);
      }
    } else {
      _realShow(context, toast);
    }
  }

  static void _realShow(BuildContext context, Toast toast) {
    var overlayState = toast.toastState == null
        ? _getOverlayState(context)
        : toast.toastState!.overlayState;

    var animController = toast.toastState == null
        ? AnimationController(vsync: overlayState, duration: _animDuration)
        : toast.toastState!.animController;

    var animation = toast.toastState == null
        ? Tween(begin: 0.0, end: 1.0).animate(_getToastCurve(animController))
        : toast.toastState!.animation;

    var overlayEntry = toast.toastState == null
        ? _getOverlayEntry(toast, animation)
        : toast.toastState!.overlayEntry;

    if (toast.toastState == null) {
      // 监听动画状态
      animController.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          // 完全显示了
          var dismiss = Timer(_showDuration, () => animController.reverse());
          toast.toastState?.dismissTimer = dismiss;
        } else if (status == AnimationStatus.dismissed) {
          // 完全隐藏了
          overlayEntry.remove();
          _previous = null;
          if (_msgQueue.isNotEmpty) {
            _realShow(context, _msgQueue.removeFirst());
          }
        }
      });
    }
    toast.toastState ??= ToastState(
      overlayState: overlayState,
      overlayEntry: overlayEntry,
      animation: animation,
      animController: animController,
    );
    _previous = toast;
    // 显示并开始动画
    overlayState.insert(overlayEntry);
    animController.forward();
  }

  static OverlayState _getOverlayState(BuildContext context) {
    final navigatorState = Navigator.of(context);
    return navigatorState.overlay!;
  }

  static OverlayEntry _getOverlayEntry(Toast toast, Animation<double> anim) {
    return OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Opacity(
          opacity: anim.value,
          child: child,
        ),
        child: IgnorePointer(
          child: Align(
            alignment: toast.gravity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: AppText(toast.text, size: 14, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  static CurvedAnimation _getToastCurve(Animation<double> parent) {
    return CurvedAnimation(parent: parent, curve: Curves.fastOutSlowIn);
  }
}

/// 定义吐司类，方便后面扩展，带图片or自定义widget啥的
class Toast {
  String text;
  AlignmentDirectional gravity;
  ToastState? toastState;

  Toast(
    this.text, {
    this.gravity = AlignmentDirectional.center,
    this.toastState,
  });
}

class ToastState {
  final OverlayState overlayState;
  final OverlayEntry overlayEntry;
  final Animation<double> animation;
  final AnimationController animController;
  Timer? dismissTimer;

  ToastState({
    required this.overlayState,
    required this.overlayEntry,
    required this.animation,
    required this.animController,
  });
}
