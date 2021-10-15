class ScratchCardList {
  List<Reward> reward;
  List<Public> public;
  ScratchCardList({
    this.reward,
    this.public,
  });
  ScratchCardList.fromJson(dynamic json) {
    if (json['reward'] != null) {
      var list = json['reward'] as List;
      reward = list.map((i) => Reward.fromJson(i)).toList();
    } else {
      reward = [];
    }

    if (json['public'] != null) {
      var list = json['public'] as List;
      public = list.map((i) => Public.fromJson(i)).toList();
    } else {
      public = [];
    }
  }
}

class Reward {
  int id;
  int adId;
  int adPricePerView;
  int adPriceWallet;
  int creatorId;
  int creatorType;
  int noAttempt;
  int noClicksPerAttempt;
  int noColumns;
  int noRows;
  int quantity;
  int quantityAvailable;
  int winningAmount;
  int winningAmountWalletId;
  int winCombinationId;
  String currencyCode;
  String kycCheck;
  String name;
  String image;
  String payForAd;
  String randomAd;
  String scratchcardType;

  Reward({
    this.id,
    this.adId,
    this.adPricePerView,
    this.adPriceWallet,
    this.creatorId,
    this.creatorType,
    this.noAttempt,
    this.noClicksPerAttempt,
    this.noColumns,
    this.noRows,
    this.quantity,
    this.quantityAvailable,
    this.winningAmount,
    this.winningAmountWalletId,
    this.winCombinationId,
    this.currencyCode,
    this.kycCheck,
    this.name,
    this.image,
    this.payForAd,
    this.randomAd,
    this.scratchcardType,
  });

  Reward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adId = json['ad_id'];
    adPricePerView = json['ad_price_per_view'];
    adPriceWallet = json['ad_price_wallet'];
    creatorId = json['creator_id'];
    creatorType = json['creator_type'];
    noAttempt = json['no_attempt'];
    noClicksPerAttempt = json['no_clicks_per_attempt'];
    noColumns = json['no_columns'];
    noRows = json['no_rows'];
    quantity = json['quantity'];
    quantityAvailable = json['quantity_available'];
    winningAmount = json['winning_amount'];
    winningAmountWalletId = json['winning_amount_wallet_id'];
    winCombinationId = json['win_combination_id'];
    currencyCode = json['currency_code'];
    kycCheck = json['kyc_check'];
    name = json['name'];
    image = json['image'];
    payForAd = json['pay_for_ad'];
    randomAd = json['random_ad'];
    scratchcardType = json['scratchcard_type'];
  }
}

class Public {
  int id;
  int adId;
  int adPricePerView;
  int adPriceWallet;
  int creatorId;
  int creatorType;
  int noAttempt;
  int noClicksPerAttempt;
  int noColumns;
  int noRows;
  int quantity;
  int quantityAvailable;
  int winningAmount;
  int winningAmountWalletId;
  int winCombinationId;
  String currencyCode;
  String kycCheck;
  String name;
  String image;
  String payForAd;
  String randomAd;
  String scratchcardType;

  Public({
    this.id,
    this.adId,
    this.adPricePerView,
    this.adPriceWallet,
    this.creatorId,
    this.creatorType,
    this.noAttempt,
    this.noClicksPerAttempt,
    this.noColumns,
    this.noRows,
    this.quantity,
    this.quantityAvailable,
    this.winningAmount,
    this.winningAmountWalletId,
    this.winCombinationId,
    this.currencyCode,
    this.kycCheck,
    this.name,
    this.image,
    this.payForAd,
    this.randomAd,
    this.scratchcardType,
  });

  Public.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adId = json['ad_id'];
    adPricePerView = json['ad_price_per_view'];
    adPriceWallet = json['ad_price_wallet'];
    creatorId = json['creator_id'];
    creatorType = json['creator_type'];
    noAttempt = json['no_attempt'];
    noClicksPerAttempt = json['no_clicks_per_attempt'];
    noColumns = json['no_columns'];
    noRows = json['no_rows'];
    quantity = json['quantity'];
    quantityAvailable = json['quantity_available'];
    winningAmount = json['winning_amount'];
    winningAmountWalletId = json['winning_amount_wallet_id'];
    winCombinationId = json['win_combination_id'];
    currencyCode = json['currency_code'];
    kycCheck = json['kyc_check'];
    name = json['name'].toString();
    image = json['image'];
    payForAd = json['pay_for_ad'];
    randomAd = json['random_ad'];
    scratchcardType = json['scratchcard_type'];
  }
}
