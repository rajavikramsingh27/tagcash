import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/booking/components/custom_drop_down.dart';
import 'package:tagcash/apps/booking/models/Currency.dart';
import 'package:tagcash/apps/booking/models/service.dart';
import 'package:tagcash/apps/booking/models/staff.dart';
import 'package:tagcash/apps/booking/models/staff_list.dart';
import 'package:tagcash/apps/booking/models/working_hour.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:toast/toast.dart';

import '../../../constants.dart';
import 'color_screen.dart';

class ServiceTabScreen extends StatefulWidget {
  @override
  _ServiceTabScreenState createState() => _ServiceTabScreenState();
}

class _ServiceTabScreenState extends State<ServiceTabScreen> with SingleTickerProviderStateMixin  {
  FocusNode myFocusNode = new FocusNode();
  FocusNode myFocusNode1 = new FocusNode();

  List<Service> getData = new List<Service>();
  List<StaffList> getStaffData = new List<StaffList>();
  bool isLoading = false, hide_variable = false;


  String color = '#000000';

  List<String> selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  List<String> selectedStartTime = ['', '', '', '', '', ''];
  List<String> selectedEndTime = ['', '', '', '', '', '', ''];

  List<String> TotalUnAvailable = [];

  var unAvailableTime = '';

  String showSelectHours = '';
  var working_hours, staff_allocated;
  List<String> workinghourslist = [];

  List<StaffList> getSelectedData = new List<StaffList>();
  List<String> selectedstaff = [];
  List<String> selectedstaffid = [];
  List<String> sendidlist = [];

