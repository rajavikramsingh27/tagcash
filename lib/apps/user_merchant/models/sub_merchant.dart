class SubMerchant {
  int id;
  String communityName;
  String kycLinkStatus;
  String status;

  SubMerchant({this.id, this.communityName, this.kycLinkStatus, this.status});

  SubMerchant.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    communityName = json['community_name'].toString();
    kycLinkStatus = json['kyc_link_status'].toString();
    status = json['status'];
  }
}
