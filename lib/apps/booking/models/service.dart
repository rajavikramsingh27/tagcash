

import 'package:tagcash/apps/booking/models/staff.dart';
import 'package:tagcash/apps/booking/models/working_hour.dart';

class Service {
  String id;
  String name;
  String description;
  String time;
  String service_start_time;
  String service_end_time;
  String amount;
  String colour;
  String currency;
  String variable;
  String available;
  List<WorkingHour> unavailable_hour;
  List<Staff> staff;
  Service(
      this.id,
      this.name,
      this.description,
      this.time,
      this.service_start_time,
      this.service_end_time,
      this.amount,
      this.colour,
      this.currency,
      this.variable,
      this.available,[this.unavailable_hour, this.staff]);

  factory Service.fromJson(Map<String, dynamic> json) {
    if (json['unavailable_hours'] != '') {
      var tagObjsJson1 = json['unavailable_hours'] as List;

      List<WorkingHour> _unavailabletags;
      _unavailabletags = tagObjsJson1.map<WorkingHour>((json) {
        return WorkingHour.fromJson(json);
      }).toList();

      if(json['staff'] != ''){
        var tagObjsJson = json['staff'] as List;

        List<Staff> _tags;
        _tags = tagObjsJson.map<Staff>((json) {
          return Staff.fromJson(json);
        }).toList();

        return Service(
            json['id'] as String,
            json['name'] as String,
            json['description'] as String,
            json['time'] as String,
            json['service_start_time'] as String,
            json['service_end_time'] as String,
            json['amount'] as String,
            json['colour'] as String,
            json['currency'] as String,
            json['variable'] as String,
            json['available'] as String,
            _unavailabletags,
            _tags
        );
      } else{
        return Service(
            json['id'] as String,
            json['name'] as String,
            json['description'] as String,
            json['time'] as String,
            json['service_start_time'] as String,
            json['service_end_time'] as String,
            json['amount'] as String,
            json['colour'] as String,
            json['currency'] as String,
            json['variable'] as String,
            json['available'] as String,
            _unavailabletags,
            []
        );
      }


    } else {
      if (json['staff'] != '') {
        var tagObjsJson = json['staff'] as List;

        List<Staff> _tags;
        _tags = tagObjsJson.map<Staff>((json) {
          return Staff.fromJson(json);
        }).toList();
        return Service(
            json['id'] as String,
            json['name'] as String,
            json['description'] as String,
            json['time'] as String,
            json['service_start_time'] as String,
            json['service_end_time'] as String,
            json['amount'] as String,
            json['colour'] as String,
            json['currency'] as String,
            json['variable'] as String,
            json['available'] as String,
             [],
            _tags
        );

      } else{
        return Service(
          json['id'] as String,
          json['name'] as String,
          json['description'] as String,
          json['time'] as String,
          json['service_start_time'] as String,
          json['service_end_time'] as String,
          json['amount'] as String,
          json['colour'] as String,
          json['currency'] as String,
          json['variable'] as String,
          json['available'] as String,
        );
      }

    }
  }



}
