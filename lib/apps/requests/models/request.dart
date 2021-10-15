class Request {
  int id;
  String requestAmount;
  String requestType;
  String requestToType;
  int requestToId;
  String status;
  String requestDate;
  String remarks;
  String currencyCode;
  String requestToName;

  Request(
      {this.id,
      this.requestAmount,
      this.requestType,
      this.requestToType,
      this.requestToId,
      this.status,
      this.requestDate,
      this.remarks,
      this.currencyCode,
      this.requestToName});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestAmount = json['request_amount'].toString();
    requestType = json['request_type'];
    requestToType = json['request_to_type'];
    requestToId = json['request_to_id'];
    status = json['status'];
    requestDate = json['request_date'];
    remarks = json['remarks'].toString();
    currencyCode = json['currency_code'];
    requestToName = json['request_to_name'];
  }
}
