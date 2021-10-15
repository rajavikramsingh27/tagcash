import 'dart:async';

import 'package:flutter/foundation.dart';

class LiveSwitchProvider extends ChangeNotifier {
  bool showLive = false;
  Timer timer;

  void startShowLive() {
    showLive = true;
    timer = Timer(Duration(minutes: 15), stopShowLive);

    notifyListeners();
  }

  void stopShowLive() {
    timer.cancel();
    showLive = false;
    notifyListeners();
  }
}
