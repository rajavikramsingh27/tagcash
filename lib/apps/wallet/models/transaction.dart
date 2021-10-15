class Transaction {
  int id;
  String fromAmount;
  String toAmount;
  int walletId;
  String currencyCode;
  String narration;
  String escrowStatus;
  String date;
  String type;
  int toId;
  String toType;
  String firstName;
  String lastName;
  String communityName;
  int communityId;
  int fromId;
  String fromType;
  String sentFromFamilyCreator;
  String sentFromFamilyCreatorId;
  String sentFromFamilyCreatorType;
  String sentByFamilyUser;
  String familyUserId;
  String familyUserType;
  String direction;
  String userCommunityName;
  bool splitted;
  String transactionCategoryId;
  String transactionCategory;
  String address;
  String lat;
  String log;
  String receiptImage;

  Transaction(
      {this.id,
      this.fromAmount,
      this.toAmount,
      this.walletId,
      this.currencyCode,
      this.narration,
      this.escrowStatus,
      this.date,
      this.type,
      this.toId,
      this.toType,
      this.communityName,
      this.firstName,
      this.lastName,
      this.communityId,
      this.fromId,
      this.fromType,
      this.sentFromFamilyCreator,
      this.sentFromFamilyCreatorId,
      this.sentFromFamilyCreatorType,
      this.sentByFamilyUser,
      this.familyUserId,
      this.familyUserType,
      this.direction,
      this.userCommunityName,
      this.splitted,
      this.transactionCategoryId,
      this.transactionCategory,
      this.address,
      this.lat,
      this.log,
      this.receiptImage});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    fromAmount = json['from_amount'].toString();
    toAmount = json['to_amount'].toString();
    walletId = int.parse(json['wallet_id']);
    currencyCode = json['currency_code'];
    narration = json['narration'] ?? '';
    escrowStatus = json['escrow_status'];
    date = json['date'];
    type = json['type'];
    toId = int.parse(json['to_id']);
    toType = json['to_type'];
    communityName = json['community_name'] ?? '';
    firstName = json['first_name'] ?? '';
    lastName = json['last_name'] ?? '';
    communityId = int.tryParse(json['community_id'].toString()) ?? 0;
    fromId = int.parse(json['from_id']);
    fromType = json['from_type'];
    sentFromFamilyCreator = json['sent_from_family_creator'].toString();
    sentFromFamilyCreatorId = json['sent_from_family_creator_id'].toString();
    sentFromFamilyCreatorType =
        json['sent_from_family_creator_type'].toString();
    sentByFamilyUser = json['sent_by_family_user'].toString();
    familyUserId = json['family_user_id'].toString();
    familyUserType = json['family_user_type'].toString();
    direction = json['direction'];
    userCommunityName = json['user_community_name'];
    splitted = json['splitted'];
    transactionCategoryId = json['transaction_category_id'];
    transactionCategory = json['transaction_category'];
    address = json['address'];
    lat = json['lat'];
    log = json['log'];
    receiptImage = json['receipt_image'];
  }
}

class TransactionFilters {
  int fromWalletId;
  int toOrFromId;
  String toOrFromType;
  String currencyCode;

  TransactionFilters(
      {this.fromWalletId,
      this.toOrFromId,
      this.toOrFromType,
      this.currencyCode});
}
