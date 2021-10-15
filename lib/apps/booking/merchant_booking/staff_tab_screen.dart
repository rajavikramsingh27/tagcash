import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/booking/models/holiday.dart';
import 'package:tagcash/apps/booking/models/staff_list.dart';
import 'package:tagcash/apps/booking/models/working_hour.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;


import '../../../constants.dart';


class StaffTabScreen extends StatefulWidget {
  @override
  _StaffTabScreenState createState() => _StaffTabScreenState();
}

class _StaffTabScreenState extends State<StaffTabScreen> with SingleTickerProviderStateMixin  {
  FocusNode myFocusNode = new FocusNode();
  FocusNode myFocusNode1 = new FocusNode();


  List<StaffList> getData = new List<StaffList>();
  List<WorkingHour> getHourData = new List<WorkingHour>();
  bool isLoading = false, hide_variable = false;


  TextEditingController _staff_nameController = TextEditingController();
  TextEditingController _tag_idController = TextEditingController();

  List<String> selectedDate = [];

  List<String> selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> selectedStartTime = ['', '', '', '', '', '', ''];
  List<String> selectedEndTime = ['', '', '', '', '', '', ''];


  List<String> selectedCurrentDay = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getService();
  }

  void getService() async  {
    getData.clear();
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/listStaff');

    List responseList = response['result'];

    getData = responseList.map<StaffList>((json) {
      return StaffList.fromJson(json);
    }).toList();
    var jsonn = response['result'];

    print(getData.length);
      if (response['status'] == 'success') {
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



  void addStaff(bool admin, bool available, List<String> workinghourslist, List<String> holidayslist) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['staff_name'] = _staff_nameController.text;
    apiBodyObj['tag_id'] = _tag_idController.text;
    apiBodyObj['admin'] = admin.toString();
    apiBodyObj['available'] = available.toString();
    apiBodyObj['working_hours'] = workinghourslist.toString();
    apiBodyObj['holidays'] = holidayslist.toString();
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/AddStaff', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getService();


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


  void editStaff(String staff_id, bool admin, bool available, List<String> workinghourslist, List<String> holidayslist) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = staff_id;
    apiBodyObj['staff_name'] = _staff_nameController.text;
    apiBodyObj['tag_id'] = _tag_idController.text;
    apiBodyObj['admin'] = admin.toString();
    apiBodyObj['available'] = available.toString();
    apiBodyObj['working_hours'] = workinghourslist.toString();
    apiBodyObj['holidays'] = holidayslist.toString();
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/EditStaff', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      selectedStartTime = ['', '', '', '', '', '', ''];
      selectedEndTime = ['', '', '', '', '', '', ''];

      getService();


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

  void deleteStaff(String staff_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['staff_id'] = staff_id;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/RemoveStaff', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getService();


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
            ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: getData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                               border: Border.all(
                                   width: 0.5,
                                 color: Color(0xFFACACAC),
                               ),
                               borderRadius: BorderRadius.circular(5.0)
                           ),
                          child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getData[index].staff_name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      getData[index].total_appointment.toString() +' appointments',
                                      style: Theme.of(context).textTheme.bodyText1.apply(color: Color(0xFFACACAC)),
                                    ),

                                  ],
                                ),
                          ),
                        ),
                        onTap: () async {
                          displayBottomSheet(context, 'edit',  getData[index].id, getData[index].staff_name,getData[index].tag_id,
                              getData[index].admin, getData[index].available, getData[index].working_hour, getData[index].holiday);
                        }
                    );
                  },
            ),
            Container(
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  toggle()
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  Widget toggle() {
    return FloatingActionButton(
      onPressed: () {
        displayBottomSheet(context, 'add', '', '', '', '','', [], []);
      },
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 40,
      ),
      backgroundColor: kPrimaryColor,
      elevation: 5,
    );
  }

  void displayBottomSheet(BuildContext context, String type, String staff_id, String staff_name, String tag_id,
      String staffadmin, String staffavailable, List<WorkingHour> working_hour, List<Holiday> holiday) {
    String holidaydate;
    String days, StartTime, EndTime;

    bool admin = false, available = false;

    List<String> workinghourslist = [];
    List<String> holidayslist = [];

    var working_hours;
    var holidays;

    String showSelectHours = '', mSelectHolidays = '';

    _staff_nameController.text = staff_name;
    _tag_idController.text = tag_id;
    if(staffadmin == 'true'){
      admin = true;
    }else{
      admin = false;
    }
    if(staffavailable == 'true'){
      available = true;
    }else{
      available = false;
    }

    selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    selectedStartTime = ['', '', '', '', '', '', ''];
    selectedEndTime = ['', '', '', '', '', '', ''];

    selectedDate.clear();

    for(int i=0; i<working_hour.length; i++){
      if(working_hour[i].day == 'Monday'){
        selectedStartTime.insert(0, working_hour[i].start_time);
        selectedEndTime.insert(0, working_hour[i].end_time);

        days = selectedDay[0];
        StartTime = selectedStartTime[0];
        EndTime = selectedEndTime[0];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Tuesday'){
        selectedStartTime.insert(1, working_hour[i].start_time);
        selectedEndTime.insert(1, working_hour[i].end_time);

        days = selectedDay[1];
        StartTime = selectedStartTime[1];
        EndTime = selectedEndTime[1];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Wednesday'){
        selectedStartTime.insert(2, working_hour[i].start_time);
        selectedEndTime.insert(2, working_hour[i].end_time);

        days = selectedDay[2];
        StartTime = selectedStartTime[2];
        EndTime = selectedEndTime[2];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Thursday'){
        selectedStartTime.insert(3, working_hour[i].start_time);
        selectedEndTime.insert(3, working_hour[i].end_time);

        days = selectedDay[3];
        StartTime = selectedStartTime[3];
        EndTime = selectedEndTime[3];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Friday'){
        selectedStartTime.insert(4, working_hour[i].start_time);
        selectedEndTime.insert(4, working_hour[i].end_time);

        days = selectedDay[4];
        StartTime = selectedStartTime[4];
        EndTime = selectedEndTime[4];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Saturday'){
        selectedStartTime.insert(5, working_hour[i].start_time);
        selectedEndTime.insert(5, working_hour[i].end_time);

        days = selectedDay[5];
        StartTime = selectedStartTime[5];
        EndTime = selectedEndTime[5];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(working_hour[i].day == 'Sunday'){
        selectedStartTime.insert(6, working_hour[i].start_time);
        selectedEndTime.insert(6, working_hour[i].end_time);

        days = selectedDay[6];
        StartTime = selectedStartTime[6];
        EndTime = selectedEndTime[6];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';
        print(showSelectHours);

      }

    }

    for(int i=0; i<holiday.length; i++){
      selectedDate.add(holiday[i].date);
      holidaydate = selectedDate[i];
      holidays = '{"date" : "$holidaydate"}';
      holidayslist.add(holidays);
      mSelectHolidays = '$mSelectHolidays $holidaydate\n\n';
    }


    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return BottomSheet(
            backgroundColor: Colors.transparent,
              onClosing: (){},
              builder: (BuildContext context){
                return
                  StatefulBuilder(
                  builder: (BuildContext context, setState) =>
                      Container(
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.only(
                                  topLeft:  const  Radius.circular(20.0),
                                  topRight: const  Radius.circular(20.0))
                          ),
                          padding: EdgeInsets.all(20),
                          height: 600,
                          child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: TextField(
                                          focusNode: myFocusNode,
                                          textCapitalization: TextCapitalization.sentences,
                                          controller: _staff_nameController,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            labelText: 'Staff Name',
                                              labelStyle: TextStyle(
                                                  color: myFocusNode.hasFocus ? kPrimaryColor : kPrimaryColor
                                              ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: kPrimaryColor),
                                            ),
                                          ),
                                          style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        child:  TextField(
                                          focusNode: myFocusNode1,
                                          textCapitalization: TextCapitalization.sentences,
                                          controller: _tag_idController,
                                          decoration: InputDecoration(
                                            labelText: 'TAG ID',
                                              labelStyle: TextStyle(
                                                  color: myFocusNode1.hasFocus ? kPrimaryColor : kPrimaryColor
                                              ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: kPrimaryColor),
                                            ),
                                          ),
                                          style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                        ),
                                      ),
                                    )
                                  ],

                                ),
                              ),

                              SizedBox(height: 20),

                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: 20, width: 20,
                                                child:Theme(
                                                  data: Theme.of(context).copyWith(
                                                    unselectedWidgetColor: Colors.grey,
                                                  ),
                                                  child: Checkbox(activeColor: kPrimaryColor,
                                                    value: admin,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        FocusScope.of(context).unfocus();
                                                        admin = val;
                                                      });
                                                    },),
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                Flexible(
                                  flex: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 2),
                                        width: MediaQuery.of(context).size.width,
                                        child:  GestureDetector(
                                          onTap: (){
                                            if(admin == true){
                                              setState(() {
                                                FocusScope.of(context).unfocus();
                                                admin = false;
                                              });
                                            }else{
                                              setState(() {
                                                FocusScope.of(context).unfocus();
                                                admin = true;
                                              });
                                            }
                                          },
                                          child: Text(
                                            'Admin (can see and make all appointments)',
                                            style: new TextStyle(fontSize: 14.0, color: Colors.black),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                     child: Container(
                                           width: MediaQuery.of(context).size.width,
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             mainAxisAlignment: MainAxisAlignment.start,
                                             children: [
                                               SizedBox(
                                                   height: 20, width: 20,
                                                   child:Theme(
                                                     data: Theme.of(context).copyWith(
                                                       unselectedWidgetColor: Colors.grey,
                                                     ),
                                                     child: Checkbox(activeColor: kPrimaryColor,
                                                       value: available,
                                                       onChanged: (val) {
                                                         setState(() {
                                                           FocusScope.of(context).unfocus();
                                                           available = val;
                                                         });
                                                       },),
                                                   )
                                               ),
                                             ],
                                           )
                                         ),
                                    ),

                                    Flexible(
                                      flex: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 2),
                                            width: MediaQuery.of(context).size.width,
                                            child: GestureDetector(
                                              onTap: (){
                                                if(available == true){
                                                  setState(() {
                                                    FocusScope.of(context).unfocus();
                                                    available = false;
                                                  });
                                                }else{
                                                  setState(() {
                                                    FocusScope.of(context).unfocus();
                                                    available = true;
                                                  });
                                                }
                                              },
                                              child: Text(
                                                'Available (if not will not appear or get booked)',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: new TextStyle(fontSize: 14.0, color: Colors.black),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    )


                                  ],
                                ),
                              ),
                              SizedBox(height: 30),

                              InkWell(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Working Hours',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(width: 15),
                                      Icon(Icons.add_circle, size: 28, color: kPrimaryColor,)
//                                      FaIcon(FontAwesomeIcons.plusCircle, size: 24, color: kPrimaryColor,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  working_hours = '';
                                  workinghourslist.clear();
                                  FocusScope.of(context).unfocus();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _WorkingHourDialog(
                                          type: type,
                                          selectedDay: selectedDay,
                                          selectedStartTime: selectedStartTime,
                                          selectedEndTime: selectedEndTime,
                                          onSelectedDayListChanged: (value) {
                                            selectedDay = value;
                                          },
                                          onSelectedStartTimeListChanged: (value) {
                                            selectedStartTime = value;
                                          },
                                          onSelectedEndTimeListChanged: (value) {
                                            showSelectHours = '';
                                            selectedEndTime = value;
//                                            String days, StartTime, EndTime;
                                            print(selectedEndTime.length);
                                            if(selectedDay.length > 0){
                                              if(selectedEndTime[0] == '' && selectedEndTime[1] == ''&& selectedEndTime[2] == ''&& selectedEndTime[3] == ''&& selectedEndTime[4] == ''&& selectedEndTime[5] == ''&& selectedEndTime[6] == ''){
                                                setState(() {
                                                  working_hours = '';
                                                  workinghourslist.clear();
                                                  showSelectHours = '';
                                                });
                                              }
                                              for(int i = 0; i<selectedDay.length; i++){
                                                if(selectedEndTime[i] != ''){
                                                  setState(() {
                                                    days = selectedDay[i];
                                                    StartTime = selectedStartTime[i];
                                                    EndTime = selectedEndTime[i];
                                                    working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
                                                    workinghourslist.add(working_hours);
                                                    showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

                                                  });
                                                } else{

                                                }
                                              }
                                            } else{
                                              setState(() {
                                                working_hours = '';
                                                workinghourslist.clear();
                                                showSelectHours = '';
                                              });
                                            }
                                          },
                                        );
                                      }
                                  );
                                },
                              ),

                              SizedBox(height: 15),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  showSelectHours,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyText1.apply(color: Color(0xFFACACAC)),
                                ),
                              ),
                              SizedBox(height: 30),
                              InkWell(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Exceptions, Holidays',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(width: 15),
                                      Icon(Icons.add_circle, size: 28, color: kPrimaryColor,)
//                                      FaIcon(FontAwesomeIcons.plusCircle, size: 24, color: kPrimaryColor,),
                                    ],
                                  ),
                                ),
                                onTap: (){
                                  FocusScope.of(context).unfocus();
                                  holidaydate = '';

                                  holidays = '';
                                  holidayslist.clear();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _HolidayDialog(
                                          selectedDate: selectedDate,
                                          onSelectedDateListChanged: (value) {
                                            mSelectHolidays = '';
                                            selectedDate = value;

                                            selectedDate.sort((a,b) {
                                              return a.compareTo(b);
                                            });
                                            List<DateTime> newProducts = [];
                                            DateFormat format = DateFormat("dd-MMMM-yyyy");

                                            for (int i = 0; i < selectedDate.length; i++) {
                                              newProducts.add(format.parse(selectedDate[i]));
                                            }

                                            newProducts.sort((a,b) => a.compareTo(b));

                                            final DateTime now = DateTime.now();

                                            if(newProducts.length != 0){
                                              for(int i = 0; i<newProducts.length; i++){
                                                setState(() {
                                                  String formatted = format.format(newProducts[i]);
                                                  holidaydate = formatted;
                                                  holidays = '{"date" : "$holidaydate"}';
                                                  holidayslist.add(holidays);
                                                  mSelectHolidays = '$mSelectHolidays $holidaydate\n\n';
                                                });
                                              }
                                            }else{
                                              setState(() {
                                                mSelectHolidays = '';
                                              });
                                            }

                                          },
                                        );
                                      }
                                  );
                                },
                              ),

                              SizedBox(height: 15),

                              Container(
                                height: 150,
                                width: MediaQuery.of(context).size.width,
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Text(
                                      mSelectHolidays,
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context).textTheme.bodyText1.apply(color: Color(0xFFACACAC)),
                                    ),
                                  ),
                                )
                              ),

                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.only(top: 20),
                                  height: MediaQuery.of(context).size.height,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      type == 'edit'?
                                      Flexible(
                                          flex: 1,
                                          child: Container(
                                            child: ButtonTheme(
                                              height: 40,
                                              minWidth: MediaQuery.of(context).size.width,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: RaisedButton(
                                                color: kUserBackColor,
                                                onPressed: () {

                                                  Widget cancelButton = FlatButton(
                                                    child: Text("No"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  );
                                                  Widget continueButton = FlatButton(
                                                    child: Text("Yes"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                      deleteStaff(staff_id);
                                                    },
                                                  );

                                                  AlertDialog alert = AlertDialog(
                                                    title: Text(""),
                                                    content: Text('Are you sure you want to delete this staff?'),
                                                    actions: [
                                                      continueButton,
                                                      cancelButton,

                                                    ],
                                                  );

                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return alert;
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )):Container(),

                                      type == 'edit'?
                                          SizedBox(width:10):Container(),
                                      Flexible(
                                          flex: 2,
                                          child: Container(
                                            child: ButtonTheme(
                                              height: 40,
                                              minWidth: MediaQuery.of(context).size.width,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: RaisedButton(
                                                color: kPrimaryColor,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  if(type == 'add'){
                                                    addStaff(admin, available, workinghourslist, holidayslist);
                                                  }else{
                                                    editStaff(staff_id, admin, available, workinghourslist, holidayslist);
                                                  }
                                                },
                                                child: Text(
                                                  'SAVE',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                );
              }
          );

        });
  }

}


class _HolidayDialog extends StatefulWidget {
  _HolidayDialog({
    this.selectedDate,
    this.onSelectedDateListChanged,
  });

  final List<String> selectedDate;
  final ValueChanged<List<String>> onSelectedDateListChanged;


  @override
  _HolidayDialogState createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<_HolidayDialog> {
  List<String> _tempSelectedDate = [];


  DateTime _currentDate = new DateTime(2020, 11, 15);

  List<DateTime> _selectedDates;
  DateTime _firstDate;
  DateTime _lastDate;

  String _selectedDate;
  String _dateCount;
  String _range;
  String _rangeCount;


  @override
  void initState() {
    final now = DateTime.now();
    _selectedDates = [
      now.subtract(Duration(days: 1)),
    ];
    _firstDate = DateTime.now().subtract(Duration(days: 0));
    _lastDate = DateTime.now().add(Duration(days: 3720));

    _tempSelectedDate = widget.selectedDate;
    _selectedDate = '';
    _dateCount = '';
    _range = '';
    _rangeCount = '';

    List<DateTime> days = [];
    for(int i = 0; i<_tempSelectedDate.length; i++){

      var inputFormat = DateFormat("dd-MMMM-yyyy");
      var date1 = inputFormat.parse(_tempSelectedDate[i].toString());

      var outputFormat = DateFormat("yyyy-MM-dd");
      var date2 = outputFormat.parse("$date1");

      DateTime dateTimeCreatedAt = DateTime.parse(date2.toString());
      DateTime dateTimeNow = DateTime.now();
      final differenceInDays = dateTimeCreatedAt.difference(dateTimeNow).inDays;
      print(differenceInDays + 1);

      int diff = differenceInDays+1;
      if(diff > 0){
        days.add(dateTimeNow.add(Duration(days: differenceInDays + 1)));
        _selectedDates.add(dateTimeNow.add(Duration(days: differenceInDays + 1)));
      }
    }


    super.initState();

  }


  void _onSelectedDateChanged(List<DateTime> newDates) {
    setState(() {
      _tempSelectedDate.clear();

      _selectedDates = newDates;
      for(int i=0; i<newDates.length; i++){
        String date = _selectedDates[i].toString();
        final DateTime now = DateTime.parse(date);
        final DateFormat formatter = DateFormat('dd-MMMM-yyyy');
        final String formatted = formatter.format(now);

        _tempSelectedDate.add(formatted);

        print(_tempSelectedDate.length);

      }

      _tempSelectedDate = List.from(_tempSelectedDate)
        ..removeAt(0);

      print(_tempSelectedDate.length);

    });
  }

  bool _isSelectableCustom (DateTime day) {
    return day.weekday < 6;
  }



  @override
  Widget build(BuildContext context) {

    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText1
            .copyWith(color: Colors.white),
        selectedSingleDateDecoration: BoxDecoration(
            color: kPrimaryColor, shape: BoxShape.circle));
    return Container(
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child:Icon(
                                Icons.close,
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
//                                widget.onSelectedDateListChanged(_tempSelectedDate);
                              },)
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child:  Text(
                      'Select Holidays',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),


                  Container(
                      margin: EdgeInsets.all(20),
                      decoration: new BoxDecoration(
                          border:
                          Border.all(color: Color(0xFFACACAC), width: 0.5),
                          borderRadius: BorderRadius.circular(5.0)),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 300,
                            child: dp.DayPicker.multi(
                              selectedDates: _selectedDates,
                              onChanged: _onSelectedDateChanged,
                              firstDate: _firstDate,
                              lastDate: _lastDate,
                              datePickerStyles: styles,
                              datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                                  maxDayPickerRowCount: 2,
                                  showPrevMonthEnd: true,
                                  showNextMonthStart: true
                              ),
                              selectableDayPredicate: _isSelectableCustom,
                            ),
                          ),

                        ],
                      )),


                  Container(
                    padding: EdgeInsets.all(20),
                    child: ButtonTheme(
                      height: 40,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: kPrimaryColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedDateListChanged(_tempSelectedDate);
                          });
                        },
                        child: Text(
                          'SAVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );

  }}






