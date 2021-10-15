import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/localization/language_constants.dart';

class TransferError {
  static errorHandle(BuildContext context, String errorString) {
    bool showAlert = false;
    String message = '';

    switch (errorString) {
      case "insufficient_amount":
      case "insufficent_balance":
      case "insufficient_balance_to_pay_the_amount":
        message = "Insufficient amount";
        break;
      case "crypto_wallets_only_allowded":
        message = "Only crypto wallets allowed";
        break;
      case "to_email_is_not_verified":
        message = "Email is not verified";
        break;
      case "limit_exceeded":
        showAlert = true;
        message = "The user has exceeded their inward allowance.";
        break;
      case "from_level1_failed":
        showAlert = true;
        message = "You are not verified enough transfer this amount.";
        break;
      case "to_level1_failed":
        showAlert = true;
        message =
            "The person you are sending to has not yet verified their account.";
        // message = "The person you are transferring to, is not verified enough to receive this amount.";
        break;
      case "from_limit_exceeded":
        showAlert = true;
        message =
            "Your transaction limit exceeded. Please change verification level to increase limit.";
        break;
      case "to_limit_exceeded":
        showAlert = true;
        message = "Receiver transaction limit exceeded.";
        break;
      case "pin_incorrect":
        message = "PIN incorrect";
        break;
      case "Transaction Failed":
        message = "Transaction Failed";
        break;
      case "invalid_to_email":
        message = "Invalid email";
        break;
      case "asset_not_found":
        message = "Asset not found";
        break;
      case "invalid_parameters_to_and_from_matching":
        // message = "Invalid parameters";
        message = "You cannot send to your own wallet";
        break;
      case "stellar_transfer_failed":
        message = "Stellar transfer failed";
        break;
      case "invalid_crypto_address":
        message = "Invalid address";
        break;
      case "verification_failed":
        message = "KYC verification is required";
        break;
      case "invalid_identifier":
        message = "Invalid identifier";
        break;
      case "loan_defaulted_please_contact_support":
        showAlert = true;
        message = "One of your loan is defaulted. Please contact support.";
        break;
      case "permission_denied":
        showAlert = true;
        message =
            "You do not have sufficient permissions to perform this action.";
        break;
      default:
        message =
            "Unable to process your request at this time. Please try again later.";
        break;
    }

    if (showAlert) {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: message);
    } else {
      // final snackBar = SnackBar(content: Text(message));
      // Scaffold.of(context).showSnackBar(snackBar);

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

// steller send
// {"error":"unable_to_transfer_check_the_sender_has_trustline_added","status":"failed"}
