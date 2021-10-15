class FamilyMember {
  int id;
  int userId;
  String nickName;
  var maxAmount;
  int transferToOwnAcc;
  var balance;
  bool removing = false;

  FamilyMember({
    this.id,
    this.userId,
    this.nickName,
    this.maxAmount,
    this.transferToOwnAcc,
    this.balance,
  });

  FamilyMember.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    nickName = json['nick_name'];
    maxAmount = json['max_amount'];
    transferToOwnAcc = json['transfer_to_own_acc'];
    balance = json['balance']['balance'];
  }
}
