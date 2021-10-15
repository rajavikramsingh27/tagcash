class Currency {
  int id;
  String name;

  Currency(this.id, this.name);

  static List<Currency> getCurrency() {
    return <Currency>[
      Currency(1, 'PHP'),
      Currency(2, 'KSR'),
      Currency(3, 'EUR'),
    ];
  }
}