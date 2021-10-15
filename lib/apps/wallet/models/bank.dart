class Bank {
  int code;
  String bank;
  int brstn;
  String bankCode;
  bool pesonetEnabled;
  String pesonetFee;
  bool instapayEnabled;
  String instapayFee;
  int instapayLimit;

  Bank(
      {this.code,
      this.bank,
      this.brstn,
      this.bankCode,
      this.pesonetEnabled,
      this.pesonetFee,
      this.instapayEnabled,
      this.instapayFee,
      this.instapayLimit});

  Bank.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    bank = json['bank'];
    brstn = json['brstn'];
    bankCode = json['bank_code'];
    pesonetEnabled = json['pesonet_enabled'];
    pesonetFee = json['pesonet_fee'].toString();
    instapayEnabled = json['instapay_enabled'];
    instapayFee = json['instapay_fee'].toString();
    instapayLimit = json['instapay_limit'];
  }
}
