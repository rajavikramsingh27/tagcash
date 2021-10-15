class Role {
  int id;
  String roleName;
  bool roleDefault;
  String roleType;
  String walletTypeId;
  String currencyCode;
  String fee;
  String noOfDays;

  Role(
      {this.id,
        this.roleName,
        this.roleDefault,
        this.roleType,
        this.walletTypeId,
        this.currencyCode,
        this.fee,
        this.noOfDays});

  Role.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roleName = json['role_name'].toString();
    roleDefault = json['role_default'];
    roleType = json['role_type'];
    walletTypeId = json['charge']['wallet_type_id'] ?? '';
    currencyCode = json['charge']['currency_code'] ?? '';
    fee = json['charge']['fee'] ?? '';
    noOfDays = json['charge']['no_of_days'] ?? '';
  }
}
