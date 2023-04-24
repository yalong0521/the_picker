import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'page_model.dart';

abstract class PageWidget<M extends PageModel> extends StatefulWidget {
  final M Function(BuildContext context) modelBuilder;

  const PageWidget(this.modelBuilder, {Key? key}) : super(key: key);

  /// 如果不是页面跳转形式的，例如嵌套在PageView里面的用这个
  Widget page() => ChangeNotifierProvider(create: modelBuilder, child: this);
}

abstract class PageWidgetState<E extends PageWidget, T extends PageModel<E>>
    extends State<E> {
  final String? key;

  /// 是否监听组件生命周期，默认为true
  /// true:组件完全可见触发onResume，完全不可见触发onPause
  /// false:不触发
  final bool listenLifecycle;

  /// 状态栏字体图标风格，默认为Brightness.dark
  /// Brightness.dark->白色，Brightness.light->黑色
  /// [listenLifecycle]为true时才有效
  final Brightness statusBarBrightness;

  PageWidgetState({
    this.key,
    this.listenLifecycle = true,
    this.statusBarBrightness = Brightness.dark,
  });

  T get model => Provider.of<T>(context, listen: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      model.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return layout();
  }

  Widget layout();
}
