class Holiday {
  String date;

  Holiday({this.date});

  Holiday.fromJson(Map<String, dynamic> json) {
    date = json['date'];
  }
}
