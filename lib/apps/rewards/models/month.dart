class Month {
  bool isSelected;
  String month;
  String monthYear;

  Month({this.isSelected, this.month, this.monthYear});

  Month.fromJson(Map<String, dynamic> json) {
    isSelected = false;
    month = json['month'];
    monthYear = json['month_year'];
  }
}
