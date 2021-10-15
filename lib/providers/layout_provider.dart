import 'package:flutter/foundation.dart';

class LayoutProvider extends ChangeNotifier {
  int lauoutMode = 0;

  void setLauoutMode(int status) {
    this.lauoutMode = status;
    notifyListeners();
  }
}
