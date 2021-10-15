
class Staff {
  String id;
  String staff_name;

  Staff(
      {this.id, this.staff_name});

  Staff.fromJson(Map<String, dynamic> json) {
    id = json['staff_id'];
    staff_name = json['staff_name'];
  }

  Map<String, dynamic> toJson() => {
    "staff_name": staff_name,
    "staff_id": id,
  };
}
