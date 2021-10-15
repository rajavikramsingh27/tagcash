class WorkingHour {
  String day;
  String start_time;
  String end_time;

  WorkingHour({this.day,
    this.start_time,
    this.end_time});

  WorkingHour.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    start_time = json['start_time'];
    end_time = json['end_time'];
  }

}
