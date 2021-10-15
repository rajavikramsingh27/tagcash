class UserService {
  String owner_id;
  String owner_name;
  int owner_total_service;
  int owner_total_staff;

  UserService(
      {this.owner_id, this.owner_name, this.owner_total_service, this.owner_total_staff});

  UserService.fromJson(Map<String, dynamic> json) {
    owner_id = json['owner_id'];
    owner_name = json['owner_name'];
    owner_total_service = json['owner_total_service'];
    owner_total_staff = json['owner_total_staff'];
  }

  Map<String, dynamic> toJson() => {
    "owner_id": owner_id,
    "owner_name": owner_name,
    "owner_total_service": owner_total_service,
    "owner_total_staff": owner_total_staff,
  };
}
