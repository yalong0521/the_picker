import 'package:flutter/material.dart';

abstract class PageModel<T extends StatefulWidget> extends ChangeNotifier {
  BuildContext context;
  bool disposed = false;

  PageModel(this.context);

  void init() {}

  void onDidChangeDependencies() {}

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
