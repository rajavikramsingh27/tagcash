class Day {
  int id;
  String name;

  Day(this.id, this.name);

  static List<Day> getDay() {
    return <Day>[
      Day(1, 'Sunday'),
      Day(2, 'Monday'),
      Day(3, 'Tuesday'),
      Day(4, 'Wednesday'),
      Day(5, 'Thursday'),
      Day(6, 'Friday'),
      Day(7, 'Saturday'),
    ];
  }
}