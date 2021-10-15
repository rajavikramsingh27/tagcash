class MemberRole {
  String name;
  String value;

  MemberRole({this.name, this.value});

  static List<MemberRole> memberRoles = [
    MemberRole(name: 'Team Leader', value: 'team_leader'),
    MemberRole(name: 'Front End', value: 'front_end'),
    MemberRole(name: 'Back End', value: 'back_end'),
    MemberRole(name: 'Mentor', value: 'mentor'),
    MemberRole(name: 'Designer', value: 'designer'),
  ];
}
