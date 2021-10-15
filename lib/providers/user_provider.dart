import 'package:flutter/foundation.dart';
import 'package:tagcash/models/user_data.dart';

class UserProvider extends ChangeNotifier {
  UserData userData;

  void setUserData(UserData newData) {
    userData = newData;
    notifyListeners();
  }
}
