class UserData {
  int id;
  String firstName,
      lastName,
      nickName,
      userName,
      rating,
      mobile,
      userGender,
      userDob,
      email,
      userCity,
      userRegion,
      countryId,
      countryCode,
      countryName,
      countryCallingCode,
      profileBio;
  bool kycVerified;

  UserData({
    this.id,
    this.rating,
    this.firstName,
    this.lastName,
    this.nickName,
    this.userName,
    this.userGender,
    this.userDob,
    this.email,
    this.userCity,
    this.userRegion,
    this.mobile,
    this.countryId,
    this.countryCode,
    this.countryName,
    this.countryCallingCode,
    this.profileBio,
    this.kycVerified,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    rating = json['rating'].toString();
    firstName = json['user_firstname'] ?? '';
    lastName = json['user_lastname'] ?? '';
    nickName = json['user_nickname'] ?? '';
    userName = json['user_name'] ?? '';

    userGender = json['user_gender'] ?? '';
    userDob = json['user_dob'] ?? '';
    email = json['user_email'] ?? '';
    userCity = json['user_city'] ?? '';
    userRegion = json['user_region'] ?? '';
    mobile = json['user_mobile'] ?? '';

    countryId = json['user_country']['country_id'];
    countryCode = json['user_country']['country_code'];
    countryName = json['user_country']['country_name'];
    countryCallingCode = json['user_country']['country_callingcode'];
    profileBio = json['profile_bio'] ?? '';
    kycVerified = json['user_verificationdetails']['kyc_verified'];
  }
  Map<String, dynamic> toMap() => {
        'id': this.id,
        'user_firstname': this.firstName,
        'user_lastname': this.lastName,
        'user_nickname': this.nickName,
        'user_email': this.email,
        'user_mobile': this.mobile,
        'user_country': {
          "country_id": this.countryId,
          "country_code": this.countryCode,
          "country_name": this.countryName,
          "country_callingcode": this.countryCallingCode,
        },
      };
}
