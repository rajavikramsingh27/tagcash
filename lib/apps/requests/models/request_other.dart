class RequestOther {
  int id;
  String requestAmount;
  String requestType;
  String requestFromType;
  int requestFromId;
  String status;
  String requestDate;
  String remarks;
  String currencyCode;
  String requestFromName;

  RequestOther(
      {this.id,
      this.requestAmount,
      this.requestType,
      this.requestFromType,
      this.requestFromId,
      this.status,
      this.requestDate,
      this.remarks,
      this.currencyCode,
      this.requestFromName});

  RequestOther.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestAmount = json['request_amount'].toString();
    requestType = json['request_type'];
    requestFromType = json['request_from_type'];
    requestFromId = json['request_from_id'];
    status = json['status'];
    requestDate = json['request_date'];
    remarks = json['remarks'].toString();
    currencyCode = json['currency_code'];
    requestFromName = json['request_from_name'];
  }
}
