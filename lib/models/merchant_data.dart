class MerchantData {
  int id;
  String name;
  String communityDescription;
  String communityCity;
  String communityMobile;
  String countryPhonecode;
  String roleName;
  String roleType;
  String countryId;
  String countryName;
  String countryCode;
  String staffCount;
  String memberCount;
  String corporateMemberCount;
  String rating;
  String categoryId;
  String categoryName;
  bool kycVerified;
  String coverPhoto;

  MerchantData({
    this.id,
    this.name,
    this.communityDescription,
    this.communityCity,
    this.communityMobile,
    this.countryPhonecode,
    this.roleName,
    this.roleType,
    this.countryId,
    this.countryName,
    this.countryCode,
    this.staffCount,
    this.memberCount,
    this.corporateMemberCount,
    this.rating,
    this.categoryId,
    this.categoryName,
    this.kycVerified,
    this.coverPhoto,
  });

  MerchantData.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    name = json['community_name'];
    communityDescription = json['community_description'] ?? '';
    communityCity = json['community_city'] ?? '';
    communityMobile = json['community_mobile'] ?? '';
    countryPhonecode = json['country_phonecode'] ?? '';
    roleName = json['role']['role_name'] ?? '';
    roleType = json['role']['role_type'] ?? '';
    countryId = json['community_country']['id'] ?? '';
    countryName = json['community_country']['country_name'] ?? '';
    countryCode = json['community_country']['country_code'] ?? '';
    staffCount = json['staff_count'].toString();
    memberCount = json['member_count'].toString();
    corporateMemberCount = json['corporate_member_count'].toString();
    rating = json['rating'].toString();

    categoryId = json['category']['id'] ?? '0';
    if (json['category']['id'] != null) {
      categoryName = json['category']['name'].toString();
    } else {
      categoryName = '';
    }

    kycVerified = json['community_verified']['kyc_verified'];
    coverPhoto = json['cover_photo'];
  }
}
