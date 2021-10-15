import 'package:flutter/foundation.dart';

class LoginProvider extends ChangeNotifier {
  bool isLogedin = false;

  void setLoginStatus(bool status) {
    this.isLogedin = status;
    notifyListeners();
  }
}
