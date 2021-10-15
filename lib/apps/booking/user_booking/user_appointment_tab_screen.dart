import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/booking/models/appointment.dart';
import 'package:tagcash/apps/booking/user_booking/edit_appointment_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:intl/intl.dart';


import '../../../constants.dart';

class UserAppointmentTabScreen extends StatefulWidget {
  @override
  _UserAppointmentTabScreenState createState() => _UserAppointmentTabScreenState();
}

class _UserAppointmentTabScreenState extends State<UserAppointmentTabScreen> with SingleTickerProviderStateMixin  {

  List<Appointment> getData = new List<Appointment>();
  List<Appointment> getAppointmentData = new List<Appointment>();

  bool sync_google = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAppointment();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getAppointment() async {
    getData.clear();
    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/MyAppointment');


    if (response['status'] == 'success') {
      List responseList = response['result'];

      getData = responseList.map<Appointment>((json) {
        return Appointment.fromJson(json);
      }).toList();

      var list = getData;
      list.sort((a, b) => b.date.compareTo(a.date));
      print(list);

      /*List<DateTime> newProducts = [];
      DateFormat format = DateFormat("yyyy-MM-dd");
        for (int i = 0; i < getData.length; i++) {
          newProducts.add(format.parse(getData[i].date));
        }

      newProducts.sort((a,b) => a.compareTo(b));

      for(int i = 0; i<newProducts.length; i++){
        String formatted = format.format(newProducts[i]);
        for (int j = 0; j < getData.length; j++) {
          if(getData[j].date.contains(formatted)){
            Appointment appointment = new Appointment();
            appointment.id = getData[j].id;
            appointment.merchant_id = getData[j].merchant_id;
            appointment.service_id = getData[j].service_id;
            appointment.service_name = getData[j].service_name;
            appointment.merchant_name = getData[j].merchant_name;
            appointment.service_start_time = getData[j].service_start_time;
            appointment.service_end_time = getData[j].service_end_time;
            appointment.date = getData[j].date;
            appointment.staff_id = getData[j].staff_id;
            getAppointmentData.add(appointment);

            print('list' + '' + getAppointmentData.length.toString());
          }
        }
      }*/

      setState(() {
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 20, width: 20,
                            child: Checkbox(
                              activeColor: kPrimaryColor,
                              value: sync_google,
                              onChanged: (val) {
                                setState(() {
                                  sync_google = val;
                                });
                              },
                            )
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Sync with Google Calendar',
                          style: new TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: getData.length,
                      itemBuilder: (BuildContext context, int index){
                        return InkWell(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Color(0xFFACACAC),
                                ),
                                borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Image(
                                    image: NetworkImage(
                                      AppConstants.getUserImagePath() +
                                          getData[index].merchant_id.toString() +
                                          "?kycImage=0",
                                    ),
                                  ),

                                ),
                                SizedBox(width: 10),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getData[index].service_name,
                                        style: Theme.of(context).textTheme.subtitle1.apply(),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                          dateTime(getData[index].date, getData[index].service_start_time, getData[index].service_end_time),
                                        style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: (){
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => EditAppointmentScreen(appointment_id: getData[index].id, owner_id: getData[index].merchant_id,
                                    name: getData[index].merchant_name, service_id: getData[index].service_id, service_name: getData[index].service_name,
                                    date: getData[index].date, service_start_time: getData[index].service_start_time, service_end_time: getData[index].service_end_time, staff_id: getData[index].staff_id)))
                                .then((val)=>val?getAppointment():null);
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }


  String dateTime(String date, String start_time, String end_time) {
    String datetime;

    final DateTime now = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd MMMM');
    String selected_date = formatter.format(now);

    var parts = start_time.split(' ');
    var stime = parts[1].toString();

    var parts1 = end_time.split(' ');
    var etime = parts1[1].toString();

    datetime = selected_date + ', '+ stime.toString() + ' - '+ etime.toString();

    return datetime;
  }

}

