class Currency {
  int id;
  String name;

  Currency(this.id, this.name);

  static List<Currency> getRole() {
    return <Currency>[
      Currency(1, 'PHP'),
      Currency(2, 'THB'),
      Currency(3, 'USD'),
      Currency(4, 'GBP'),
      Currency(5, 'EUR'),
      Currency(6, 'AUD'),

    ];
  }
}