  List<String> selectedColor = [];



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserService();
    getStaff();
  }

  void getUserService() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/ServiceList');

    if (response['status'] == 'success') {
      List responseList = response['result'];

      getData = responseList.map<Service>((json) {
        return Service.fromJson(json);
      }).toList();

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


  void getStaff() async  {
    getData.clear();
    print('loadStaffC'
        'ommunities');

    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/listStaff');

    List responseList = response['result'];

    getStaffData = responseList.map<StaffList>((json) {
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

  void addService(String service_name, String service_desc, String currency, String service_price, bool variable, bool available,
      String service_time, String color, List<String> unavailablehourslist, List<String> stafflist) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = service_name;
    apiBodyObj['amount'] = service_price;
    apiBodyObj['colour'] = color;
    apiBodyObj['time'] = service_time;
    apiBodyObj['staff'] = stafflist.toString();
    apiBodyObj['description'] = service_desc;
    apiBodyObj['currency'] = currency;
    apiBodyObj['variable'] = variable.toString();
    apiBodyObj['available'] = available.toString();
    apiBodyObj['unavailable_hours'] = unavailablehourslist.toString();

//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/CreateService', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getUserService();


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

  void editService(String service_id, String service_name, String service_desc, String currency, String service_price, bool variable, bool available,
      String service_time, String color, List<String> unavailablehourslist, List<String> stafflist) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = service_id;
    apiBodyObj['name'] = service_name;
    apiBodyObj['amount'] = service_price;
    apiBodyObj['colour'] = color;
    apiBodyObj['time'] = service_time;
    apiBodyObj['staff'] = stafflist.toString();
    apiBodyObj['description'] = service_desc;
    apiBodyObj['currency'] = currency;
    apiBodyObj['variable'] = variable.toString();
    apiBodyObj['available'] = available.toString();
    apiBodyObj['unavailable_hours'] = unavailablehourslist.toString();

//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/EditService', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      selectedStartTime = ['', '', '', '', '', ''];
      selectedEndTime = ['', '', '', '', '', '', ''];

      getUserService();


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


  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }

  getColorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String

    setState(() {
      color = prefs.getString('config_colour');
      displayBottomSheet(context, 'add', '', '', '', '', '', '', '', '', '', [], []);
    });
  }



  void deleteService(String staff_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['service_id'] = staff_id;
//
    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/RemoveService', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getUserService();


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
                return
                  InkWell(
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
                          child: Row(
                            children: [
                              Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getData[index].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time, size: 14, color: Color(0xFF535353).withOpacity(0.8),),
                                              SizedBox(width:5),
                                              Text(
                                                getData[index].time + ' mins',
                                                  style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  )
                              ),

                              Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          getData[index].amount,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(height: 2),
                                      ],
                                    ),
                                  )
                              )
                            ],
                          )
                      ),
                      onTap: () async {
                        if(getData[index].unavailable_hour != null){
                          if(getData[index].staff != null){
                            displayBottomSheet(context, 'edit', getData[index].id, getData[index].name, getData[index].description,
                                getData[index].time, getData[index].amount, getData[index].colour, getData[index].currency,
                                getData[index].variable, getData[index].available, getData[index].unavailable_hour, getData[index].staff);
                          }else{
                            displayBottomSheet(context, 'edit', getData[index].id, getData[index].name, getData[index].description,
                                getData[index].time, getData[index].amount, getData[index].colour, getData[index].currency,
                                getData[index].variable, getData[index].available, getData[index].unavailable_hour, []);
                          }
                        }else{
                          if(getData[index].staff != null){
                            displayBottomSheet(context, 'edit', getData[index].id, getData[index].name, getData[index].description,
                                getData[index].time, getData[index].amount, getData[index].colour, getData[index].currency,
                                getData[index].variable, getData[index].available, [], getData[index].staff);
                          }else{
                            displayBottomSheet(context, 'edit', getData[index].id, getData[index].name, getData[index].description,
                                getData[index].time, getData[index].amount, getData[index].colour, getData[index].currency,
                                getData[index].variable, getData[index].available, [], []);
                          }
                        }
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
        displayBottomSheet(context, 'add', '', '', '', '', '', '', '', '', '', [], []);
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

  void displayBottomSheet(BuildContext context, String type, String service_id, String service_name, String service_desc, String service_time,
      String service_amount, String service_color, String service_currency, String service_variable, String service_available,
      List<WorkingHour> unavailable_hour, List<Staff> staffList) {

//    selectedDay.clear();
//    selectedStartTime.clear();
//    selectedEndTime.clear();

    selectedDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    selectedStartTime = ['', '', '', '', '', ''];
    selectedEndTime = ['', '', '', '', '', '', ''];

    selectedstaff.clear();
    selectedstaffid.clear();
    getSelectedData.clear();
    working_hours = '';
    staff_allocated = '';
    workinghourslist.clear();
    sendidlist.clear();

    bool hide_variable = false;
    bool available = false;

    String days, StartTime, EndTime;
    String showSelectHours = '';
    String staff = '';

    if(type == 'edit'){
      color = service_color;
    } else{
    }

    if(service_variable == 'true'){
      hide_variable = true;
    }else{
      hide_variable = false;
    }
    if(service_available == 'true'){
      available = true;
    }else{
      available = false;
    }

    for(int i=0; i<unavailable_hour.length; i++){
      if(unavailable_hour[i].day == 'Monday'){
        selectedStartTime.insert(0, unavailable_hour[i].start_time);
        selectedEndTime.insert(0, unavailable_hour[i].end_time);

        days = selectedDay[0];
        StartTime = selectedStartTime[0];
        EndTime = selectedEndTime[0];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(unavailable_hour[i].day == 'Tuesday'){
        selectedStartTime.insert(1, unavailable_hour[i].start_time);
        selectedEndTime.insert(1, unavailable_hour[i].end_time);

        days = selectedDay[1];
        StartTime = selectedStartTime[1];
        EndTime = selectedEndTime[1];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(unavailable_hour[i].day == 'Wednesday'){
        selectedStartTime.insert(2, unavailable_hour[i].start_time);
        selectedEndTime.insert(2, unavailable_hour[i].end_time);

        days = selectedDay[2];
        StartTime = selectedStartTime[2];
        EndTime = selectedEndTime[2];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(unavailable_hour[i].day == 'Thursday'){
        selectedStartTime.insert(3, unavailable_hour[i].start_time);
        selectedEndTime.insert(3, unavailable_hour[i].end_time);

        days = selectedDay[3];
        StartTime = selectedStartTime[3];
        EndTime = selectedEndTime[3];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(unavailable_hour[i].day == 'Friday'){
        selectedStartTime.insert(4, unavailable_hour[i].start_time);
        selectedEndTime.insert(4, unavailable_hour[i].end_time);

        days = selectedDay[4];
        StartTime = selectedStartTime[4];
        EndTime = selectedEndTime[4];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';

      } else if(unavailable_hour[i].day == 'Saturday'){
        selectedStartTime.insert(5, unavailable_hour[i].start_time);
        selectedEndTime.insert(5, unavailable_hour[i].end_time);

        days = selectedDay[5];
        StartTime = selectedStartTime[5];
        EndTime = selectedEndTime[5];
        working_hours = '{"day" : "$days", "start_time" : "$StartTime", "end_time" : "$EndTime"}';
        workinghourslist.add(working_hours);
        showSelectHours = '$showSelectHours$days - $StartTime to $EndTime, ';
      }

    }

    for(int i=0; i<staffList.length; i++){
      selectedstaff.add(staffList[i].staff_name);
      selectedstaffid.add(staffList[i].id);

      var stringList = selectedstaff.reduce((value, element) => value + ',' + element);
      staff = stringList;

      var staff_name = staffList[i].staff_name;
      var staff_id = staffList[i].id;

      staff_allocated = '{"staff_name" : "$staff_name", "staff_id" : "$staff_id"}';
      sendidlist.add(staff_allocated);

      StaffList stafflist = new StaffList('', 0, '', '', '', '');
      stafflist.id = staffList[i].id;
      stafflist.staff_name =staffList[i].staff_name;
      getSelectedData.add(stafflist);

    }


    List<Currency> _currency = Currency.getCurrency();
    List<CustomDropdownMenuItem<Currency>> _dropdownMenuItems;
    Currency _selectedCompany;

    List<CustomDropdownMenuItem<Currency>> buildDropdownMenuItems(List companies) {
      List<CustomDropdownMenuItem<Currency>> items = List();
      for (Currency company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(company.name,
              style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black)),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems = buildDropdownMenuItems(_currency);

    if(service_currency == 'PHP'){
      _selectedCompany = _dropdownMenuItems[0].value;
    }else if(service_currency == 'KSR'){
      _selectedCompany = _dropdownMenuItems[1].value;
    }else if(service_currency == 'EUR'){
      _selectedCompany = _dropdownMenuItems[2].value;
    } else{
      _selectedCompany = _dropdownMenuItems[0].value;
    }

    TextEditingController _service_nameController = TextEditingController();
    TextEditingController _service_descriptionController = TextEditingController();
    TextEditingController _service_priceController = TextEditingController();
    TextEditingController _service_timeController = TextEditingController();

    _service_nameController.text = service_name;
    _service_descriptionController.text = service_desc;
    _service_priceController.text = service_amount;
    _service_timeController.text = service_time;


    showModalBottomSheet(
      isScrollControlled: true,
      barrierColor: Colors.black87.withOpacity(0.3),
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BottomSheet(
          backgroundColor: Colors.transparent,
          onClosing: () {},
          builder: (BuildContext context) {
            return StatefulBuilder(
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
                        child: Column(
                          children: [
                            TextField(
                              focusNode: myFocusNode,
                              controller: _service_nameController,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: 'Service Name',
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
                            SizedBox(height: 5),
                            TextField(
                              focusNode: myFocusNode1,
                              controller: _service_descriptionController,
                              decoration: InputDecoration(
                                  labelText: 'Service Description(if any)',
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
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width,
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
                                          Text(
                                            'Currency',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Price',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [

                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child:
                                    Container(
                                      decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Color(0xFFACACAC), width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0)),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, right: 10),
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            CustomDropdownButton(
                                              isExpanded: true,
                                              value: _selectedCompany,
                                              items: _dropdownMenuItems,
                                              underline:Container(),
                                              onChanged: (val) {
                                                setState(() {
                                                  FocusScope.of(context).unfocus();
                                                  _selectedCompany = val;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: 10),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                ),
                                              ),
                                              controller: _service_priceController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.digitsOnly
                                              ],
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 20, width: 20,
                                              child:  Theme(
                                                data: Theme.of(context).copyWith(
                                                  unselectedWidgetColor: Colors.grey,
                                                ),
                                                child: Checkbox(activeColor: kPrimaryColor,
                                                  value: hide_variable,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      FocusScope.of(context).unfocus();
                                                      hide_variable = val;
                                                    });
                                                  },),
                                              )
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              FocusScope.of(context).unfocus();
                                              if(hide_variable == true){
                                                setState(() {
                                                  FocusScope.of(context).unfocus();
                                                  hide_variable = false;
                                                });
                                              }else{
                                                setState(() {
                                                  FocusScope.of(context).unfocus();
                                                  hide_variable = true;
                                                });
                                              }
                                            },
                                            child: Text(
                                              'Variable',
                                              style: new TextStyle(fontSize: 14.0, color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width,
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
                                          Text(
                                            'Time (in minutes)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Select Color',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.w500),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),

                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [

                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                      flex: 1,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(top: 10),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.grey),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: kPrimaryColor),
                                            ),
                                          ),
                                          controller: _service_timeController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ], // O
                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                      flex: 1,
                                      child:
                                      GestureDetector(
                                        child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(25),
                                                      color: parseColor(color)
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        onTap: (){
                                          selectedColor.clear();
                                          FocusScope.of(context).unfocus();
//                                              Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return ColorScreen(
                                                  color: color,
                                                  selectedColor: selectedColor,
                                                  onSelectedColorListChanged: (value) {
                                                    selectedColor = value;
                                                    var stringList = selectedColor.reduce((value, element) => value + ',' + element);
                                                    setState(() {
                                                      color = stringList;
                                                    });
                                                  },

                                                );
                                              }
                                          );
//                                              Navigator.of(context).push(
//                                                  new MaterialPageRoute(builder: (context) => ColorScreen(color: color,))
//                                              ).then((val)=>val?getColorData():null);


                                        },
                                      )
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 20, width: 20,
                                              child: Theme(
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
                                          SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              FocusScope.of(context).unfocus();
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
                                              'Available',
                                              style: new TextStyle(fontSize: 14.0,color: Colors.black),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 15),

                            InkWell(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unavailable Hours',
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
//                                showSelectHours = '';
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
                                            if(selectedEndTime[0] == '' && selectedEndTime[1] == ''&& selectedEndTime[2] == ''&& selectedEndTime[3] == ''&& selectedEndTime[4] == ''&& selectedEndTime[5] == ''){
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
                                               }
                                            }
                                          }else{
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
                            SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            showSelectHours,
                                            style: Theme.of(context).textTheme.bodyText1.apply(color: Color(0xFFACACAC)),
                                            maxLines: 10),
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Staff Allocated',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
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
                                                staff,
                                                style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
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
                                        FocusScope.of(context).unfocus();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return _StaffDialog(
                                                  staffData: getStaffData,
                                                  staffSelectedData: getSelectedData,
                                                  selectedStaff: selectedstaff,
                                                  selectedStaffId: selectedstaffid,
                                                  onSelectedCitiesListChanged: (cities) {
                                                  },
                                                  onSelectedTaxIdListChanged: (cities) {
                                                  },
                                                  onSelectedTaxListChanged: (cities) {
                                                    getSelectedData = cities;
                                                    setState(() {
                                                      if (getSelectedData.length != 0){
                                                        selectedstaff.clear();
                                                        selectedstaffid.clear();
                                                        staff_allocated = '';
                                                        sendidlist.clear();

                                                        for (int i = 0; i < getSelectedData.length; i++) {
                                                          selectedstaff.add(getSelectedData[i].staff_name);
                                                          selectedstaffid.add(getSelectedData[i].id);

                                                          var stringList = selectedstaff.reduce((value, element) => value + ', ' + element);
                                                          staff = stringList;

                                                          var staff_name = getSelectedData[i].staff_name;
                                                          var staff_id = getSelectedData[i].id;

                                                          staff_allocated = '{"staff_name" : "$staff_name", "staff_id" : "$staff_id"}';
                                                          sendidlist.add(staff_allocated);
                                                        }

                                                        print(sendidlist);

                                                      } else{
                                                        sendidlist.clear();
                                                        staff = '';
                                                      }

                                                    });
                                                  }
                                              );
                                            });
                                      },
                                    )
                                  ],
                                )),

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
                                                    deleteService(service_id);

                                                  },
                                                );

                                                AlertDialog alert = AlertDialog(
                                                  title: Text(""),
                                                  content: Text('Are you sure you want to delete this service?'),
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
                                    SizedBox(width: 10):Container(),
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
                                                if(_service_nameController.text == ''){
                                                  showSimpleDialog(context,
                                                      title: getTranslated(context, 'error'),
                                                      message: 'Service name required');
                                                }else if(_service_descriptionController.text == ''){
                                                  showSimpleDialog(context,
                                                      title: getTranslated(context, 'error'),
                                                      message: 'Service description required');
                                                }else if(_service_priceController.text == ''){
                                                  showSimpleDialog(context,
                                                      title: getTranslated(context, 'error'),
                                                      message: 'Service price required');
                                                }else if(_service_timeController.text == ''){
                                                  showSimpleDialog(context,
                                                      title: getTranslated(context, 'error'),
                                                      message: 'Service time required');
                                                } else{
                                                  Navigator.of(context).pop();
                                                  if(type == 'add'){
                                                    addService(_service_nameController.text, _service_descriptionController.text, _selectedCompany.name,
                                                        _service_priceController.text, hide_variable, available, _service_timeController.text,
                                                        color, workinghourslist, sendidlist);
                                                  }else{
                                                    editService(service_id, _service_nameController.text, _service_descriptionController.text, _selectedCompany.name,
                                                        _service_priceController.text, hide_variable, available, _service_timeController.text,
                                                        color, workinghourslist, sendidlist);
                                                  }
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
                        )));
          },
        );
      },
    );
  }
}

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

  int mon_sHour, tues_sHour, wednes_sHour, thurs_sHour, fri_sHour, satur_sHour;
  int mon_sMin, tues_sMin, wednes_sMin, thurs_sMin, fri_sMin, satur_sMin;
  int  mon_eHour, tues_eHour, wednes_eHour, thurs_eHour, fri_eHour, satur_eHour;
  int mon_eMin, tues_eMin, wednes_eMin, thurs_eMin, fri_eMin, satur_eMin;
  var _monday_stime = '', _tuesday_stime = '', _wednesday_stime = '', _thursday_stime = '',_friday_stime = '', _saturday_stime = '';
  var _monday_etime = '', _tuesday_etime = '', _wednesday_etime = '', _thursday_etime = '', _friday_etime = '', _saturday_etime = '';
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
          child: Column(
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
                                  /*     widget.onSelectedDayListChanged(_tempSelectedDay);
                                widget.onSelectedStartTimeListChanged(_tempSelectedStartTime);
                                widget.onSelectedEndTimeListChanged(_tempSelectedEndTime);*/
                                },)
                            ],
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child:  Text(
                        'Select Unavailable Hours',
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
                              flex: 4,
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
                                ],
                              )
                          ),
                          SizedBox(width: 10),
                          Flexible(
                              flex: 2,
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
                                ],
                              )
                          ),
                          SizedBox(width: 10),
                          Flexible(
                              flex: 2,
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
                                          _showEndTimePicker('saturday', widget.type, _saturday_etime);
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
//                          _tempSelectedStartTime.add(_stime);
//                          _tempSelectedEndTime.add(_etime);

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
          textAlign: TextAlign.center,),
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

      }
    });
  }
  _showEndTimePicker(String day, String type, String time) async {
    var picker;
    if(time != ''){
      picker = await showTimePicker(context: context, initialTime: TimeOfDay(hour:int.parse(time.split(":")[0]),minute: int.parse(time.split(":")[1])));
    } else{
      picker = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
      }

    });
  }
}



