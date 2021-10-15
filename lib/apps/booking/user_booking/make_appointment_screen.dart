import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/models/staff.dart';
import 'package:tagcash/apps/booking/user_booking/user_booking_tab_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:intl/intl.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;


class MakeAppointmentScreen extends StatefulWidget {
  String owner_id, owner_service_id,  service_name, name, service, staff;
  List<Staff> getData = new List<Staff>();

  MakeAppointmentScreen(
      {Key key, this.owner_id, this.owner_service_id, this.service_name, this.name, this.service, this.staff, this.getData}) : super(key: key);

  @override
  _MakeAppointmentScreenState createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> with SingleTickerProviderStateMixin  {

  String servicestaff_name = 'Any', servicestaff_id = '';
  List<Staff> getSelectedData = new List<Staff>();
  List<String> selectedservicestaff = [];
  List<String> selectedservicestaffid = [];
  var service_allocated;

  String selected_starttime = '09:00';
  String selected_endtime = '10:30';
  String selected_date = '';
  bool isLoading = false;

  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 372));
    _lastDate = DateTime.now().add(Duration(days: 3720));

    Staff stafflist = new Staff();
    stafflist.id = '';
    stafflist.staff_name = 'Any';
    widget.getData.add(stafflist);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        selected_date = formatter.format(newDate);
    });
  }


  void addAppointment(String start_time, String end_time) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['merchant'] = widget.owner_id;
    apiBodyObj['service'] = widget.owner_service_id;
    apiBodyObj['date'] = selected_date;
    apiBodyObj['staff'] = servicestaff_id;
    apiBodyObj['service_start_time'] = start_time;
    apiBodyObj['service_end_time'] = end_time;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/AddAppointment', apiBodyObj);
//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => UserBookingTabScreen()),
          ModalRoute.withName('/')
      );

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
                                     widget.service + ' Services, '+ widget.staff + ' Staff',
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
                                 style: Theme.of(context).textTheme.subtitle1.apply(),
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
                                                 staffData: widget.getData,
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
                                                     servicestaff_id = staffidList;
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
                                           if(selected_date != ''){
                                             addAppointment(selected_date + ' '+ selected_starttime, selected_date + ' '+ selected_endtime);
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
                       ],
                     ),
                   )
                  ],
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),

          ],
        ));
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




