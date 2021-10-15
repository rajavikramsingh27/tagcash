class IdentifierData {
  String id;
  String identifierName;
  var identifierValue;
  var merchantId;
  var userId;
  String linkedTo;
  var linkedBy;

  var linkedByType;
  var countryCode;
  var mobileNo;
  String status;

  IdentifierData(
      {this.id,
      this.identifierName,
      this.identifierValue,
      this.merchantId,
      this.userId,
      this.linkedTo,
      this.linkedBy,
      this.linkedByType,
      this.countryCode,
      this.mobileNo,
      this.status});
  IdentifierData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    identifierName = json['identifier_name'].toString();
    identifierValue = json['identifier'];
    merchantId = json['merchant_id'];

    userId = json['user_id'];

    linkedTo = json['linked_to'];

    linkedBy = json['linked_by'];

    linkedByType = json['linked_by_type'];
    countryCode = json['country_code'];
    mobileNo = json['mobile_no'];
    status = json['status'];
  }
}