class _StaffDialog extends StatefulWidget {
  _StaffDialog({
    this.staffData,
    this.staffSelectedData,
    this.selectedStaff,
    this.selectedStaffId,
    this.onSelectedCitiesListChanged,
    this.onSelectedTaxIdListChanged,
    this.onSelectedTaxListChanged,
  });

  List<StaffList> staffData = new List<StaffList>();
  List<StaffList> staffSelectedData = new List<StaffList>();
  final List<String> selectedStaff;
  final List<String> selectedStaffId;
  final ValueChanged<List<String>> onSelectedCitiesListChanged;
  final ValueChanged<List<String>> onSelectedTaxIdListChanged;
  final ValueChanged<List<StaffList>> onSelectedTaxListChanged;


  @override
  _TaxDialogState createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_StaffDialog> {
  List<String> _tempSelectedStaff = [];
  List<String> _tempSelectedId = [];
  List<StaffList> _taxSelectedData = new List<StaffList>();

  @override
  void initState() {
    _tempSelectedStaff = widget.selectedStaff;
    _tempSelectedId = widget.selectedStaffId;
    _taxSelectedData = widget.staffSelectedData;
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
                      'Select staff',
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
                    return Container(
                      child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: kPrimaryColor,
                          checkColor: Colors.white,
                          title: Text(cityName.staff_name),
                          value: _tempSelectedId.contains(cityName.id),
                          onChanged: (bool value) {
                            if (value) {
                              if (!_tempSelectedId.contains(cityName.id)) {
                                setState(() {
                                  StaffList staff = new StaffList('', 0, '', '', '', '');
                                  staff.id = cityName.id;
                                  staff.staff_name = cityName.staff_name;
                                  _taxSelectedData.add(staff);

                                  _tempSelectedStaff.add(cityName.staff_name);
                                  _tempSelectedId.add(cityName.id);
                                });
                              }
                            } else {
                              if (_tempSelectedId.contains(cityName.id)) {
                                setState(() {
                                  StaffList staff = new StaffList('', 0, '', '', '', '');
                                  staff.id = cityName.id;
                                  staff.staff_name = cityName.staff_name;
                                  _taxSelectedData.removeWhere((item) => item.id == cityName.id);

                                  _tempSelectedStaff.removeWhere(
                                          (String city) => city == cityName.staff_name);
                                  _tempSelectedId.removeWhere(
                                          (String city) => city == cityName.id);
                                });
                              }
                            }

                          }),
                    );
                  }),
            ),),

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kPrimaryColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedCitiesListChanged(_tempSelectedStaff);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget.onSelectedTaxListChanged(_taxSelectedData);
                          });
                        },
                        child: Text('SAVE',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),)

                ],
              ),
            )
          ],
        ),
      ),
    );

  }
}



