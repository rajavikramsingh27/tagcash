import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/models/service.dart';
import 'package:tagcash/apps/booking/models/staff.dart';
import 'package:tagcash/apps/booking/models/user_service.dart';
import 'package:tagcash/apps/booking/user_booking/user_booking_tab_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';
import 'package:intl/intl.dart';


import '../../../constants.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;


class EditAppointmentScreen extends StatefulWidget {
  String appointment_id, owner_id, name, service_id, service_name, date,
      service_start_time, service_end_time, staff_id, total_service = '', total_staff = '';

  EditAppointmentScreen(
      {Key key, this.appointment_id, this.owner_id, this.name, this.service_id, this.service_name, this.date,
      this.service_start_time, this.service_end_time, this.staff_id}) : super(key: key);

  @override
  _EditAppointmentScreenState createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> with SingleTickerProviderStateMixin  {

  List<Service> getData = new List<Service>();
  List<UserService> getUserServiceData = new List<UserService>();

  List<Staff> getStaffData = new List<Staff>();
  List<Staff> getSelectedData = new List<Staff>();
  List<String> selectedservicestaff = [];
  List<String> selectedservicestaffid = [];
  var service_allocated;


  String selected_starttime = '09:00';
  String selected_endtime = '10:30';

  bool isLoading = false;
  List<DateTime> days = [];

  String servicestaff_name = 'Any';

  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 372));
    _lastDate = DateTime.now().add(Duration(days: 3720));

    getUserService();
    getMerchantService();

  }

  void getUserService() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['merchant_name'] = '';

    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/ServiceListUser', apiBodyObj);


    if (response['status'] == 'success') {
      List responseList = response['result'];

      getUserServiceData = responseList.map<UserService>((json) {
        return UserService.fromJson(json);
      }).toList();

      for(int i=0; i<getUserServiceData.length; i++){
        if(widget.owner_id == getUserServiceData[i].owner_id){
          widget.total_service =  getUserServiceData[i].owner_total_service.toString();
          widget.total_staff =  getUserServiceData[i].owner_total_staff.toString();
        }
      }

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
  void getMerchantService() async  {
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['owner_id'] = widget.owner_id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/GetMerchantService', apiBodyObj);


    var jsonn = response['result'];

    List responseList = jsonn['result'];

    getData = responseList.map<Service>((json) {
      return Service.fromJson(json);
    }).toList();

    for(int i=0; i<getData.length; i++){
      if(widget.service_id == getData[i].id){
        getStaffData =  getData[i].staff;
      }
    }

    for(int j=0; j<getStaffData.length; j++){
      if(widget.staff_id == getStaffData[j].id){
        servicestaff_name =  getStaffData[j].staff_name;
      }
    }

    Staff stafflist = new Staff();
    stafflist.id = '';
    stafflist.staff_name = 'Any';
    getStaffData.add(stafflist);

    _selectedDate =  DateTime.parse(widget.date);
    DateTime dateTimeCreatedAt = DateTime.parse(widget.date);
    DateTime dateTimeNow = DateTime.now();
    final differenceInDays = dateTimeCreatedAt.difference(dateTimeNow).inDays;
    print(differenceInDays + 1);

    int diff = differenceInDays+1;
    if(diff > 0){
      days.add(dateTimeNow.add(Duration(days: differenceInDays + 1)));
    }

    var parts = widget.service_start_time.split(' ');
    selected_starttime = parts[1].toString();

    var parts1 = widget.service_end_time.split(' ');
    selected_endtime = parts1[1].toString();

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


  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      widget.date = formatter.format(newDate);
    });
  }

  void editAppointment(String start_time, String end_time) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.appointment_id;
    apiBodyObj['merchant'] = widget.owner_id;
    apiBodyObj['service'] = widget.service_id;
    apiBodyObj['date'] = widget.date;
    apiBodyObj['staff'] = widget.staff_id;
    apiBodyObj['service_start_time'] = start_time;
    apiBodyObj['service_end_time'] = end_time;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/EditAppointment', apiBodyObj);
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      Navigator.pop(context, true);

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

  void removeBooking(String appointment_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['appointment_id'] = appointment_id;

//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/RemoveAppointment', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);

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
    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText1
            .copyWith(color: Colors.white),
        selectedSingleDateDecoration: BoxDecoration(
            color: kPrimaryColor, shape: BoxShape.circle));
    // TODO: implement build
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: '',
        ),
        body: Stack(
          children: [
            SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
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
                                        widget.owner_id +
                                        "?kycImage=0",
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),

                              Flexible(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: Theme.of(context).textTheme.bodyText1.apply(),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 5),

                                  Text(
                                    widget.total_service + ' Services, '+widget.total_staff + ' Staff',
                                    style: Theme.of(context).textTheme.bodyText1.apply(color: Color(0xFFACACAC)),
                                  ),
                                ],
                              ),)

                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Color(0xFFACACAC),
                                ),
                                borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Container(
                              child: Text(
                                widget.service_name,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 320,
                          width: MediaQuery.of(context).size.width,
                          child: dp.DayPicker.single(
                            selectedDate: _selectedDate,
                            onChanged: _onSelectedDateChanged,
                            firstDate: _firstDate,
                            lastDate: _lastDate,
                            datePickerStyles: styles,
                            datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                                scrollPhysics: NeverScrollableScrollPhysics(),
                                maxDayPickerRowCount: 2,
                                showPrevMonthEnd: true,
                                showNextMonthStart: true
                            ),
                          ),
                        ),
                        Container(
                            decoration: new BoxDecoration(
                                border:
                                Border.all(color: Color(0xFFACACAC), width: 0.5),
                                borderRadius: BorderRadius.circular(5.0)),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            servicestaff_name,
                                            style: Theme.of(context).textTheme.bodyText2.apply(),
                                            textAlign: TextAlign.center,
                                          ),
                                          FaIcon(
                                            FontAwesomeIcons.angleDown,
                                            size: 16,
                                            color: Color(0xFFACACAC),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return
                                            _ServicecStaffDialog(
                                                staffData: getStaffData,
                                                serSelectedData: getSelectedData,
                                                selectedStaff: selectedservicestaff,
                                                selectedStaffId: selectedservicestaffid,
                                                onSelectedCitiesListChanged: (cities) {
                                                  selectedservicestaff = cities;
                                                  var stringList = selectedservicestaff.reduce((value, element) => value + ',' + element);
                                                  servicestaff_name = stringList;
                                                },
                                                onSelectedTaxIdListChanged: (cities) {
                                                  selectedservicestaffid = cities;
                                                  setState(() {
                                                    var stringList = selectedservicestaff.reduce((value, element) => value + ',' + element);
                                                    servicestaff_name = stringList;

                                                    var staffidList = selectedservicestaffid.reduce((value, element) => value + ',' + element);
                                                    widget.staff_id = staffidList;
                                                  });
                                                },
                                                onSelectedTaxListChanged: (cities) {
                                                  getSelectedData = cities;
                                                }
                                            );
                                        });

                                  },
                                )
                              ],
                            )),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Flexible(
                                  flex:1,
                                  child: InkWell(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: new BoxDecoration(
                                          color: selected_starttime == '09:00'?
                                          kPrimaryColor:Colors.white,
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(15.0)),
                                      child: Text(
                                        '9:00 - 10:30',
                                        style: TextStyle(
                                            color: selected_starttime == '09:00'?
                                            Colors.white: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: (){
                                      setState(() {
                                        selected_starttime = '09:00';
                                        selected_endtime = '10:30';
                                      });
                                    },
                                  )
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: new BoxDecoration(
                                          color: selected_starttime == '10:30'?
                                          kPrimaryColor:Colors.white,
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(15.0)),
                                      child: Text(
                                        '10:30 - 12:00',
                                        style: TextStyle(
                                            color: selected_starttime == '10:30'?
                                            Colors.white: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: (){
                                      setState(() {
                                        selected_starttime = '10:30';
                                        selected_endtime = '12:00';
                                      });
                                    },
                                  )
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: new BoxDecoration(
                                          color: selected_starttime == '12:00'?
                                          kPrimaryColor:Colors.white,
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(15.0)),
                                      child: Text(
                                        '12:00 - 13:30',
                                        style: TextStyle(
                                            color: selected_starttime == '12:00'?
                                            Colors.white: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: (){
                                      setState(() {
                                        selected_starttime = '12:00';
                                        selected_endtime = '13:30';
                                      });
                                    },
                                  )
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Flexible(
                                  flex:1,
                                  child: InkWell(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(10),
                                      decoration: new BoxDecoration(
                                          color: selected_starttime == '15:00'?
                                          kPrimaryColor:Colors.white,
                                          border: Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(15.0)),
                                      child: Text(
                                        '15:00 - 16:30',
                                        style: TextStyle(
                                            color: selected_starttime == '15:00'?
                                            Colors.white: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: (){
                                      setState(() {
                                        selected_starttime = '15:00';
                                        selected_endtime = '16:30';
                                      });
                                    },
                                  )
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              Flexible(
                                  flex: 1,
                                  child: Container(
                                    child: ButtonTheme(
                                      height: 40,
                                      minWidth: MediaQuery.of(context).size.width,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      child: RaisedButton(
                                        color: Color(0xFF2b2b2b),
                                        onPressed: () {
                                          removeBooking(widget.appointment_id);
                                        },
                                        child: Text(
                                          'DELETE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(width: 10),
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
                                          if(widget.date != ''){
                                            editAppointment(widget.date + ' '+ selected_starttime, widget.date + ' '+ selected_endtime);

                                          }else{
                                            showSimpleDialog(context,
                                                title: getTranslated(context, 'error'),
                                                message:
                                                'Please select date');
                                          }
                                        },
                                        child: Text(
                                          'MAKE APPOINTMENT / SAVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
}



class _ServicecStaffDialog extends StatefulWidget {
  _ServicecStaffDialog({
    this.staffData,
    this.serSelectedData,
    this.selectedStaff,
    this.selectedStaffId,
    this.onSelectedCitiesListChanged,
    this.onSelectedTaxIdListChanged,
    this.onSelectedTaxListChanged,
  });

  List<Staff> staffData = new List<Staff>();
  List<Staff> serSelectedData = new List<Staff>();
  final List<String> selectedStaff;
  final List<String> selectedStaffId;
  final ValueChanged<List<String>> onSelectedCitiesListChanged;
  final ValueChanged<List<String>> onSelectedTaxIdListChanged;
  final ValueChanged<List<Staff>> onSelectedTaxListChanged;



  @override
  _ServiceStaffDialogState createState() => _ServiceStaffDialogState();
}

class _ServiceStaffDialogState extends State<_ServicecStaffDialog> {
  List<String> _tempSelectedService = [];
  List<String> _tempSelectedId = [];
  List<Staff> _staffSelectedData = new List<Staff>();

  @override
  void initState() {
    _tempSelectedService = widget.selectedStaff;
    _tempSelectedId = widget.selectedStaffId;
    _staffSelectedData = widget.serSelectedData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
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
                      'Select Staff',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),



                ],
              ),
            ),
            Expanded(child:  Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.staffData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final cityName = widget.staffData[index];
                    return InkWell(
                      child:  Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          cityName.staff_name,
                          style: Theme.of(context).textTheme.subtitle1.apply(),
                        ),),
                      onTap: (){
                        _staffSelectedData.clear();
                        _tempSelectedService.clear();
                        _tempSelectedId.clear();

                        Staff staff = new Staff();
                        staff.id = cityName.id;
                        staff.staff_name = cityName.staff_name;
                        _staffSelectedData.add(staff);

                        _tempSelectedService.add(cityName.staff_name);
                        _tempSelectedId.add(cityName.id);

                        Navigator.of(context).pop();
                        setState(() {
                          widget.onSelectedCitiesListChanged(_tempSelectedService);
                          widget.onSelectedTaxIdListChanged(_tempSelectedId);
                          widget.onSelectedTaxListChanged(_staffSelectedData);
                        });
                      },
                    );

                  }),
            ),),

          ],
        ),
      ),
    );

  }
}

