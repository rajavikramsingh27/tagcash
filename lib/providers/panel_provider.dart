import 'package:flutter/foundation.dart';

class PanelProvider extends ChangeNotifier {
  String panelName = 'main';

  void setPanelName(String name) {
    this.panelName = name;
    notifyListeners();
  }
}
