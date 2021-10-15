class AllMerchant {
  String id;
  String communityName;
  String communityDescription;
  String communityCity;
  bool kycVerified;
  String roleType;
  String rating;
  String roleName;
  String coverPhoto;
  String membersCount;
  bool paidRoleExist;

  AllMerchant(
      {this.id,
        this.communityName,
        this.communityDescription,
        this.communityCity,
        this.kycVerified,
        this.roleType,
        this.rating,
        this.roleName,
        this.coverPhoto,
        this.membersCount,
        this.paidRoleExist});

  AllMerchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    communityName = json['community_name'];
    communityDescription = json['community_description'];
    communityCity = json['community_city'];
    kycVerified = json['community_verified']['kyc_verified'];

    roleName = json['role_name'];
    roleType = json['role_type'].toString();
    rating = json['rating'].toString();
    coverPhoto = json['cover_photo'];
    membersCount = json['members_count'];
    paidRoleExist = json['paid_role_exist'];
  }
}
