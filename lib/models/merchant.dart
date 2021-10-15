class Merchant {
  int communityId;
  String communityName;
  bool kycVerified;

  String roleName;
  String roleType;

  Merchant(
      {this.communityId,
      this.communityName,
      this.kycVerified,
      this.roleName,
      this.roleType});

  Merchant.fromJson(Map<String, dynamic> json) {
    communityId = json['community_id'] != null
        ? int.parse(json['community_id'])
        : int.parse(json['id']);
    communityName = json['community_name'];
    kycVerified = json['community_verified']['kyc_verified'];
    roleName = json['role_name'] ?? '';
    roleType = json['role_type'].toString();
  }
}
