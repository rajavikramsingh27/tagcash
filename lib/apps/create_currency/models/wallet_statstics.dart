class WalletStatstics {
  WalletAggregateStats system;
  WalletAggregateStats merchant;
  WalletAggregateStats user;
  //int totalHolders;
  List<WalletUserBalance> balances;

  WalletStatstics({
    this.system,
    this.merchant,
    this.user,
    //this.totalHolders,
    this.balances
  });

  WalletStatstics.fromJson(Map<String, dynamic> json) {
    system = WalletAggregateStats.fromJson(json['system']);
    merchant = WalletAggregateStats.fromJson(json['merchant']);
    user = WalletAggregateStats.fromJson(json['user']);
    //totalHolders = json['total_holders'];
    balances = json['balances'].map<WalletUserBalance>((json) {
      return WalletUserBalance.fromJson(json);
    }).toList();
  }

}

class WalletAggregateStats {
  var holders;
  var sum;

  WalletAggregateStats({
    this.holders,
    this.sum
  });

  WalletAggregateStats.fromJson(Map<String, dynamic> json) {
    holders = json['holders'];
    sum = json['sum'];
  }
}


class WalletUserBalance {
  var balanceAmount;
  int balanceId;
  int balanceType;
  String name;
  String communityName;
  String systemName;

  WalletUserBalance({
    this.balanceAmount,
    this.balanceId,
    this.balanceType,
    this.name,
    this.communityName,
    this.systemName,
  });

  WalletUserBalance.fromJson(Map<String, dynamic> json) {
    balanceAmount = json['balance_amount'].toDouble();
    balanceId = json['balance_id'];
    balanceType = json['balance_type'];
    name = json['name'];
    communityName = json['community_name'];
    systemName = json['system_name'];
  }
}