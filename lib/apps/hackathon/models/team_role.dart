class TeamRole {
  int id;
  String name;
  String value;

  TeamRole({this.id, this.name, this.value});

  static List<TeamRole> teamRoles = [
    TeamRole(id: 1, name: 'All', value: ''),
    TeamRole(id: 1, name: 'Team Leader', value: 'Team Leader'),
    TeamRole(id: 1, name: 'Front End', value: 'Front End'),
    TeamRole(id: 1, name: 'Back End', value: 'Back End'),
    TeamRole(id: 1, name: 'Mentor', value: 'Mentor'),
    TeamRole(id: 1, name: 'Designer', value: 'Designer'),
  ];
}