class ColorScreen extends StatefulWidget {
  String color;

  ColorScreen({
    this.color,
    this.selectedColor,
    this.onSelectedColorListChanged,
  });

  final List<String> selectedColor;
  final ValueChanged<List<String>> onSelectedColorListChanged;


  @override
  _ColorScreenState createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String> _tempSelectedColor = [];


  String color, color_name = '', colorName = '';
  Color pickerColor = Color(0xff443a49);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _tempSelectedColor = widget.selectedColor;
      color_name = widget.color;
      color = widget.color;
    });
  }

  addStringToSF() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_colour', color_name);

  }

  Color currentColor = Color(0xff2ecd71);


  void changeColor(Color color) =>
      setState(() =>
      currentColor = color
      );

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Accent Color'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
            ),
            onPressed: () {
              _tempSelectedColor.add(color_name);
              widget.onSelectedColorListChanged(_tempSelectedColor);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(4),
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        crossAxisCount: 3,
        children: [
          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Custom',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: parseColor(color),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#2ecd71';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#2ecd71' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              ),

              GestureDetector(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FaIcon(FontAwesomeIcons.pen, size: 16, color: Colors.white,)
                        ],
                      )
                  ),
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          titlePadding: const EdgeInsets.all(0.0),
                          contentPadding: const EdgeInsets.all(0.0),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: parseColor(color),
                              onColorChanged: changeColor,
                              colorPickerWidth: 300.0,
                              pickerAreaHeightPercent: 0.7,
                              enableAlpha: false,
                              displayThumbColor: true,
                              showLabel: true,
                              paletteType: PaletteType.hsv,

                            ),
                          ),
                          actions: <Widget>[
                            ButtonTheme(
                              height: 40,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              child: RaisedButton(
                                color: kUserBackColor,
                                onPressed: () {
                                  String colorString = currentColor.toString(); // Color(0x12345678)
                                  String valueString = colorString.split('(0xff')[1].split(')')[0]; // kind of hacky..
                                  valueString = '#'+valueString;
                                  color_name = valueString;
                                  print(valueString);

                                  setState(() {
                                    color = color_name;
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        );
                      },
                    );
                  }
              ),


            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Red',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#E51C23'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#E51C23';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#E51C23' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              ),
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Pink',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#FF4081'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#FF4081';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#FF4081' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Purple',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#9C27B0'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#9C27B0';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#9C27B0' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Deep purple',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#673AB7'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#673AB7';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#673AB7' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Indigo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#00416A'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#00416A';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#00416A' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Blue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#03A9F4'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#03A9F4';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#03A9F4' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Light blue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#40C4FF'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#40C4FF';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#40C4FF' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Cyan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#00BCD4'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#00BCD4';

                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#00BCD4' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Teal',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#009688'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#009688';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#009688' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Green',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#259B24'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#259B24';

                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#259B24' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Light green',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#8BC34A'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#8BC34A';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#8BC34A' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Lime',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#CDDC39'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#CDDC39';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#CDDC39' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Yellow',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#FFEB3B'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#FFEB3B';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#FFEB3B' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Amber',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#FFC107'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#FFC107';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#FFC107' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Orange',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#FF9800'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#FF9800';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#FF9800' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Deep Orange',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#FF5722'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#FF5722';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#FF5722' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Brown',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#b79186'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#b79186';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#b79186' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Grey',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#d4d5db'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#d4d5db';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#d4d5db' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Blue Grey',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#a2a8d6'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#a2a8d6';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#a2a8d6' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

          Stack(
            children: [
              GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Black',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.end,),
                    ],
                  ),
                  color: HexColor('#000000'),
                ),
                onTap: (){
                  setState(() {
                    color_name = '#000000';
                  });
                },
              ),

              Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#000000' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
              )
            ],
          ),

        ],
      ),
    );
  }
}








