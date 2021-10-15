class BankApprove {
  String bankName;
  String bankFullName;
  String fee;

  BankApprove({this.bankName, this.bankFullName, this.fee});

  BankApprove.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    bankFullName = json['bank_full_name'];
    fee = json['fee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank_name'] = this.bankName;
    data['bank_full_name'] = this.bankFullName;
    data['fee'] = this.fee;
    return data;
  }
}