class _WorkingHourDialog extends StatefulWidget {
  _WorkingHourDialog({
    this.type,
    this.selectedDay,
    this.selectedStartTime,
    this.selectedEndTime,
    this.onSelectedDayListChanged,
    this.onSelectedStartTimeListChanged,
    this.onSelectedEndTimeListChanged,
  });
 String type;
  final List<String> selectedDay;
  final List<String> selectedStartTime;
  final List<String> selectedEndTime;
  final ValueChanged<List<String>> onSelectedDayListChanged;
  final ValueChanged<List<String>> onSelectedStartTimeListChanged;
  final ValueChanged<List<String>> onSelectedEndTimeListChanged;


  @override
  __WorkingHourDialogState createState() => __WorkingHourDialogState();
}

class __WorkingHourDialogState extends State<_WorkingHourDialog> {
  List<String> _tempSelectedDay = [];
  List<String> _tempSelectedStartTime = [];
  List<String> _tempSelectedEndTime = [];

  int mon_sHour, tues_sHour, wednes_sHour, thurs_sHour, fri_sHour, satur_sHour, sun_sHour;
  int mon_sMin, tues_sMin, wednes_sMin, thurs_sMin, fri_sMin, satur_sMin, sun_sMin;
  int  mon_eHour, tues_eHour, wednes_eHour, thurs_eHour, fri_eHour, satur_eHour, sun_eHour;
  int mon_eMin, tues_eMin, wednes_eMin, thurs_eMin, fri_eMin, satur_eMin, sun_eMin;
  var _monday_stime = '', _tuesday_stime = '', _wednesday_stime = '', _thursday_stime = '',_friday_stime = '', _saturday_stime = '', _sunday_stime = '';
  var _monday_etime = '', _tuesday_etime = '', _wednesday_etime = '', _thursday_etime = '', _friday_etime = '', _saturday_etime = '', _sunday_etime = '';
  bool startTime = false, endTime = false;


