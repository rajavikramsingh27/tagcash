import 'package:flutter/foundation.dart';

class PerspectiveProvider extends ChangeNotifier {
  String _activePerspective;

  void setActivePerspective(String perspective) {
    _activePerspective = perspective;
    notifyListeners();
  }

  String getActivePerspective() {
    return _activePerspective;
  }
}
