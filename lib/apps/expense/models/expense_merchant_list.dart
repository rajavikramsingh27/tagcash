class MerchantList {
  int claimuserId,merchantId;
  String communityName;

  MerchantList(
      {this.claimuserId,
      this.merchantId,
      this.communityName});

  MerchantList.fromJson(Map<String, dynamic> json) {
    communityName = json['community_name'];
    claimuserId = json['claimuser_id'];
    merchantId = json['merchant_id'];
   
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['community_name'] = this.communityName;
    data['claimuser_id'] = this.claimuserId;
    data['merchant_id'] = this.merchantId;
    return data;
  }
}
