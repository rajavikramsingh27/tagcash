import 'package:flutter/foundation.dart';
import 'package:tagcash/models/merchant_data.dart';

class MerchantProvider extends ChangeNotifier {
  MerchantData merchantData;

  void setMerchantData(MerchantData newData) {
    merchantData = newData;
    notifyListeners();
  }
}
