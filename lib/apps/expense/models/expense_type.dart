class ExpenseType {
  int id;
  String typeDetails;

  ExpenseType(
      {this.id,
      this.typeDetails});

  ExpenseType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeDetails = json['type_details'];
   
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type_details'] = this.typeDetails;
    return data;
  }
}