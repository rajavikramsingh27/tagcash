class Country_code {
  int id;
  String name;

  Country_code(this.id, this.name);

  static List<Country_code> getCurrency() {
    return <Country_code>[
      Country_code(1, '+63'),
      Country_code(2, '+357'),
    ];
  }
}