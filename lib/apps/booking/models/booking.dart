class Booking {
  String booking_id;
  String name;
  String country_code;
  String contact;
  String email;
  String service_id;
  String booking_date;
  String booking_start_time;
  String booking_end_time;
  String staff_id;
  String booking_notes;

  Booking(
      {this.booking_id, this.name, this.country_code, this.contact, this.email, this.service_id, this.booking_date,
        this.booking_start_time, this.booking_end_time, this.staff_id, this.booking_notes});

  Booking.fromJson(Map<String, dynamic> json) {
    booking_id = json['booking_id'];
    name = json['name'];
    country_code = json['country_code'];
    contact = json['contact'];
    email = json['email'];
    service_id = json['service_id'];
    booking_date = json['booking_date'];
    booking_start_time = json['booking_start_time'];
    booking_end_time = json['booking_end_time'];
    staff_id = json['staff_id'];
    booking_notes = json['booking_notes'];
  }

  Map<String, dynamic> toJson() => {
    "booking_id": booking_id,
    "name": name,
    "country_code": country_code,
    "contact": contact,
    "email": email,
    "service_id": service_id,
    "booking_date": booking_date,
    "booking_start_time": booking_start_time,
    "booking_end_time": this.booking_end_time,
    "staff_id": this.staff_id,
    "booking_notes": booking_notes,
  };
}
