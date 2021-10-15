import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/merchant_detail_screen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_merchant_screen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

class IdentifierHandler {
  BuildContext context;

  void nfcScanStart(BuildContext newContext) async {
    print("Start NFC Process");

    context = newContext;

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) ;

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      print(tag.data);

      var identifier = tag.data['nfca']['identifier'];

      final String tagId =
          identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
      print("NFC-Tag" + tagId.toString());
      searchIdentifierList(tagId.toString());
    });
  }

  nfcScanStop() {
    print("nfc scan stopped");
    NfcManager.instance.stopSession();
  }

  void searchIdentifierList(String identifierValue) async {
    showSnackBar('Checking identifier, please wait a moment');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['search'] = identifierValue;

    Map<String, dynamic> response =
        await NetworkHelper.request('Identifiers/', apiBodyObj);

    if (response['status'] == 'success') {
      List responseList = response['result'];

      if (responseList.length != 0) {
        if (responseList[0]['linked_to'] == "user") {
          searchUsersHandler(responseList[0]['user_id'].toString());
        } else {
          searchCommunityHandler(responseList[0]['merchant_id'].toString());
        }
      } else {
        invalidIdentifiers();
      }
    } else {
      invalidIdentifiers();
    }
  }

  searchUsersHandler(String value) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    if (response['status'] == 'success') {
      List responseList = response['result'];

      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailUserScreen(
              userData: responseList[0],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailMerchantScreen(
              userData: responseList[0],
            ),
          ),
        );
      }

      // if (_model.activePerspectiveType == "user") {
      //         router.push("userScanMenuPage", { resultUser: resultUser, identifier: identifierValue, datId: Math.random() });
      // } else {
      //         router.push("merchantSearchResultPage", { username: nameUserScaned.value, rating: ratingUserScaned.value, role: roleNameScaned.value, role_status: roleStatusScaned, role_type: roleTypeScaned.value, userID: idUserScaned.value, identifier: identifierValue, datId: Math.random() });
      // }
    } else {
      invalidIdentifiers();
    }
  }

  searchCommunityHandler(String value) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantDetailScreen(
            merchantData: responseList[0],
          ),
        ),
      );

      // router.push("merchantScanMenuPage", { resultUser: resultUser, perspective: "user", identifier: identifierValue, datId: Math.random() });

    } else {
      invalidIdentifiers();
    }
  }

  invalidIdentifiers() {
    showSnackBar('Not a valid Identifier');
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }
}
