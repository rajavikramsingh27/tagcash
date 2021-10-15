class CharityRequest {
  String id;
  String ownerName;
  var ownerId;
  int ownerType;
  String title;
  String description;
  var donatedAmount;
  var totalDonated;
  int expiryStatus;
  var rating;
  String createdDate;
  int disableStatus;
  List<DonationHistory> donationHistory;
  List<UploadedFile> uploadedFiles;

  CharityRequest(
      {this.id,
      this.ownerId,
      this.ownerName,
      this.ownerType,
      this.title,
      this.description,
      this.donatedAmount,
      this.totalDonated,
      this.expiryStatus,
      this.rating,
      this.disableStatus,
      this.createdDate,
      this.donationHistory});

  CharityRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerDetails']['user_id'];
    ownerName = json['ownerDetails']['name'];
    ownerType = json['ownerDetails']['user_type'];
    title = json['title'];
    description = json['description'];
    totalDonated = json['total_donated'];
    donatedAmount = json['donated_amount'];
    expiryStatus = json['expiry_status'];
    rating = json['avg_rating'];
    disableStatus = json['disable_status'];
    createdDate = json['created_date'];
    if (json['uploaded_files'] != null) {
      var list = json['uploaded_files'] as List;
      uploadedFiles = list.map((i) => UploadedFile.fromJson(i)).toList();
    } else {
      uploadedFiles = [];
    }
    if (json['donation_history'] != null) {
      var list = json['donation_history'] as List;
      donationHistory = list.map((i) => DonationHistory.fromJson(i)).toList();
    } else {
      donationHistory = [];
    }
  }
}

class DonationHistory {
  String userName;
  String createdDate;
  String amount;

  DonationHistory({this.userName, this.createdDate, this.amount});

  DonationHistory.fromJson(Map<String, dynamic> json) {
    userName = json['username'];
    createdDate = json['created_date'];
    amount = json['amount'];
  }
}

class UploadedFile {
  String fileName;
  String fileType;
  String fileUrl;

  UploadedFile({this.fileName, this.fileType, this.fileUrl});

  UploadedFile.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    fileType = json['file_type'];
    fileUrl = json['file_url'];
  }
}
