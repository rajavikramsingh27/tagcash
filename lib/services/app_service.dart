import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';

import 'networking.dart';

class AppService {
  static bool isDarkMode(BuildContext context) {
    return Provider.of<ThemeProvider>(context).isDarkMode;
  }

  static bool isUserPerspective(BuildContext context) {
    return Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user';
  }

  static bool isMerchantPerspective(BuildContext context) {
    return Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community';
  }

  static MerchantData merchantData(BuildContext context) {
    return Provider.of<MerchantProvider>(context, listen: false).merchantData;
  }

  static String getUserTypeByType(int userType) {
    String type;
    switch (userType) {
      case 1:
        type = "user";
        break;
      case 2:
        type = "community";
        break;
      case 3:
        type = "system";
        break;
    }

    return type;
  }

  static Future<Wallet> getDefaultWallet() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('user/DefaultWallet');

    if (response["status"] == "success") {
      return Wallet.fromJson(response['result']);
    }

    return null;
  }

  static Future<List<Role>> getCommunityRoles(String communityId) async {
    var apiBodyObj = {"community_id": communityId};

    Map<String, dynamic> response =
        await NetworkHelper.request('community/GetAllRoles', apiBodyObj);

    var status = response["status"].toString();

    if (status == "success") {
      var responseList = response["result"];
      return responseList.map<Role>((json) {
        return Role.fromJson(json);
      }).toList();
    }

    return [];
  }
}
