class MerchantVerifyLevel {
  int verificationLevel,kycParentMerchantId;

  MerchantVerifyLevel(
      {this.verificationLevel,
      this.kycParentMerchantId,
     
    });

  MerchantVerifyLevel.fromJson(Map<String, dynamic> json) {
    verificationLevel = json['verification_level'];
    kycParentMerchantId = json['kyc_parent_merchant_id'];
  }
  
}
