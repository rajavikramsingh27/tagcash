class Token {
  double balanceAmount;

  //double promisedAmount;
  //FamilyAccountBalance familyAccountBalance;
  int walletId;

  //String walletType;
  //int walletTypeNumeric;
  String walletName;
  String currencyCode;

  //int communityId;
  String communityName;

//  bool canReceiveViaMultichain;
//  String canBurn;
//  String walletDescription;
//  String bankDepositWithdraw;
  TransferPermission transferPermission;
  int decimal;
  bool canIssueMoreLater;

  //bool allowNfcTransfer;
  List<TopUpDetails> topUpDetails;

//  int tokenTypeId;
//  List<dynamic> subSetTokenTypeId;
//  int exchange;
//  String contractAddress;

//  Token(
//      {this.balanceAmount,
//      this.promisedAmount,
//      this.familyAccountBalance,
//      this.walletId,
//      this.walletType,
//      this.walletTypeNumeric,
//      this.walletName,
//      this.currencyCode,
//      this.communityId,
//      this.communityName,
//      this.canReceiveViaMultichain,
//      this.canBurn,
//      this.walletDescription,
//      this.bankDepositWithdraw,
//      this.transferPermission,
//      this.decimal,
//      this.canIssueMoreLater,
//      this.allowNfcTransfer,
//      this.topUpDetails,
//      this.tokenTypeId,
//      this.subSetTokenTypeId,
//      this.exchange,
//      this.contractAddress});
  Token(
      {this.balanceAmount,
        this.walletId,
        this.walletName,
        this.currencyCode,
        this.communityName,
        this.transferPermission,
        this.decimal,
        this.canIssueMoreLater,
        this.topUpDetails});

  Token.fromJson(Map<String, dynamic> json) {
    balanceAmount = json['balance_amount'].toDouble();
//    promisedAmount = json['promised_amount'].toDouble();
//    familyAccountBalance =
//        FamilyAccountBalance.fromJson(json['family_account_balance']);
    walletId = int.parse(json['wallet_id']);
//    walletType = json['wallet_type'];
//    walletTypeNumeric = int.parse(json['wallet_type_numeric']);
    walletName = json['wallet_name'].toString();
    currencyCode = json['currency_code'].toString();
//    communityId = int.parse(json['community_id']);
    communityName = json['community_name'];
//    canReceiveViaMultichain = json['can_receive_via_multichain'];
//    canBurn = json['can_burn'];
//    walletDescription = json['wallet_description'];
//    bankDepositWithdraw = json['bank_deposit_withdraw'];
    transferPermission =
        TransferPermission.fromJson(json['transfer_permission']);
    decimal = json['decimal'];
    canIssueMoreLater = json['can_issue_more_later'].toString() == "y";
//    allowNfcTransfer = json['allow_nfc_transfer'] == "y";
    topUpDetails = json['top_up_details'] != null
        ? List<TopUpDetails>.from(
        json['top_up_details'].map((x) => TopUpDetails.fromJson(x)))
        : null;
//    tokenTypeId = int.parse(json['token_type_id']);
//    subSetTokenTypeId = List<dynamic>.from(json['sub_set_token_type_id']);
//    exchange = int.parse(json['exchange']);
//    contractAddress = json['contract_address'];
  }
}

//class FamilyAccountBalance {
//  int allowance;
//  int spent;
//  int balance;
//  String walletId;
//  String currencyCode;
//  bool isFamilyMember;
//
//  FamilyAccountBalance(
//      {this.allowance,
//      this.spent,
//      this.balance,
//      this.walletId,
//      this.currencyCode,
//      this.isFamilyMember});
//
//  FamilyAccountBalance.fromJson(Map<String, dynamic> json) {
//    allowance = json['allowance'];
//    spent = json['spent'];
//    balance = json['balance'];
//    walletId = json['wallet_id'];
//    currencyCode = json['currency_code'];
//    isFamilyMember = json['is_family_member'];
//  }
//}

class TransferPermission {
//  bool userToUser;
//  bool userToCommunity;
  bool communityToUser;

//  bool communityToCommunity;

//  TransferPermission(
//      {this.userToUser,
//      this.userToCommunity,
//      this.communityToUser,
//      this.communityToCommunity});
  TransferPermission({this.communityToUser});

  TransferPermission.fromJson(Map<String, dynamic> json) {
//    userToUser = json['user_to_user'];
//    userToCommunity = json['user_to_community'];
    communityToUser = json['community_to_user'];
//    communityToCommunity = json['community_to_community'];
  }
}

class TopUpDetails {
  double amount;
  DateTime transferDate;
  String narration;

  TopUpDetails({this.amount, this.transferDate, this.narration});

  TopUpDetails.fromJson(Map<String, dynamic> json) {
    amount = json['amount'].toDouble();
    transferDate = DateTime.parse(json['transfer_date']);
    narration = json['narration'];
  }
}
