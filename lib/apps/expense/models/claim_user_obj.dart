class ClaimUserObj {
  int claimuserId,userId,userType,merchantId,roleType;
  String userFirstName,userLastName,communityName,roleName;

  ClaimUserObj(
      {this.claimuserId,
      this.userId,
      this.userType,
      this.merchantId,
      this.roleType,
      this.userFirstName,
      this.userLastName,
      this.communityName,
      this.roleName
      });

  ClaimUserObj.fromJson(Map<String, dynamic> json) {
    claimuserId = json['claimuser_id'];
    userId = json['user_id'];
    userType = json['user_type'];
    merchantId = json['merchant_id'];
    roleType = json['role_type'];
    userFirstName = json['user_firstname'];
    userLastName = json['user_lastname'];
    communityName = json['community_name'];
    roleName = json['role_name'];
   
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['claimuser_id'] = this.claimuserId;
    data['user_id'] = this.userId;
    data['user_type'] = this.userType;
    data['merchant_id'] = this.merchantId;
    data['role_type'] = this.roleType;
    data['user_firstname'] = this.userFirstName;
    data['user_lastname'] = this.userLastName;
    data['community_name'] = this.communityName;
    data['role_name'] = this.roleName;
    return data;
  }
}