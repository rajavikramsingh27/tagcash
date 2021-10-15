
import 'package:tagcash/apps/booking/models/working_hour.dart';

import 'holiday.dart';

class StaffList {
  String id;
  int total_appointment;
  String staff_name;
  String tag_id;
  String admin;
  String available;
  List<WorkingHour> working_hour;
  List<Holiday> holiday;

  StaffList(
      this.id,
      this.total_appointment,
      this.staff_name,
      this.tag_id,
      this.admin,
      this.available, [this.working_hour, this.holiday]);

  factory StaffList.fromJson(Map<String, dynamic> json) {
    if (json['working_hours'] != null) {
      var tagObjsJson = json['working_hours'] as List;
      var tagObjsJson1 = json['holidays'] as List;

      List<Holiday> _Holidaystags;
      _Holidaystags = tagObjsJson1.map<Holiday>((json) {
        return Holiday.fromJson(json);
      }).toList();

      List<WorkingHour> _tags;
      _tags = tagObjsJson.map<WorkingHour>((json) {
        return WorkingHour.fromJson(json);
      }).toList();

      return StaffList(
          json['id'] as String,
          json['total_appointment'] as int,
          json['staff_name'] as String,
          json['tag_id'] as String,
          json['admin'] as String,
          json['available'] as String,
          _tags,
          _Holidaystags
      );
    } else {
      return StaffList(
        json['id'] as String,
        json['total_appointment'] as int,
        json['staff_name'] as String,
        json['tag_id'] as String,
        json['admin'] as String,
        json['available'] as String,
      );
    }
  }



}