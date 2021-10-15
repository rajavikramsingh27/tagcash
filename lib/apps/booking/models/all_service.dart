class AllService {
  int id;
  String name;

  AllService(this.id, this.name);

  static List<AllService> getCurrency() {
    return <AllService>[
      AllService(1, 'Hairdressers'),
      AllService(2, 'Nail salons'),
      AllService(3, 'Massage'),
      AllService(4, 'Other'),
    ];
  }
}