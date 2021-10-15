class Lend {
  String id;
  String ownerName;
  int ownerId;
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
  //var amountPendingWithInterest;
  var amountPaidWithInterest;
  int installmentsPending;
  int dueStatus;
  String currentStatus;
  var dueAmount;
  List<UploadedFile> uploadedFiles;

  Lend(
      {this.id,
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
      //this.amountPendingWithInterest,
      this.amountPaidWithInterest,
      this.installmentsPending,
      this.dueStatus,
      this.currentStatus,
      this.dueAmount,
        this.uploadedFiles});

  Lend.fromJson(Map<String, dynamic> json) {
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
    if (json['uploaded_files'] != null) {
      print(json['uploaded_files'].toString());
      var list = json['uploaded_files'] as List;
      uploadedFiles = list.map((i) => UploadedFile.fromJson(i)).toList();
      print("Uploaded files");
      for (var i = 0; i < uploadedFiles.length; i++) {
        print(uploadedFiles[i].fileName);
      }
    } else {
      uploadedFiles = [];
    }
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
//      if (json['loaned_details']['amount_pending_with_interest'] != null)
//        amountPendingWithInterest =
//            json['loaned_details']['amount_pending_with_interest'];
//      else
//        amountPendingWithInterest = 0;
      if (json['loaned_details']['amount_paid_with_interest'] != null)
        amountPaidWithInterest = double.parse((json['loaned_details']
                ['amount_paid_with_interest'])
            .toStringAsFixed(2));
      else
        amountPaidWithInterest = 0;
      if (json['loaned_details']['instalments_pending'] != null)
        installmentsPending = json['loaned_details']['instalments_pending'];
      else
        installmentsPending = 0;
    } else {
      loanedAmount = 0;
      amountPending = 0;
      //amountPendingWithInterest = 0;
      amountPaidWithInterest = 0;
      installmentsPending = 0;
    }
    dueStatus = json['due_status'];
    if (this.requestStatus == 1) {
      this.currentStatus = "PLEDGED";
    } else if (this.requestStatus == 2 &&
        this.completedStatus == 0 &&
        this.dueStatus == 0) {
      this.currentStatus = "OWING";
    } else if (this.requestStatus == 2 && this.completedStatus == 1) {
      this.currentStatus = "COMPLETED";
    } else if (this.requestStatus == 2 &&
        this.completedStatus == 0 &&
        this.dueStatus == 1) {
      this.currentStatus = "DEFAULTED";
    }
    if (json['due_amount'] != null) {
      dueAmount = double.parse((json['due_amount']).toStringAsFixed(2));
    } else {
      dueAmount = 0;
    }
  }
}
class UploadedFile {
  String fileName;
  String fileType;
  String fileUrl;

  UploadedFile(
      {this.fileName,
        this.fileType,
        this.fileUrl});

  UploadedFile.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    fileType = json['file_type'];
    fileUrl = json['file_url'];
  }
}



