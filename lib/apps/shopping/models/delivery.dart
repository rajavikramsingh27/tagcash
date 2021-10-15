class Delivery {
  int id;
  String name;

  Delivery(this.id, this.name);

  static List<Delivery> getDelivery() {
    return <Delivery>[
      Delivery(1, 'Manually'),
      Delivery(2, 'Grab delivery'),
      Delivery(3, 'Gofer'),
      Delivery(4, 'DHL'),
    ];
  }
}