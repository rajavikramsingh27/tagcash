class LendUser {
  String pledgeId;
  String fullName;
  var userId;
  int userType;
  var pledgeAmount;
  String lendRequestId;
  int anonymousStatus;

  LendUser({this.pledgeId,
    this.fullName,
    this.userId,
    this.userType,
    this.pledgeAmount,
    this.lendRequestId,
    this.anonymousStatus});

  LendUser.fromJson(Map<String, dynamic> json) {
    pledgeId = json['pledge_id'];
    fullName = json['fullname'];
    userId = json['user_id'];
    userType = json['user_type'];
    pledgeAmount = json['pledge_amount'];
    lendRequestId = json['lend_request_id'];
    anonymousStatus = json['anonymous_status'];
  }
}