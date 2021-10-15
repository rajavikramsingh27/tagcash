class Appointment {
  String id;
  String merchant_id;
  String service_id;
  String service_name;
  String merchant_name;
  String service_start_time;
  String service_end_time;
  String date;
  String staff_id;

  Appointment(
      {this.id, this.merchant_id, this.service_id, this.service_name, this.merchant_name, this.service_start_time, this.service_end_time,
        this.date, this.staff_id});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchant_id = json['merchant_id'];
    service_id = json['service_id'];
    service_name = json['service_name'];
    merchant_name = json['merchant_name'];
    service_start_time = json['service_start_time'];
    service_end_time = json['service_end_time'];
    date = json['date'];
    staff_id = json['staff_id'];
  }

}
