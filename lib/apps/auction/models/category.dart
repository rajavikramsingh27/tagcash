class Category {
  int id;
  String name;

  Category(this.id, this.name);

  static List<Category> getDelivery() {
    return <Category>[
      Category(1, 'All'),
      Category(2, 'Currently bidding'),
      Category(3, 'Watching'),
      Category(4, 'My Items for auction'),
    ];
  }
}