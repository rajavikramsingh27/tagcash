class RemittanceTransaction {
  int id;
  String refno;
  String txnid;
  String date;
  String type;
  String subType;
  int amount;
  int fee;
  String currency;
  String description;
  String status;
  String email;
  String depositType;
  String remittanceCenter;
  int remittanceId;
  String pickupName;
  String pickupMobile;

  RemittanceTransaction(
      {this.id,
      this.refno,
      this.txnid,
      this.date,
      this.type,
      this.subType,
      this.amount,
      this.fee,
      this.currency,
      this.description,
      this.status,
      this.email,
      this.depositType,
      this.remittanceCenter,
      this.remittanceId,
      this.pickupName,
      this.pickupMobile});

  RemittanceTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    refno = json['refno'];
    txnid = json['txnid'].toString();
    date = json['date'];
    type = json['type'];
    subType = json['sub_type'];
    amount = json['amount'];
    fee = json['fee'];
    currency = json['currency'];
    description = json['description'];
    status = json['status'];
    email = json['email'];
    depositType = json['deposit_type'];
    remittanceCenter = json['remittance_center'];
    remittanceId = json['remittance_id'];
    pickupName = json['pickup_name'];
    pickupMobile = json['pickup_mobile'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['refno'] = this.refno;
    data['txnid'] = this.txnid;
    data['date'] = this.date;
    data['type'] = this.type;
    data['sub_type'] = this.subType;
    data['amount'] = this.amount;
    data['fee'] = this.fee;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data['status'] = this.status;
    data['email'] = this.email;
    data['deposit_type'] = this.depositType;
    data['remittance_center'] = this.remittanceCenter;
    data['remittance_id'] = this.remittanceId;
    data['pickup_name'] = this.pickupName;
    data['pickup_mobile'] = this.pickupMobile;
    return data;
  }
}