  @override
  void initState() {
    _tempSelectedDay = widget.selectedDay;
    _tempSelectedStartTime = widget.selectedStartTime;
    _tempSelectedEndTime = widget.selectedEndTime;


    for(int i=0; i<_tempSelectedDay.length; i++){
      if(_tempSelectedDay[i] == 'Monday'){
        _monday_stime = _tempSelectedStartTime[i];
        _monday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Tuesday'){
        _tuesday_stime = _tempSelectedStartTime[i];
        _tuesday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Wednesday'){
        _wednesday_stime = _tempSelectedStartTime[i];
        _wednesday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Thursday'){
        _thursday_stime = _tempSelectedStartTime[i];
        _thursday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Friday'){
        _friday_stime = _tempSelectedStartTime[i];
        _friday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Saturday'){
        _saturday_stime = _tempSelectedStartTime[i];
        _saturday_etime = _tempSelectedEndTime[i];
      }else if(_tempSelectedDay[i] == 'Sunday'){
        _sunday_stime = _tempSelectedStartTime[i];
        _sunday_etime = _tempSelectedEndTime[i];
      }
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        child:SingleChildScrollView(
          child:         Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                child:Icon(
                                  Icons.close,
                                ),
                                onTap: (){
                                  Navigator.of(context).pop();
                                },)
                            ],
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child:  Text(
                        'Select Working Hours',
                        style: TextStyle(
                          fontSize: 18,
                          color: kMerchantBackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),),


                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 5,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Day',
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow:TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Start Time',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow:TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 3,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'End Time',
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow:TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),

                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          Flexible(
                              flex: 5,
                              child: Column(
                                children: [
                                  WeekDay('Monday'),
                                  SizedBox(height: 10),
                                  WeekDay('Tuesday'),
                                  SizedBox(height: 10),
                                  WeekDay('Wednesday'),
                                  SizedBox(height: 10),
                                  WeekDay('Thursday'),
                                  SizedBox(height: 10),
                                  WeekDay('Friday'),
                                  SizedBox(height: 10),
                                  WeekDay('Saturday'),
                                  SizedBox(height: 10),
                                  WeekDay('Sunday'),
                                ],
                              )
                          ),
                          SizedBox(width: 10),
                          Flexible(
                              flex: 3,
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_monday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('monday', widget.type, _monday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_tuesday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('tuesday', widget.type, _tuesday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_wednesday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('wednesday',widget.type, _wednesday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_thursday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('thursday', widget.type, _thursday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_friday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('friday', widget.type, _friday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_saturday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('saturday', widget.type, _saturday_stime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(_sunday_stime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showStartTimePicker('sunday', widget.type, _sunday_stime);
                                        },
                                      )
                                  ),
                                ],
                              )
                          ),
                          SizedBox(width: 10),
                          Flexible(
                              flex: 3,
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _monday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('monday', widget.type, _monday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _tuesday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('tuesday', widget.type, _tuesday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _wednesday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('wednesday', widget.type, _wednesday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _thursday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('thursday', widget.type, _thursday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _friday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('friday', widget.type, _friday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _saturday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('saturday', widget.type, _sunday_etime);
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.symmetric(vertical:10),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: InkWell(
                                        child: Container(
                                          child: Text(
                                            _sunday_etime,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow:TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onTap: (){
                                          _showEndTimePicker('sunday', widget.type, _sunday_etime);
                                        },
                                      )
                                  ),
                                ],
                              )
                          ),
                          Flexible(
                              child: Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Monday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(0, 'Monday');
                                                _tempSelectedStartTime.insert(0, '');
                                                _tempSelectedEndTime.insert(0, '');
                                              }
                                            }
                                            _monday_stime = '';
                                            _monday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Tuesday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(1, 'Tuesday');
                                                _tempSelectedStartTime.insert(1, '');
                                                _tempSelectedEndTime.insert(1, '');
                                              }
                                            }
                                            _tuesday_stime = '';
                                            _tuesday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Wednesday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(2, 'Wednesday');
                                                _tempSelectedStartTime.insert(2, '');
                                                _tempSelectedEndTime.insert(2, '');
                                              }
                                            }
                                            _wednesday_stime = '';
                                            _wednesday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Thursday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(3, 'Thursday');
                                                _tempSelectedStartTime.insert(3, '');
                                                _tempSelectedEndTime.insert(3, '');
                                              }
                                            }
                                            _thursday_stime = '';
                                            _thursday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Friday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(4, 'Friday');
                                                _tempSelectedStartTime.insert(4, '');
                                                _tempSelectedEndTime.insert(4, '');
                                              }
                                            }
                                            _friday_stime = '';
                                            _friday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Saturday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(5, 'Saturday');
                                                _tempSelectedStartTime.insert(5, '');
                                                _tempSelectedEndTime.insert(5, '');
                                              }
                                            }
                                            _saturday_stime = '';
                                            _saturday_etime = '';
                                          });
                                        },)
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Colors.transparent, width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child:  InkWell(
                                        child:Icon(
                                          Icons.remove_circle,
                                          color: kPrimaryColor,
                                        ),
                                        onTap: (){
                                          setState(() {
                                            for(int i=0; i<_tempSelectedDay.length; i++){
                                              if(_tempSelectedDay[i] == 'Sunday'){
                                                _tempSelectedDay.removeAt(i);
                                                _tempSelectedStartTime.removeAt(i);
                                                _tempSelectedEndTime.removeAt(i);

                                                _tempSelectedDay.insert(6, 'Sunday');
                                                _tempSelectedStartTime.insert(6, '');
                                                _tempSelectedEndTime.insert(6, '');
                                              }
                                            }
                                            _sunday_stime = '';
                                            _sunday_etime = '';
                                          });
                                        },)
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.all(20),
                      child: ButtonTheme(
                        height: 40,
                        minWidth: MediaQuery.of(context).size.width,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: RaisedButton(
                          color: kPrimaryColor,
                          onPressed: () {

                            Navigator.of(context).pop();
                            setState(() {
                              widget.onSelectedDayListChanged(_tempSelectedDay);
                              widget.onSelectedStartTimeListChanged(_tempSelectedStartTime);
                              widget.onSelectedEndTimeListChanged(_tempSelectedEndTime);
                            });

                          },
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
        )
,
      ),
    );

  }

  Widget WeekDay(String day_name) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:10),
      decoration: new BoxDecoration(
          border:Border.all(color: Color(0xFFACACAC), width: 0.5),
          borderRadius: BorderRadius.circular(5.0)),
      width: MediaQuery.of(context).size.width,
      child: Text(day_name,
          style: Theme.of(context).textTheme.bodyText2.apply(),
          maxLines: 1,
          overflow:TextOverflow.ellipsis,
          textAlign: TextAlign.center),
    );
  }

  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10)
      return '0$value';
    return value.toString();
  }

  _showStartTimePicker(String day, String type, String time) async {
    var picker;
    if(time != ''){
      picker = await showTimePicker(context: context, initialTime: TimeOfDay(hour:int.parse(time.split(":")[0]),minute: int.parse(time.split(":")[1])));
    } else{
      picker = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    }
    setState(() {
      if(day =='monday'){
        mon_sHour = picker.hour;
        mon_sMin = picker.minute;
        _monday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);
        if(type == 'edit'){
          if(_monday_etime != ''){
            var parts = _monday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(mon_sHour > etime){
              _monday_etime = '';
            }
          }
        }

      }else if(day =='tuesday'){
        tues_sHour = picker.hour;
        tues_sMin = picker.minute;
        _tuesday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_tuesday_etime != ''){
            var parts = _tuesday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(tues_sHour > etime){
              _tuesday_etime = '';
            }
          }

        }

      }else if(day =='wednesday'){
        wednes_sHour = picker.hour;
        wednes_sMin = picker.minute;
        _wednesday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_wednesday_etime != ''){
            var parts = _wednesday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(wednes_sHour > etime){
              _wednesday_etime = '';
            }
          }

        }

      }else if(day =='thursday'){
        thurs_sHour = picker.hour;
        thurs_sMin = picker.minute;
        _thursday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_thursday_etime != ''){
            var parts = _thursday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(thurs_sHour > etime){
              _thursday_etime = '';
            }
          }

        }

      }else if(day =='friday'){
        fri_sHour = picker.hour;
        fri_sMin = picker.minute;
        _friday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_friday_etime != ''){
            var parts = _friday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(fri_sHour > etime){
              _friday_etime = '';
            }
          }

        }

      }else if(day =='saturday'){
        satur_sHour = picker.hour;
        satur_sMin = picker.minute;
        _saturday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_saturday_etime != ''){
            var parts = _saturday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(satur_sHour > etime){
              _saturday_etime = '';
            }
          }
        }
      }else if(day =='sunday'){
        sun_sHour = picker.hour;
        sun_sMin = picker.minute;
        _sunday_stime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

        if(type == 'edit'){
          if(_sunday_etime != ''){
            var parts = _sunday_etime.split(':');
            int etime = int.parse(parts[0]);
            if(sun_sHour > etime){
              _sunday_etime = '';
            }
          }
        }
      }
    });
  }
  _showEndTimePicker(String day, String type, String time) async {
    var picker;
    if(time != ''){
      picker = await showTimePicker(context: context, initialEntryMode: TimePickerEntryMode.input, initialTime: TimeOfDay(hour:int.parse(time.split(":")[0]),minute: int.parse(time.split(":")[1])));
    } else{
      picker = await showTimePicker(context: context, initialEntryMode: TimePickerEntryMode.input,initialTime: TimeOfDay.now());
    }
    setState(() {

      if(day =='monday'){
        mon_eHour = picker.hour;
        mon_eMin = picker.minute;
        if(type == 'edit'){
          var parts = _monday_stime.split(':');
          mon_sHour = int.parse(parts[0]);
        }
        if(mon_eHour > mon_sHour) {
          _monday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);
          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Monday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }
            }

            _tempSelectedDay.insert(0, 'Monday');
            _tempSelectedStartTime.insert(0, _monday_stime);
            _tempSelectedEndTime.insert(0, _monday_etime);

          } else{

            _tempSelectedDay.insert(0, 'Monday');
            _tempSelectedStartTime.insert(0, _monday_stime);
            _tempSelectedEndTime.insert(0, _monday_etime);
          }


        } else{
          _monday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='tuesday'){
        tues_eHour = picker.hour;
        tues_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _tuesday_stime.split(':');
          tues_sHour = int.parse(parts[0]);
        }

        if(tues_eHour > tues_sHour) {
          _tuesday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Tuesday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }

            }

            _tempSelectedDay.insert(1, 'Tuesday');
            _tempSelectedStartTime.insert(1, _tuesday_stime);
            _tempSelectedEndTime.insert(1, _tuesday_etime);

          } else{

          }

        }else{
          _tuesday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='wednesday'){
        wednes_eHour = picker.hour;
        wednes_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _wednesday_stime.split(':');
          wednes_sHour = int.parse(parts[0]);
        }

        if(wednes_eHour > wednes_sHour) {
          _wednesday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Wednesday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }
            }

            _tempSelectedDay.insert(2, 'Wednesday');
            _tempSelectedStartTime.insert(2, _wednesday_stime);
            _tempSelectedEndTime.insert(2, _wednesday_etime);
          }else{

          }



        }else{
          _wednesday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='thursday'){
        thurs_eHour = picker.hour;
        thurs_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _thursday_stime.split(':');
          thurs_sHour = int.parse(parts[0]);
        }

        if(thurs_eHour > thurs_sHour) {
          _thursday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Thursday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }
            }

            _tempSelectedDay.insert(3, 'Thursday');
            _tempSelectedStartTime.insert(3, _thursday_stime);
            _tempSelectedEndTime.insert(3, _thursday_etime);

          }else{

          }


        }else{
          _thursday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='friday'){
        fri_eHour = picker.hour;
        fri_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _friday_stime.split(':');
          fri_sHour = int.parse(parts[0]);
        }

        if(fri_eHour > fri_sHour) {
          _friday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Friday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);

              }
            }

            _tempSelectedDay.insert(4, 'Friday');
            _tempSelectedStartTime.insert(4, _friday_stime);
            _tempSelectedEndTime.insert(4, _friday_etime);

          }else{

          }


        }else{
          _friday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='saturday'){
        satur_eHour = picker.hour;
        satur_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _saturday_stime.split(':');
          satur_sHour = int.parse(parts[0]);
        }

        if(satur_eHour > satur_sHour ) {
          _saturday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Saturday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }
            }

            _tempSelectedDay.insert(5, 'Saturday');
            _tempSelectedStartTime.insert(5, _saturday_stime);
            _tempSelectedEndTime.insert(5, _saturday_etime);

          }else{
          }
        }else{
          _saturday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }else if(day =='sunday'){
        sun_eHour = picker.hour;
        sun_eMin = picker.minute;

        if(type == 'edit'){
          var parts = _sunday_stime.split(':');
          sun_sHour = int.parse(parts[0]);
        }

        if(sun_eHour > sun_sHour ) {
          _sunday_etime = _addLeadingZeroIfNeeded(picker.hour) + ':'+ _addLeadingZeroIfNeeded(picker.minute);

          if(_tempSelectedDay.length > 0){
            for(int i=0; i<_tempSelectedDay.length; i++){
              if(_tempSelectedDay[i] == 'Sunday'){
                _tempSelectedDay.removeAt(i);
                _tempSelectedStartTime.removeAt(i);
                _tempSelectedEndTime.removeAt(i);
              }
            }

            _tempSelectedDay.insert(6, 'Sunday');
            _tempSelectedStartTime.insert(6, _sunday_stime);
            _tempSelectedEndTime.insert(6, _sunday_etime);

          }else{
          }
        }else{
          _sunday_etime = '';
          Toast.show("End time must be greater than start time!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        }
      }

    });
  }
}


