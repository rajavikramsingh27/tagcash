class BankDeposit {
  int id;
  String bankName;
  String bankFullName;
  String accountNumber;
  String accountName;
  String switfCode;
  int walletId;
  String address;
  String fee;

  BankDeposit(
      {this.id,
      this.bankName,
      this.bankFullName,
      this.accountNumber,
      this.accountName,
      this.switfCode,
      this.walletId,
      this.address,
      this.fee});

  BankDeposit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bankName = json['bank_name'];
    bankFullName = json['bank_full_name'];
    accountNumber = json['account_number'].toString();
    accountName = json['account_name'];
    switfCode = json['switf_code'].toString();
    walletId = json['wallet_id'];
    address = json['address'] ?? '';
    fee = json['fee'];
  }
}
