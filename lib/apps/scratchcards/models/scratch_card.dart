class ScratchCard {
  int id;
  int adId;
  int adPricePerView;
  int adPriceWallet;
  int creatorId;
  int creatorType;
  int noAttempt;
  int noClicksPerAttempt;
  int noAttemptPerDay;
  int noColumns;
  int noRows;
  int quantity;
  int quantityAvailable;
  int winningAmount;
  int winningAmountWalletId;
  int winCombinationId;
  int winAmount;
  String currencyCode;
  String kycCheck;
  String name;
  String image;
  String payForAd;
  String randomAd;
  String scratchcardType;
  String winDate;
  String roleName;

  ScratchCard({
    this.id,
    this.adId,
    this.adPricePerView,
    this.adPriceWallet,
    this.creatorId,
    this.creatorType,
    this.noAttempt,
    this.noClicksPerAttempt,
    this.noAttemptPerDay,
    this.noColumns,
    this.noRows,
    this.quantity,
    this.quantityAvailable,
    this.winningAmount,
    this.winningAmountWalletId,
    this.winCombinationId,
    this.winAmount,
    this.currencyCode,
    this.kycCheck,
    this.name,
    this.image,
    this.payForAd,
    this.randomAd,
    this.scratchcardType,
    this.winDate,
    this.roleName,
  });

  ScratchCard.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adId = json['ad_id'];
    adPricePerView = json['ad_price_per_view'];
    adPriceWallet = json['ad_price_wallet'];
    creatorId = json['creator_id'];
    creatorType = json['creator_type'];
    noAttempt = json['no_attempt'];
    noClicksPerAttempt = json['no_clicks_per_attempt'];
    noAttemptPerDay = json['no_attempt_per_day'];
    noColumns = json['no_columns'];
    noRows = json['no_rows'];
    quantity = json['quantity'];
    quantityAvailable = json['quantity_available'];
    winningAmount = json['winning_amount'];
    winningAmountWalletId = json['winning_amount_wallet_id'];
    winCombinationId = json['win_combination_id'];
    winAmount = json['win_amount'];
    currencyCode = json['currency_code'];
    kycCheck = json['kyc_check'];
    name = json['name'].toString();
    if (json['image'] != null) {
      image = json['image'];
    } else {
      image = "";
    }
    payForAd = json['pay_for_ad'];
    randomAd = json['random_ad'];
    scratchcardType = json['scratchcard_type'];
    winDate = json['win_date'];
    roleName = json['role_name'];
  }
}
