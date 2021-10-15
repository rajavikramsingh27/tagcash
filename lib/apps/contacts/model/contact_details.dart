class ContactDetail {
  int id;
  int contactId;
  String contactEmail;
  String contactFirstname;
  String contactLastname;
  String contactDate;
  int contactStatus;
  int memberStatus;
  var rating;

  ContactDetail({
    this.id,
    this.contactId,
    this.contactEmail,
    this.contactFirstname,
    this.contactLastname,
    this.contactDate,
    this.contactStatus,
    this.memberStatus,
    this.rating,
  });

  ContactDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactId = json['contact_id'];
    contactEmail = json['contact_email'] ?? '';
    contactFirstname = json['contact_firstname'] ?? '';
    contactLastname = json['contact_lastname'] ?? '';
    contactDate = json['contact_date'];
    contactStatus = json['contact_status'];
    memberStatus = json['member_status'];
    rating = json['rating'] ?? 0;
  }
}

class UserVerified {
  bool emailVerified;
  bool smsVerified;
  bool kycVerified;
  UserVerified({this.emailVerified, this.smsVerified, this.kycVerified});

  UserVerified.fromJson(Map<String, dynamic> json) {
    emailVerified = json['email_verified'];
    smsVerified = json['sms_verified'];
    kycVerified = json['kyc_verified'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_verified'] = this.emailVerified;
    data['sms_verified'] = this.smsVerified;
    data['kyc_verified'] = this.kycVerified;
    return data;
  }
}
