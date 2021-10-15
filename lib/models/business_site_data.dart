class BusinessSiteData {
  String id;
  String communityCreatedDate;
  String communityName;
  String communityDescription;
  String communityType;
  bool kycVerified;
  String longitude;
  String latitude;
  String countryId;
  String communityCity;
  String roleType;
  String roleName;
  String rating;
  String coverPhoto;
  String membersCount;
  bool paidRoleExist;

  BusinessSiteData({
    this.id,
    this.communityCreatedDate,
    this.communityName,
    this.communityDescription,
    this.communityType,
    this.kycVerified,
    this.longitude,
    this.latitude,
    this.countryId,
    this.communityCity,
    this.roleType,
    this.roleName,
    this.rating,
    this.coverPhoto,
    this.membersCount,
    this.paidRoleExist,
  });

  BusinessSiteData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    communityCreatedDate = json['community_created_date'];
    communityName = json['community_name'];
    communityDescription = json['community_description'];
    communityType = json['community_type'];
    kycVerified = json['community_verified']['kyc_verified'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    countryId = json['country_id'];
    communityCity = json['community_city'];
    roleType = json['role_type'].toString();
    roleName = json['role_name'].toString();
    rating = json['rating'].toString();
    coverPhoto = json['cover_photo'];
    membersCount = json['members_count'] ?? '';
    paidRoleExist = json['paid_role_exist'] ?? false;
  }
}
