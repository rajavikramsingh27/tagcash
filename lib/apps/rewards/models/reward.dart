class Reward {
  String id;
  String userId;
  String userType;
  String roleId;
  String roleName;
  String receiveWalletId;
  String receiveCurrencyCode;
  String receiveAmount;
  String rewardWalletId;
  String rewardCurrencyCode;
  String rewardAmount;
  String createdDate;

  Reward({
    this.id,
    this.userId,
    this.userType,
    this.roleId,
    this.roleName,
    this.receiveWalletId,
    this.receiveCurrencyCode,
    this.receiveAmount,
    this.rewardWalletId,
    this.rewardCurrencyCode,
    this.rewardAmount,
    this.createdDate
  });

  Reward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userType = json['user_type'];
    roleId = json['role_id'];
    roleName = json['role_name'];
    receiveWalletId = json['receive_wallet_id'];
    receiveCurrencyCode = json['receive_currency_code'];
    receiveAmount = json['receive_amount'];
    rewardWalletId = json['reward_wallet_id'];
    rewardCurrencyCode = json['reward_currency_code'];
    rewardAmount = json['reward_amount'];
    createdDate = json['created_date'];
  }
}
