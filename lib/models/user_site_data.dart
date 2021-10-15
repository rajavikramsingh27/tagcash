class UserSiteData {
  String id;
  String country;
  String name;
  String userFirstname;
  String userLastname;
  String userEmail;
  String userName;
  String userMobile;
  String userDob;
  String rating;
  bool kycVerified;
  int contactStatus;

  UserSiteData(
      {this.id,
      this.country,
      this.name,
      this.userFirstname,
      this.userLastname,
      this.userEmail,
      this.userName,
      this.userMobile,
      this.userDob,
      this.rating,
      this.kycVerified,
      this.contactStatus});

  UserSiteData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    name = json['name'];
    userFirstname = json['user_firstname'];
    userLastname = json['user_lastname'];
    userEmail = json['user_email'];
    userName = json['user_name'];
    userMobile = json['user_mobile'];
    userDob = json['user_dob'];
    rating = json['rating'].toString();
    kycVerified = json['user_verificationdetails']['kyc_verified'];
    contactStatus = json['contact_status'];
  }
}
