class AdminRole {
  String name;
  String value;

  AdminRole({this.name, this.value});

  static List<AdminRole> adminRoles = [
    AdminRole(name: 'Admin', value: 'ADMIN'),
    AdminRole(name: 'Mentor', value: 'MENTOR'),
    AdminRole(name: 'Sponsor', value: 'SPONSOR'),
    AdminRole(name: 'Judge', value: 'JUDGE'),
  ];
}
