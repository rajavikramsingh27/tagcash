class BusinessFavorite {
  String communityId;
  String communityName;
  String communityCity;
  bool kycVerified;
  String roleName;
  String membersCount;
  String coverPhoto;
  String profilePhoto;
  String roleType;
  var rating;
  String latitude;
  String longitude;
  bool paidRoleExist;

  BusinessFavorite({
    this.communityId,
    this.communityName,
    this.communityCity,
    this.kycVerified,
    this.roleName,
    this.membersCount,
    this.coverPhoto,
    this.profilePhoto,
    this.roleType,
    this.rating,
    this.latitude,
    this.longitude,
    this.paidRoleExist,
  });

  BusinessFavorite.fromJson(Map<String, dynamic> json) {
    communityId = json['community_id'];
    communityName = json['community_name'];
    communityCity = json['community_city'];
    kycVerified = json['community_verified']['kyc_verified'];

    roleName = json['role_name'];
    membersCount = json['members_count'];
    coverPhoto = json['cover_photo'];
    profilePhoto = json['profile_photo'];
    roleType = json['role_type'];
    rating = json['rating'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    paidRoleExist = json['paid_role_exist'];
  }
}
