class Borrow{
  String id;
  String ownerName;
  var ownerId;
  int ownerType;
  int moduleId;
  int appId;
  int walletId;
  String walletName;
  var amount;
  String duration;
  int interestPercent;
  String title;
  String description;
  String collateralType;
  var collateralValue;
  int pledgedUserCount;
  var pledgedAmount;
  int lendersCount;
  String requestCreated;
  String expiryDate;
  int expiryStatus;
  int requestStatus;
  int approvedStatus;
  int completedStatus;
  String firstTransferDate;
  int payTwiceAMonth;
  var rating;
  var loanedAmount;
  var amountPending;
  var amountPaid;

  Borrow({this.id,
    this.ownerId,
    this.ownerName,
    this.ownerType,
    this.moduleId,
    this.appId,
    this.walletId,
    this.walletName,
    this.amount,
    this.duration,
    this.interestPercent,
    this.title,
    this.description,
    this.collateralType,
    this.collateralValue,
    this.pledgedUserCount,
    this.pledgedAmount,
    this.lendersCount,
    this.requestCreated,
    this.expiryDate,
    this.expiryStatus,
    this.requestStatus,
    this.approvedStatus,
    this.completedStatus,
    this.firstTransferDate,
    this.payTwiceAMonth,
    this.rating,
    this.loanedAmount,
    this.amountPending,
    this.amountPaid
  });

  Borrow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['owner_details']['user_id'];
    ownerName = json['owner_details']['name'];
    ownerType = json['owner_details']['user_type'];
    moduleId = json['module_id'];
    appId = json['app_id'];
    walletId = json['wallet_id'];
    walletName = json['wallet_name'];
    amount = json['amount'];
    duration = json['duration'];
    interestPercent = json['interest_percent'];
    title = json['title'];
    description = json['description'];
    collateralType = json['collateral_type'];
    collateralValue = json['collateral_value'];
    pledgedUserCount = json['pledged_user_count'];
    pledgedAmount = json['pledged_amount'];
    lendersCount = json['lenders_count'];
    requestCreated = json['request_created'];
    expiryDate = json['expiry_date'];
    expiryStatus = json['expiry_status'];
    requestStatus = json['request_status'];
    approvedStatus = json['approved_status'];
    completedStatus = json['completed_status'];
    firstTransferDate = json['first_transfer_date'];
    payTwiceAMonth = json['pay_twice_a_month'];
    rating = json['rating'];
    loanedAmount = json['loaned_details']['loaned_amount'];
    amountPending = json['loaned_details']['amount_pending'];
    amountPaid = json['loaned_details']['amount_paid'];

    if (json['loaned_details'] != null) {
      if (json['loaned_details']['loaned_amount'] != null)
        loanedAmount = json['loaned_details']['loaned_amount'];
      else
        loanedAmount = 0;
      if (json['loaned_details']['amount_pending'] != null)
        amountPending = double.parse(
            (json['loaned_details']['amount_pending']).toStringAsFixed(2));
      else
        amountPending = 0;
      if (json['loaned_details']['amount_paid'] != null)
        amountPaid =
        json['loaned_details']['amount_paid'];
      else
        amountPaid = 0;
    } else {
      loanedAmount = 0;
      amountPending = 0;
      amountPaid = 0;
    }
  }
}