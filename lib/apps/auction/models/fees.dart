class Fees {
  int id;
  String name;

  Fees(this.id, this.name);

  static List<Fees> getDelivery() {
    return <Fees>[
      Fees(1, 'Bidding Fee Paid by Buyer(credits)'),
      Fees(2, 'Bidding Fee Paid by Seller(credits)'),
    ];
  }
}