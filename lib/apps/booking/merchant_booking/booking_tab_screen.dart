import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/models/booking.dart';
import 'package:tagcash/apps/booking/models/country_code.dart';
import 'package:tagcash/apps/booking/models/service.dart';
import 'package:tagcash/apps/booking/models/staff.dart';
import 'package:tagcash/apps/booking/models/staff_list.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

import '../../../constants.dart';

class BookingTabScreen extends StatefulWidget {
  @override
  _BookingTabScreenState createState() => _BookingTabScreenState();
}

class _BookingTabScreenState extends State<BookingTabScreen>
    with SingleTickerProviderStateMixin {
  FocusNode myFocusNode = new FocusNode();
  FocusNode myFocusNode1 = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();

  Color selectedPeriodStartColor;
  Color selectedPeriodLastColor;
  Color selectedPeriodMiddleColor;

  List<Booking> getBookingData = new List<Booking>();

  List<String> selectedBookingDate = [];

  List<Booking> getEditBookingData = new List<Booking>();

  List<Service> getData = new List<Service>();
  List<StaffList> getStaffData = new List<StaffList>();
  List<Staff> getServiceStaffData = new List<Staff>();
  List<Service> getSelectedData = new List<Service>();
  List<String> selectedservice = [];
  List<String> selectedserviceid = [];

  List<StaffList> getSelectedData1 = new List<StaffList>();
  List<Staff> getSelectedData2 = new List<Staff>();

  List<String> selectedstaff = [];
  List<String> selectedstaffid = [];

  List<String> selectedservicestaff = [];
  List<String> selectedservicestaffid = [];

  bool sync_google = false,
      monday = true,
      tuesday = true,
      wednesday = true,
      thursday = true,
      friday = true,
      saturday = true,
      sunday = true;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _starttimeController = TextEditingController();
  TextEditingController _endtimeController = TextEditingController();
  bool isLoading = false;

  String service_name = 'Select service',
      service_id = '',
      filter_service_name = 'All Services',
      filter_service_id = '',
      filter_staff_name = 'All Staff',
      filter_staff_id = '',
      staff_name = '',
      staff_id = '',
      servicestaff_name = 'Any',
      servicestaff_id = '';
  var service_allocated;
  List<String> sendidlist = [];
  int start_hour, end_hour;

  /*calender*/
  DateTime _currentDate = new DateTime(2020, 11, 15);
  String _selectedDate;
  String _dateCount;
  String _range;
  String _rangeCount;

  List<String> bookingSelectedName = [];
  List<String> bookingSelectedBookingId = [];
  List<String> selectedBookingCountryCode = [];
  List<String> selectedBookingContact = [];
  List<String> selectedBookingEmail = [];
  List<String> selectedBookingServiceId = [];
  List<String> selectedBookDate = [];
  List<String> selectedBookingStartTime = [];
  List<String> selectedBookingEndTime = [];
  List<String> selectedBookingStaffId = [];
  List<String> selectedBookingNotes = [];

  var bookingIdList,
      bookingnameList,
      bookingContryCodeList,
      bookingContactList,
      bookingEmailList,
      bookingServiceIdList,
      bookingDateList,
      bookingStartTimeList,
      bookingEndTimeList,
      bookingStaffIdList,
      bookingNotesList;

  String mo_st = '9',
      tu_st = '9',
      we_st = '9',
      th_st = '9',
      fr_st = '9',
      sa_st = '9',
      su_st = '9';
  String mo_et = '18',
      tu_et = '18',
      we_et = '18',
      th_et = '18',
      fr_et = '18',
      sa_et = '18',
      su_et = '18';

  var booking_availability;
  List<String> bookAvailabilityList = [];

  String nowCommunityID = '0';

  List<DateTime> _selectedDates = [];
  DateTime _firstDate;
  DateTime _lastDate;
  DateTime _selectedDatee;

  @override
  void initState() {
    super.initState();
    _selectedDatee = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 372));
    _lastDate = DateTime.now().add(Duration(days: 3720));

    getUserService();
  }

  bool _isSelectableCustom(DateTime day) {
    return day.weekday < 6;
  }

  void _onSelectedDateChanged(DateTime newDate) {
    getEditBookingData.clear();
    setState(() {
      String formatteddate;
//      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      formatteddate = formatter.format(newDate);

      for (int i = 0; i < getBookingData.length; i++) {
        if (formatteddate == getBookingData[i].booking_date) {
          Booking booking = new Booking();
          booking.booking_id = getBookingData[i].booking_id;
          booking.name = getBookingData[i].name;
          booking.country_code = getBookingData[i].country_code;
          booking.contact = getBookingData[i].contact;
          booking.email = getBookingData[i].email;
          booking.service_id = getBookingData[i].service_id;
          booking.booking_date = getBookingData[i].booking_date;
          booking.booking_start_time = getBookingData[i].booking_start_time;
          booking.booking_end_time = getBookingData[i].booking_end_time;
          booking.staff_id = getBookingData[i].staff_id;
          booking.booking_notes = getBookingData[i].booking_notes;
          getEditBookingData.add(booking);
        }
      }

      if (getEditBookingData.length > 1) {
        print('if editbooking ' + selectedBookingDate.length.toString());

        showDialog(
            context: context,
            builder: (context) {
              return _BookingDialog(
                bookingData: getEditBookingData,
                bookingSelectedBookingId: bookingSelectedBookingId,
                bookingSelectedName: bookingSelectedName,
                selectedBookingCountryCode: selectedBookingCountryCode,
                selectedBookingContact: selectedBookingContact,
                selectedBookingEmail: selectedBookingEmail,
                selectedBookingServiceId: selectedBookingServiceId,
                selectedBookingDate: selectedBookDate,
                selectedBookingStartTime: selectedBookingStartTime,
                selectedBookingEndTime: selectedBookingEndTime,
                selectedBookingStaffId: selectedBookingStaffId,
                selectedBookingNotes: selectedBookingNotes,
                onSelectedBookingIdListChanged: (cities) {
                  bookingSelectedBookingId = cities;
                  bookingIdList = bookingSelectedBookingId
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedNameListChanged: (cities) {
                  bookingSelectedName = cities;
                  bookingnameList = bookingSelectedName
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingCountryCodeListChanged: (cities) {
                  selectedBookingCountryCode = cities;
                  bookingContryCodeList = selectedBookingCountryCode
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingContactListChanged: (cities) {
                  selectedBookingContact = cities;
                  bookingContactList = selectedBookingContact
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingEmailListChanged: (cities) {
                  selectedBookingEmail = cities;
                  bookingEmailList = selectedBookingEmail
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingServiceIdListChanged: (cities) {
                  selectedBookingServiceId = cities;
                  bookingServiceIdList = selectedBookingServiceId
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingDateListChanged: (cities) {
                  selectedBookDate = cities;
                  bookingDateList = selectedBookDate
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingStartTimeListChanged: (cities) {
                  selectedBookingStartTime = cities;
                  bookingStartTimeList = selectedBookingStartTime
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingEndTimeListChanged: (cities) {
                  selectedBookingEndTime = cities;
                  bookingEndTimeList = selectedBookingEndTime
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingStaffIdListChanged: (cities) {
                  selectedBookingStaffId = cities;
                  bookingStaffIdList = selectedBookingStaffId
                      .reduce((value, element) => value + ',' + element);
                },
                onSelectedBookingNotesListChanged: (cities) {
                  selectedBookingNotes = cities;
                  bookingNotesList = selectedBookingNotes
                      .reduce((value, element) => value + ',' + element);
                  displayBottomSheet(
                      context,
                      'edit',
                      bookingIdList.toString(),
                      bookingnameList.toString(),
                      bookingContryCodeList,
                      bookingContactList,
                      bookingEmailList,
                      bookingServiceIdList,
                      bookingDateList,
                      bookingStartTimeList,
                      bookingEndTimeList,
                      bookingStaffIdList,
                      bookingNotesList);
                },
              );
            });
      } else {
        print('else editbooking ' + selectedBookingDate.length.toString());
        displayBottomSheet(
            context,
            'edit',
            getEditBookingData[0].booking_id,
            getEditBookingData[0].name,
            getEditBookingData[0].country_code,
            getEditBookingData[0].contact,
            getEditBookingData[0].email,
            getEditBookingData[0].service_id,
            getEditBookingData[0].booking_date,
            getEditBookingData[0].booking_start_time,
            getEditBookingData[0].booking_end_time,
            getEditBookingData[0].staff_id,
            getEditBookingData[0].booking_notes);
      }
    });
  }

  dp.EventDecoration _eventDecorationBuilder(DateTime date) {
    List<DateTime> eventsDates = _selectedDates;

    bool isEventDate = eventsDates?.any((DateTime d) =>
            date.year == d.year &&
            date.month == d.month &&
            d.day == date.day) ??
        false;

    BoxDecoration roundedBorder =
        BoxDecoration(color: Colors.grey, shape: BoxShape.circle);

    return isEventDate
        ? dp.EventDecoration(boxDecoration: roundedBorder)
        : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    selectedPeriodLastColor = kUserBackColor;
    selectedPeriodMiddleColor = kPrimaryColor;
    selectedPeriodStartColor = kPrimaryColor;

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData
          .id
          .toString();
    }
  }

  void getBooking(String serviec_id, String staff_id) async {
    selectedBookingDate.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['service_id'] = serviec_id;
    apiBodyObj['staff_id '] = staff_id;
    apiBodyObj['booking_date'] = '';

    Map<String, dynamic> response =
        await NetworkHelper.request('BookingService/ListBooking', apiBodyObj);

    if (response['status'] == 'success') {
      List responseList = response['result'];

      getBookingData = responseList.map<Booking>((json) {
        return Booking.fromJson(json);
      }).toList();

      List<DateTime> days = [];
      for (int i = 0; i < getBookingData.length; i++) {
        print('getbooking' + getBookingData.length.toString());
        var inputFormat = DateFormat("dd-MM-yyyy");
        var date1 =
            inputFormat.parse(getBookingData[i].booking_date.toString());

        selectedBookingDate.add(getBookingData[i].booking_date.toString());

        var outputFormat = DateFormat("yyyy-MM-dd");
        var date2 = outputFormat.parse("$date1");

//        DateTime dateTimeCreatedAt = DateTime.parse(date2.toString());
        DateTime dateTimeCreatedAt = DateTime.parse(getBookingData[i].booking_date.toString());
        DateTime dateTimeNow = DateTime.now();
        final differenceInDays =
            dateTimeCreatedAt.difference(dateTimeNow).inDays;
        print(differenceInDays + 1);

        int diff = differenceInDays + 1;
        if (diff > 0) {
          days.add(dateTimeNow.add(Duration(days: differenceInDays + 1)));
          _selectedDates
              .add(dateTimeNow.add(Duration(days: differenceInDays + 1)));
          final now = DateTime.now();
          _eventDecorationBuilder(now);
        }
      }

      getMerchantAvailability();
      setState(() {
        isLoading = false;
      });
    } else {
      getMerchantAvailability();
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

      getStaff();
    } else {
      getStaff();
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

  void getStaff() async {

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('BookingService/listStaff');

    List responseList = response['result'];

    getStaffData = responseList.map<StaffList>((json) {
      return StaffList.fromJson(json);
    }).toList();
    var jsonn = response['result'];

    if (response['status'] == 'success') {
      getBooking('', '');
      setState(() {
        isLoading = false;
      });
    } else {
      getBooking('', '');
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

  void getServiceStaff(String service_id) async {

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['service_id'] = service_id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/GetServiceStaff', apiBodyObj);

    List responseList = response['result'];
    List staffresponseList = responseList[0]['staff'];

    getServiceStaffData = staffresponseList.map<Staff>((json) {
      return Staff.fromJson(json);
    }).toList();

    var jsonn = response['result'];

    if (response['status'] == 'success') {
      getBooking('', '');
      setState(() {
        isLoading = false;
      });
    } else {
      getBooking('', '');
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

  void addBooking(
      String name,
      String country_code,
      String contact,
      String email,
      String service_id,
      String date,
      String start_time,
      String end_time,
      String note,
      String staff_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = name;
    apiBodyObj['country_code'] = country_code;
    apiBodyObj['contact'] = contact;
    apiBodyObj['email'] = email;
    apiBodyObj['service_id'] = service_id;
    apiBodyObj['booking_date'] = date;
    apiBodyObj['booking_start_time'] = start_time;
    apiBodyObj['booking_end_time'] = end_time;
    apiBodyObj['booking_notes'] = note;
    apiBodyObj['staff_id'] = staff_id;

//
    Map<String, dynamic> response =
        await NetworkHelper.request('BookingService/CreateBooking', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getBooking('', '');
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

  void addBookingAvailabillity() async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['merchant_availability'] = bookAvailabilityList.toString();

    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/MerchantBookingAvailability', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      bookAvailabilityList.clear();
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

  void editBooking(
      String id,
      String name,
      String country_code,
      String contact,
      String email,
      String service_id,
      String date,
      String start_time,
      String end_time,
      String note,
      String staff_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = id;
    apiBodyObj['name'] = name;
    apiBodyObj['country_code'] = country_code;
    apiBodyObj['contact'] = contact;
    apiBodyObj['email'] = email;
    apiBodyObj['service_id'] = service_id;
    apiBodyObj['booking_date'] = date;
    apiBodyObj['booking_start_time'] = start_time;
    apiBodyObj['booking_end_time'] = end_time;
    apiBodyObj['booking_notes'] = note;
    apiBodyObj['staff_id'] = staff_id;

//
    Map<String, dynamic> response =
        await NetworkHelper.request('BookingService/EditBooking', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getBooking('', '');
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

  void removeBooking(String booking_id) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['booking_id'] = booking_id;

//
    Map<String, dynamic> response =
        await NetworkHelper.request('BookingService/RemoveBooking', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      getBooking('', '');
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

  void getMerchantAvailability() async {

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['owner_id'] = nowCommunityID;

    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/GetMerchantService', apiBodyObj);


    var jsonn = response['result'];

    if (response['status'] == 'success') {
      setState(() {
        mo_st = jsonn['availability'][0]['start_time'];
        mo_et = jsonn['availability'][0]['end_time'];
        monday = jsonn['availability'][0]['is_closed'];

        tu_st = jsonn['availability'][1]['start_time'];
        tu_et = jsonn['availability'][1]['end_time'];
        tuesday = jsonn['availability'][1]['is_closed'];

        we_st = jsonn['availability'][2]['start_time'];
        we_et = jsonn['availability'][2]['end_time'];
        wednesday = jsonn['availability'][2]['is_closed'];

        th_st = jsonn['availability'][3]['start_time'];
        th_et = jsonn['availability'][3]['end_time'];
        thursday = jsonn['availability'][3]['is_closed'];

        fr_st = jsonn['availability'][4]['start_time'];
        fr_et = jsonn['availability'][4]['end_time'];
        friday = jsonn['availability'][4]['is_closed'];

        sa_st = jsonn['availability'][5]['start_time'];
        sa_et = jsonn['availability'][5]['end_time'];
        saturday = jsonn['availability'][5]['is_closed'];

        su_st = jsonn['availability'][6]['start_time'];
        su_et = jsonn['availability'][6]['end_time'];
        sunday = jsonn['availability'][6]['is_closed'];

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
    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .bodyText1
            .copyWith(color: Colors.white),
        selectedSingleDateDecoration:
            BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle));
    // TODO: implement build
    return Scaffold(
        body: Stack(
      children: [
        ListView(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                            flex: 1,
                            child: Container(
                                decoration: new BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xFFACACAC), width: 0.5),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filter_service_name,
                                                style: Theme.of(context).textTheme.bodyText2.apply(),
                                                textAlign: TextAlign.center,
                                              ),
                                              FaIcon(
                                                FontAwesomeIcons.angleDown,
                                                size: 16,
                                                color: Color(0xFFACACAC),
                                              ),
                                            ],
                                          )),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return _ServiceDialog(
                                                  serviceData: getData,
                                                  serviceSelectedData:
                                                      getSelectedData,
                                                  selectedService:
                                                      selectedservice,
                                                  selectedServiceId:
                                                      selectedserviceid,
                                                  onSelectedCitiesListChanged:
                                                      (cities) {},
                                                  onSelectedTaxIdListChanged:
                                                      (cities) {},
                                                  onSelectedTaxListChanged:
                                                      (cities) {
                                                    getSelectedData = cities;
                                                    setState(() {
                                                      if (getSelectedData
                                                              .length !=
                                                          0) {
                                                        selectedservice.clear();
                                                        selectedserviceid
                                                            .clear();
                                                        service_allocated = '';
                                                        sendidlist.clear();

                                                        for (int i = 0;
                                                            i <
                                                                getSelectedData
                                                                    .length;
                                                            i++) {
                                                          selectedservice.add(
                                                              getSelectedData[i]
                                                                  .name);
                                                          selectedserviceid.add(
                                                              getSelectedData[i]
                                                                  .id);

                                                          var stringList =
                                                              selectedservice
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      ',' +
                                                                      element);
                                                          filter_service_name =
                                                              stringList;

                                                          var serviceIdList =
                                                              selectedserviceid
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      ',' +
                                                                      element);
                                                          filter_service_id =
                                                              serviceIdList;
                                                        }

                                                        getBooking(
                                                            filter_service_id,
                                                            '');
                                                      } else {
                                                        sendidlist.clear();
                                                        service_name = '';
                                                      }
                                                    });
                                                  });
                                            });
                                      },
                                    )
                                  ],
                                ))),
                        SizedBox(width: 5),
                        Flexible(
                            flex: 1,
                            child: Container(
                                decoration: new BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xFFACACAC), width: 0.5),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filter_staff_name,
                                                style: Theme.of(context).textTheme.bodyText2.apply(),
                                                textAlign: TextAlign.center,
                                              ),
                                              FaIcon(
                                                FontAwesomeIcons.angleDown,
                                                size: 16,
                                                color: Color(0xFFACACAC),
                                              ),
                                            ],
                                          )),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return _StaffDialog(
                                                  staffData: getStaffData,
                                                  staffSelectedData:
                                                      getSelectedData1,
                                                  selectedStaff: selectedstaff,
                                                  selectedStaffId:
                                                      selectedstaffid,
                                                  onSelectedCitiesListChanged:
                                                      (cities) {},
                                                  onSelectedTaxIdListChanged:
                                                      (cities) {},
                                                  onSelectedTaxListChanged:
                                                      (cities) {
                                                    getSelectedData1 = cities;
                                                    setState(() {
                                                      if (getSelectedData1
                                                              .length !=
                                                          0) {
                                                        selectedstaff.clear();
                                                        selectedstaffid.clear();
                                                        service_allocated = '';
                                                        sendidlist.clear();

                                                        for (int i = 0;
                                                            i <
                                                                getSelectedData1
                                                                    .length;
                                                            i++) {
                                                          selectedstaff.add(
                                                              getSelectedData1[
                                                                      i]
                                                                  .staff_name);
                                                          selectedstaffid.add(
                                                              getSelectedData1[
                                                                      i]
                                                                  .id);

                                                          var stringList =
                                                              selectedstaff
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      ',' +
                                                                      element);
                                                          filter_staff_name =
                                                              stringList;

                                                          var stafIdList =
                                                              selectedstaffid
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      ',' +
                                                                      element);
                                                          filter_staff_id =
                                                              stafIdList;
                                                        }

                                                        getBooking('',
                                                            filter_staff_id);
                                                      } else {
                                                        sendidlist.clear();
                                                        service_name = '';
                                                      }
                                                    });
                                                  });
                                            });
                                      },
                                    )
                                  ],
                                ))),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: dp.DayPicker.single(
                      selectedDate: _selectedDatee,
                      onChanged: _onSelectedDateChanged,
                      firstDate: _firstDate,
                      lastDate: _lastDate,
                      datePickerStyles: styles,
                      datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                          scrollPhysics: NeverScrollableScrollPhysics(),
                          maxDayPickerRowCount: 2,
                          showPrevMonthEnd: true,
                          showNextMonthStart: true),
                      selectableDayPredicate: _isSelectableCustom,
                      eventDecorationBuilder: _eventDecorationBuilder,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: sync_google,
                            onChanged: (val) {
                              setState(() {
                                sync_google = val;
                              });
                            },
                          ),
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
                  Container(
                    child: Wrap(
                      spacing: 4.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      direction: Axis.horizontal, //
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: monday,
                            onChanged: (val) {
                              setState(() {
                                monday = val;
                                booking_availability =
                                '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                bookAvailabilityList
                                    .add(booking_availability);
                                addBookingAvailabillity();
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            'Mon ' + mo_st + '-' + mo_et,
                            style: new TextStyle(fontSize: 14.0),
                          ),
                          onTap: () async {
                            TimeRange result = await showTimeRangePicker(
                                hideButtons: true,
                                context: context,
                                interval: const Duration(minutes: 60),
                                start: TimeOfDay(
                                    hour: int.parse(mo_st), minute: 0),
                                end: TimeOfDay(
                                    hour: int.parse(mo_et), minute: 0),
                                disabledTime: TimeRange(
                                    startTime:
                                    TimeOfDay(hour: 0, minute: 0),
                                    endTime:
                                    TimeOfDay(hour: 0, minute: 0)),
                                disabledColor:
                                Colors.red.withOpacity(0.5),
                                strokeWidth: 4,
                                ticks: 24,
                                ticksOffset: -7,
                                ticksLength: 15,
                                ticksColor: Colors.grey,
                                labels: [
                                  "12 pm",
                                  "3 am",
                                  "6 am",
                                  "9 am",
                                  "12 am",
                                  "3 pm",
                                  "6 pm",
                                  "9 pm"
                                ].asMap().entries.map((e) {
                                  return ClockLabel.fromIndex(
                                      idx: e.key,
                                      length: 8,
                                      text: e.value);
                                }).toList(),
                                labelOffset: 35,
                                rotateLabels: false,
                                padding: 60);

                            setState(() {
                              mo_st = result.startTime.hour.toString();
                              mo_et = result.endTime.hour.toString();
                              booking_availability =
                              '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                              bookAvailabilityList
                                  .add(booking_availability);
                              addBookingAvailabillity();
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: tuesday,
                            onChanged: (val) {
                              setState(() {
                                tuesday = val;
                                booking_availability =
                                '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                bookAvailabilityList
                                    .add(booking_availability);
                                addBookingAvailabillity();
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            'Tue ' + tu_st + '-' + tu_et,
                            style: new TextStyle(fontSize: 14.0),
                          ),
                          onTap: () async {
                            TimeRange result = await showTimeRangePicker(
                                hideButtons: true,
                                context: context,
                                interval: const Duration(minutes: 60),
                                start: TimeOfDay(
                                    hour: int.parse(tu_st), minute: 0),
                                end: TimeOfDay(
                                    hour: int.parse(tu_et), minute: 0),
                                disabledTime: TimeRange(
                                    startTime:
                                    TimeOfDay(hour: 0, minute: 0),
                                    endTime:
                                    TimeOfDay(hour: 0, minute: 0)),
                                disabledColor:
                                Colors.red.withOpacity(0.5),
                                strokeWidth: 4,
                                ticks: 24,
                                ticksOffset: -7,
                                ticksLength: 15,
                                ticksColor: Colors.grey,
                                labels: [
                                  "12 pm",
                                  "3 am",
                                  "6 am",
                                  "9 am",
                                  "12 am",
                                  "3 pm",
                                  "6 pm",
                                  "9 pm"
                                ].asMap().entries.map((e) {
                                  return ClockLabel.fromIndex(
                                      idx: e.key,
                                      length: 8,
                                      text: e.value);
                                }).toList(),
                                labelOffset: 35,
                                rotateLabels: false,
                                padding: 60);

                            setState(() {
                              tu_st = result.startTime.hour.toString();
                              tu_et = result.endTime.hour.toString();
                              booking_availability =
                              '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                              bookAvailabilityList
                                  .add(booking_availability);
                              addBookingAvailabillity();
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: wednesday,
                            onChanged: (val) {
                              setState(() {
                                wednesday = val;
                                booking_availability =
                                '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                bookAvailabilityList
                                    .add(booking_availability);
                                addBookingAvailabillity();
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            'Wed ' + we_st + '-' + we_et,
                            style: new TextStyle(fontSize: 14.0),
                          ),
                          onTap: () async {
                            TimeRange result = await showTimeRangePicker(
                                hideButtons: true,
                                context: context,
                                interval: const Duration(minutes: 60),
                                start: TimeOfDay(
                                    hour: int.parse(we_st), minute: 0),
                                end: TimeOfDay(
                                    hour: int.parse(we_et), minute: 0),
                                disabledTime: TimeRange(
                                    startTime:
                                    TimeOfDay(hour: 0, minute: 0),
                                    endTime:
                                    TimeOfDay(hour: 0, minute: 0)),
                                disabledColor:
                                Colors.red.withOpacity(0.5),
                                strokeWidth: 4,
                                ticks: 24,
                                ticksOffset: -7,
                                ticksLength: 15,
                                ticksColor: Colors.grey,
                                labels: [
                                  "12 pm",
                                  "3 am",
                                  "6 am",
                                  "9 am",
                                  "12 am",
                                  "3 pm",
                                  "6 pm",
                                  "9 pm"
                                ].asMap().entries.map((e) {
                                  return ClockLabel.fromIndex(
                                      idx: e.key,
                                      length: 8,
                                      text: e.value);
                                }).toList(),
                                labelOffset: 35,
                                rotateLabels: false,
                                padding: 60);

                            setState(() {
                              we_st = result.startTime.hour.toString();
                              we_et = result.endTime.hour.toString();
                              booking_availability =
                              '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                              bookAvailabilityList
                                  .add(booking_availability);
                              addBookingAvailabillity();
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            activeColor: kPrimaryColor,
                            value: thursday,
                            onChanged: (val) {
                              setState(() {
                                thursday = val;
                                booking_availability =
                                '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                bookAvailabilityList
                                    .add(booking_availability);
                                addBookingAvailabillity();
                              });
                            },
                          ),
                        ),

                        GestureDetector(
                          child: Text(
                            'Thu ' + th_st + '-' + th_et,
                            style: new TextStyle(fontSize: 14.0),
                          ),
                          onTap: () async {
                            TimeRange result = await showTimeRangePicker(
                                hideButtons: true,
                                context: context,
                                interval: const Duration(minutes: 60),
                                start: TimeOfDay(
                                    hour: int.parse(th_st), minute: 0),
                                end: TimeOfDay(
                                    hour: int.parse(th_et), minute: 0),
                                disabledTime: TimeRange(
                                    startTime:
                                    TimeOfDay(hour: 0, minute: 0),
                                    endTime:
                                    TimeOfDay(hour: 0, minute: 0)),
                                disabledColor:
                                Colors.red.withOpacity(0.5),
                                strokeWidth: 4,
                                ticks: 24,
                                ticksOffset: -7,
                                ticksLength: 15,
                                ticksColor: Colors.grey,
                                labels: [
                                  "12 pm",
                                  "3 am",
                                  "6 am",
                                  "9 am",
                                  "12 am",
                                  "3 pm",
                                  "6 pm",
                                  "9 pm"
                                ].asMap().entries.map((e) {
                                  return ClockLabel.fromIndex(
                                      idx: e.key,
                                      length: 8,
                                      text: e.value);
                                }).toList(),
                                labelOffset: 35,
                                rotateLabels: false,
                                padding: 60);

                            setState(() {
                              th_st = result.startTime.hour.toString();
                              th_et = result.endTime.hour.toString();
                              booking_availability =
                              '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                              bookAvailabilityList
                                  .add(booking_availability);
                              addBookingAvailabillity();
                            });
                          },
                        ),
                      ],// main axis (rows or columns)
                    ),
                  ),

                  SizedBox(height: 15),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: friday,
                                  onChanged: (val) {
                                    setState(() {
                                      friday = val;
                                      booking_availability =
                                          '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                      bookAvailabilityList
                                          .add(booking_availability);
                                      addBookingAvailabillity();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                child: Text(
                                  'Fri ' + fr_st + '-' + fr_et,
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                                onTap: () async {
                                  TimeRange result = await showTimeRangePicker(
                                      hideButtons: true,
                                      context: context,
                                      interval: const Duration(minutes: 60),
                                      start: TimeOfDay(
                                          hour: int.parse(fr_st), minute: 0),
                                      end: TimeOfDay(
                                          hour: int.parse(fr_et), minute: 0),
                                      disabledTime: TimeRange(
                                          startTime:
                                              TimeOfDay(hour: 0, minute: 0),
                                          endTime:
                                              TimeOfDay(hour: 0, minute: 0)),
                                      disabledColor:
                                          Colors.red.withOpacity(0.5),
                                      strokeWidth: 4,
                                      ticks: 24,
                                      ticksOffset: -7,
                                      ticksLength: 15,
                                      ticksColor: Colors.grey,
                                      labels: [
                                        "12 pm",
                                        "3 am",
                                        "6 am",
                                        "9 am",
                                        "12 am",
                                        "3 pm",
                                        "6 pm",
                                        "9 pm"
                                      ].asMap().entries.map((e) {
                                        return ClockLabel.fromIndex(
                                            idx: e.key,
                                            length: 8,
                                            text: e.value);
                                      }).toList(),
                                      labelOffset: 35,
                                      rotateLabels: false,
                                      padding: 60);

                                  setState(() {
                                    fr_st = result.startTime.hour.toString();
                                    fr_et = result.endTime.hour.toString();
                                    booking_availability =
                                        '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                    bookAvailabilityList
                                        .add(booking_availability);
                                    addBookingAvailabillity();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: saturday,
                                  onChanged: (val) {
                                    setState(() {
                                      saturday = val;
                                      booking_availability =
                                          '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                      bookAvailabilityList
                                          .add(booking_availability);
                                      addBookingAvailabillity();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                child: Text(
                                  'Sat ' + sa_st + '-' + sa_et,
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                                onTap: () async {
                                  TimeRange result = await showTimeRangePicker(
                                      hideButtons: true,
                                      context: context,
                                      interval: const Duration(minutes: 60),
                                      start: TimeOfDay(
                                          hour: int.parse(sa_st), minute: 0),
                                      end: TimeOfDay(
                                          hour: int.parse(sa_et), minute: 0),
                                      disabledTime: TimeRange(
                                          startTime:
                                              TimeOfDay(hour: 0, minute: 0),
                                          endTime:
                                              TimeOfDay(hour: 0, minute: 0)),
                                      disabledColor:
                                          Colors.red.withOpacity(0.5),
                                      strokeWidth: 4,
                                      ticks: 24,
                                      ticksOffset: -7,
                                      ticksLength: 15,
                                      ticksColor: Colors.grey,
                                      labels: [
                                        "12 pm",
                                        "3 am",
                                        "6 am",
                                        "9 am",
                                        "12 am",
                                        "3 pm",
                                        "6 pm",
                                        "9 pm"
                                      ].asMap().entries.map((e) {
                                        return ClockLabel.fromIndex(
                                            idx: e.key,
                                            length: 8,
                                            text: e.value);
                                      }).toList(),
                                      labelOffset: 35,
                                      rotateLabels: false,
                                      padding: 60);

                                  setState(() {
                                    sa_st = result.startTime.hour.toString();
                                    sa_et = result.endTime.hour.toString();
                                    booking_availability =
                                        '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                    bookAvailabilityList
                                        .add(booking_availability);
                                    addBookingAvailabillity();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  activeColor: kPrimaryColor,
                                  value: sunday,
                                  onChanged: (val) {
                                    setState(() {
                                      sunday = val;
                                      booking_availability =
                                          '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                      bookAvailabilityList
                                          .add(booking_availability);
                                      addBookingAvailabillity();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                child: Text(
                                  'Sun ' + su_st + '-' + su_et,
                                  style: new TextStyle(fontSize: 14.0),
                                ),
                                onTap: () async {
                                  TimeRange result = await showTimeRangePicker(
                                      hideButtons: true,
                                      context: context,
                                      interval: const Duration(minutes: 60),
                                      start: TimeOfDay(
                                          hour: int.parse(su_st), minute: 0),
                                      end: TimeOfDay(
                                          hour: int.parse(su_et), minute: 0),
                                      disabledTime: TimeRange(
                                          startTime:
                                              TimeOfDay(hour: 0, minute: 0),
                                          endTime:
                                              TimeOfDay(hour: 0, minute: 0)),
                                      disabledColor:
                                          Colors.red.withOpacity(0.5),
                                      strokeWidth: 4,
                                      ticks: 24,
                                      ticksOffset: -7,
                                      ticksLength: 15,
                                      ticksColor: Colors.grey,
                                      labels: [
                                        "12 pm",
                                        "3 am",
                                        "6 am",
                                        "9 am",
                                        "12 am",
                                        "3 pm",
                                        "6 pm",
                                        "9 pm"
                                      ].asMap().entries.map((e) {
                                        return ClockLabel.fromIndex(
                                            idx: e.key,
                                            length: 8,
                                            text: e.value);
                                      }).toList(),
                                      labelOffset: 35,
                                      rotateLabels: false,
                                      padding: 60);

                                  setState(() {
                                    su_st = result.startTime.hour.toString();
                                    su_et = result.endTime.hour.toString();
                                    booking_availability =
                                        '{"day" : "Monday", "start_time" : "$mo_st", "end_time" : "$mo_et", "is_closed" : $monday}, {"day" : "Tuesday", "start_time" : "$tu_st", "end_time" : "$tu_et", "is_closed" : $tuesday}, {"day" : "Thursday", "start_time" : "$we_st", "end_time" : "$we_et", "is_closed" : $wednesday}, {"day" : "Wednesday", "start_time" : "$th_st", "end_time" : "$th_et", "is_closed" : $thursday}, {"day" : "Friday", "start_time" : "$fr_st", "end_time" : "$fr_et", "is_closed" : $friday}, {"day" : "Saturday", "start_time" : "$sa_st", "end_time" : "$sa_et", "is_closed" : $saturday}, {"day" : "Sunday", "start_time" : "$su_st", "end_time" : "$su_et", "is_closed" : $sunday}';
                                    bookAvailabilityList
                                        .add(booking_availability);
                                    addBookingAvailabillity();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Container(
          padding: EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [toggle()],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    ));
  }

  Widget timePicker() {
    return FloatingActionButton(
      onPressed: () {
        displayBottomSheet(
            context, 'add', '', '', '', '', '', '', '', '', '', '', '');
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

  Widget toggle() {
    return FloatingActionButton(
      onPressed: () {
        displayBottomSheet(
            context, 'add', '', '', '', '', '', '', '', '', '', '', '');
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

  void displayBottomSheet(
      BuildContext context,
      String type,
      String booking_id,
      String booking_name,
      String booking_country_code,
      String booking_contact,
      String booking_email,
      String booking_serviceId,
      String booking_date,
      String booking_starttime,
      String booking_endtime,
      String booking_staffId,
      String booking_note) {
    List<Country_code> _currency = Country_code.getCurrency();
    List<DropdownMenuItem<Country_code>> _dropdownMenuItems;
    Country_code _selectedCompany;

    List<DropdownMenuItem<Country_code>> buildDropdownMenuItems(
        List companies) {
      List<DropdownMenuItem<Country_code>> items = List();
      for (Country_code company in companies) {
        items.add(
          DropdownMenuItem(
            value: company,
            child: Text(
              company.name,
              style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black)
            ),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems = buildDropdownMenuItems(_currency);

    if (booking_country_code == '+63') {
      _selectedCompany = _dropdownMenuItems[0].value;
    } else if (booking_country_code == '+357') {
      _selectedCompany = _dropdownMenuItems[1].value;
    } else {
      _selectedCompany = _dropdownMenuItems[0].value;
    }

    _nameController.text = booking_name;
    _numberController.text = booking_contact;
    _emailController.text = booking_email;
    _dateController.text = booking_date;
    _starttimeController.text = booking_starttime;
    _endtimeController.text = booking_endtime;
    _notesController.text = booking_note;

    if (type == 'edit') {
      service_id = booking_serviceId;
      servicestaff_id = booking_staffId;

      getServiceStaff(service_id);

      for (int i = 0; i < getData.length; i++) {
        if (booking_serviceId == getData[i].id) {
          service_name = getData[i].name;
          for (int j = 0; j < getData[i].staff.length; j++) {
            if (booking_staffId == getData[i].staff[j].id) {
              servicestaff_name = getData[i].staff[j].staff_name;
            }
          }
        }
      }
    } else {
      service_name = 'Select service';
      servicestaff_name = 'Any';
    }

    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.black87.withOpacity(0.3),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return BottomSheet(
              backgroundColor: Colors.transparent,
              onClosing: () {},
              builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (BuildContext context, setState) => Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(20.0),
                                topRight: const Radius.circular(20.0))),
                        padding: EdgeInsets.all(20),
                        height: 600,
                        child: ListView(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  TextField(
                                    focusNode: myFocusNode,
                                    controller: _nameController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                        labelText: 'Name',
                                        labelStyle:
                                            TextStyle(color: kPrimaryColor),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: kPrimaryColor),
                                      ),),
                                    style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Contact Number',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                            flex: 2,
                                            child: Container(
                                              decoration: new BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xFFACACAC),
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0)),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    DropdownButton(
                                                      isExpanded: true,
                                                      value: _selectedCompany,
                                                      items: _dropdownMenuItems,
                                                      underline: Container(),
                                                      onChanged: (val) {
                                                        setState(() {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          _selectedCompany =
                                                              val;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                        SizedBox(width: 10),
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: TextField(
                                                    focusNode: myFocusNode1,
                                                    controller:
                                                        _numberController,
                                                    textCapitalization: TextCapitalization.sentences,
                                                    textInputAction: TextInputAction.next,
                                                    decoration: InputDecoration(
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey),
                                                      ),
                                                      focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: kPrimaryColor),
                                                      ),),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    focusNode: myFocusNode2,
                                    controller: _emailController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle:
                                            TextStyle(color: kPrimaryColor),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: kPrimaryColor),
                                      ),),
                                    keyboardType: TextInputType.emailAddress,
                                    style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Service',
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
                                          border: Border.all(
                                              color: Color(0xFFACACAC),
                                              width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 15),
                                                      child: Text(
                                                        service_name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )),
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .angleDown,
                                                      size: 16,
                                                      color: Color(0xFFACACAC),
                                                    ),
                                                  ],
                                                )),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return _ServiceDialog(
                                                        serviceData: getData,
                                                        serviceSelectedData:
                                                            getSelectedData,
                                                        selectedService:
                                                            selectedservice,
                                                        selectedServiceId:
                                                            selectedserviceid,
                                                        onSelectedCitiesListChanged:
                                                            (cities) {},
                                                        onSelectedTaxIdListChanged:
                                                            (cities) {},
                                                        onSelectedTaxListChanged:
                                                            (cities) {
                                                          getSelectedData =
                                                              cities;
                                                          setState(() {
                                                            if (getSelectedData
                                                                    .length !=
                                                                0) {
                                                              selectedservice
                                                                  .clear();
                                                              selectedserviceid
                                                                  .clear();
                                                              service_allocated =
                                                                  '';
                                                              sendidlist
                                                                  .clear();

                                                              for (int i = 0;
                                                                  i <
                                                                      getSelectedData
                                                                          .length;
                                                                  i++) {
                                                                selectedservice.add(
                                                                    getSelectedData[
                                                                            i]
                                                                        .name);
                                                                selectedserviceid.add(
                                                                    getSelectedData[
                                                                            i]
                                                                        .id);

                                                                var stringList =
                                                                    selectedservice.reduce((value,
                                                                            element) =>
                                                                        value +
                                                                        ',' +
                                                                        element);
                                                                service_name =
                                                                    stringList;

                                                                var serviceList =
                                                                    selectedserviceid.reduce((value,
                                                                            element) =>
                                                                        value +
                                                                        ',' +
                                                                        element);
                                                                service_id =
                                                                    serviceList;

                                                                var staff_name =
                                                                    getSelectedData[
                                                                            i]
                                                                        .name;
                                                                var staff_id =
                                                                    getSelectedData[
                                                                            i]
                                                                        .id;

                                                                service_allocated =
                                                                    '{"staff_name" : "$staff_name", "staff_id" : "$staff_id"}';
                                                                sendidlist.add(
                                                                    service_allocated);
                                                              }

                                                              getServiceStaff(
                                                                  service_id);

                                                            } else {
                                                              sendidlist
                                                                  .clear();
                                                              service_name = '';
                                                            }
                                                          });
                                                        });
                                                  });
                                            },
                                          )
                                        ],
                                      )),
                                  SizedBox(height: 5),
                                  Container(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            child: TextField(
                                              readOnly: true,
                                              enableInteractiveSelection: true,
                                              controller: _dateController,
                                              decoration: InputDecoration(
                                                  labelText: 'Date',
                                                  labelStyle: TextStyle(
                                                      color: kPrimaryColor),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: kPrimaryColor),
                                                ),),
                                              style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                _showDatePicker();
                                              },
                                            )),
                                        SizedBox(width: 5),
                                        Flexible(
                                          flex: 1,
                                          child: TextField(
                                            readOnly: true,
                                            enableInteractiveSelection: true,
                                            controller: _starttimeController,
                                            decoration: InputDecoration(
                                                labelText: 'Start Time',
                                                labelStyle: TextStyle(
                                                    color: kPrimaryColor),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: kPrimaryColor),
                                              ),),
                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              _showStartTimePicker(
                                                  'start', type);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          flex: 1,
                                          child: TextField(
                                            readOnly: true,
                                            enableInteractiveSelection: true,
                                            controller: _endtimeController,
                                            decoration: InputDecoration(
                                                labelText: 'End Time',
                                                labelStyle: TextStyle(
                                                    color: kPrimaryColor),
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: kPrimaryColor),
                                              ),),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              _showStartTimePicker('end', type);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Staff(optional)',
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
                                          border: Border.all(
                                              color: Color(0xFFACACAC),
                                              width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: 15),
                                                      child: Text(
                                                        servicestaff_name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false,
                                                        style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )),
                                                    FaIcon(
                                                      FontAwesomeIcons
                                                          .angleDown,
                                                      size: 16,
                                                      color: Color(0xFFACACAC),
                                                    ),
                                                  ],
                                                )),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return _ServicecStaffDialog(
                                                        staffData:
                                                            getServiceStaffData,
                                                        serSelectedData:
                                                            getSelectedData2,
                                                        selectedStaff:
                                                            selectedservicestaff,
                                                        selectedStaffId:
                                                            selectedservicestaffid,
                                                        onSelectedCitiesListChanged:
                                                            (cities) {},
                                                        onSelectedTaxIdListChanged:
                                                            (cities) {},
                                                        onSelectedTaxListChanged:
                                                            (cities) {
                                                          getSelectedData2 =
                                                              cities;
                                                          setState(() {
                                                            if (getSelectedData2
                                                                    .length !=
                                                                0) {
                                                              selectedservicestaff
                                                                  .clear();
                                                              selectedservicestaffid
                                                                  .clear();
                                                              service_allocated =
                                                                  '';
                                                              sendidlist
                                                                  .clear();

                                                              for (int i = 0;
                                                                  i <
                                                                      getSelectedData2
                                                                          .length;
                                                                  i++) {
                                                                selectedservicestaff.add(
                                                                    getSelectedData2[
                                                                            i]
                                                                        .staff_name);
                                                                selectedservicestaffid.add(
                                                                    getSelectedData2[
                                                                            i]
                                                                        .id);

                                                                var stringList =
                                                                    selectedservicestaff.reduce((value,
                                                                            element) =>
                                                                        value +
                                                                        ',' +
                                                                        element);
                                                                servicestaff_name =
                                                                    stringList;

                                                                var staffidList =
                                                                    selectedservicestaffid.reduce((value,
                                                                            element) =>
                                                                        value +
                                                                        ',' +
                                                                        element);
                                                                servicestaff_id =
                                                                    staffidList;
                                                              }

                                                            } else {
                                                              sendidlist
                                                                  .clear();
                                                              service_name = '';
                                                            }
                                                          });
                                                        });
                                                  });
                                            },
                                          )
                                        ],
                                      )),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: _notesController,
                                    decoration: InputDecoration(
                                        labelText: 'Notes',
                                        labelStyle:
                                            TextStyle(color: kPrimaryColor),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: kPrimaryColor),
                                      ),),
                                    keyboardType: TextInputType.emailAddress,
                                    style: Theme.of(context).textTheme.bodyText2.apply(color: Colors.black),
                                  ),
                                  type == 'edit'
                                      ? Flexible(
                                          child: Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                type == 'edit'
                                                    ? Flexible(
                                                        flex: 1,
                                                        child: Container(
                                                          child: ButtonTheme(
                                                            height: 40,
                                                            minWidth:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: RaisedButton(
                                                              color:
                                                                  kUserBackColor,
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                removeBooking(booking_id);
                                                              },
                                                              child: Text(
                                                                'DELETE',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  letterSpacing:
                                                                      1,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                    : Container(),
                                                type == 'edit'
                                                    ? SizedBox(width: 10)
                                                    : Container(),
                                                Flexible(
                                                    flex: 2,
                                                    child: Container(
                                                      child: ButtonTheme(
                                                        height: 40,
                                                        minWidth: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        child: RaisedButton(
                                                          color: kPrimaryColor,
                                                          onPressed: () {
                                                            if (_nameController
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title: getTranslated(
                                                                      context,
                                                                      'error'),
                                                                  message:
                                                                      'Name required');
                                                            } else if (_dateController
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title: getTranslated(
                                                                      context,
                                                                      'error'),
                                                                  message:
                                                                      'Date required');
                                                            } else if (_starttimeController
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title: getTranslated(
                                                                      context,
                                                                      'error'),
                                                                  message:
                                                                      'Start time required');
                                                            } else if (_endtimeController
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title: getTranslated(
                                                                      context,
                                                                      'error'),
                                                                  message:
                                                                      'End time required');
                                                            } else if (_notesController
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title: getTranslated(
                                                                      context,
                                                                      'error'),
                                                                  message:
                                                                      'Note required');
                                                            } else {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              if (type ==
                                                                  'add') {
                                                                addBooking(
                                                                    _nameController
                                                                        .text,
                                                                    _selectedCompany
                                                                        .name,
                                                                    _numberController
                                                                        .text,
                                                                    _emailController
                                                                        .text,
                                                                    service_id,
                                                                    _dateController
                                                                        .text,
                                                                    _starttimeController
                                                                        .text,
                                                                    _endtimeController
                                                                        .text,
                                                                    _notesController
                                                                        .text,
                                                                    servicestaff_id);
                                                              } else {
                                                                editBooking(
                                                                    booking_id,
                                                                    _nameController
                                                                        .text,
                                                                    _selectedCompany
                                                                        .name,
                                                                    _numberController
                                                                        .text,
                                                                    _emailController
                                                                        .text,
                                                                    service_id,
                                                                    _dateController
                                                                        .text,
                                                                    _starttimeController
                                                                        .text,
                                                                    _endtimeController
                                                                        .text,
                                                                    _notesController
                                                                        .text,
                                                                    servicestaff_id);
                                                              }
                                                            }
                                                          },
                                                          child: Text(
                                                            'SAVE',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                      : Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: ButtonTheme(
                                            height: 40,
                                            minWidth: MediaQuery.of(context)
                                                .size
                                                .width,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: RaisedButton(
                                              color: kPrimaryColor,
                                              onPressed: () {
                                                if (_nameController.text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message: 'Name required');
                                                } else if (_numberController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message:
                                                          'Contact Number required');
                                                } else if (_emailController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message:
                                                          'Email required');
                                                } else if (_dateController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message: 'Date required');
                                                } else if (_starttimeController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message:
                                                          'Start time required');
                                                } else if (_endtimeController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message:
                                                          'End time required');
                                                } else if (_notesController
                                                        .text ==
                                                    '') {
                                                  showSimpleDialog(context,
                                                      title: getTranslated(
                                                          context, 'error'),
                                                      message: 'Note required');
                                                } else {
                                                  Navigator.of(context).pop();
                                                  if (type == 'add') {
                                                    addBooking(
                                                        _nameController.text,
                                                        _selectedCompany.name,
                                                        _numberController.text,
                                                        _emailController.text,
                                                        service_id,
                                                        _dateController.text,
                                                        _starttimeController
                                                            .text,
                                                        _endtimeController.text,
                                                        _notesController.text,
                                                        servicestaff_id);
                                                  } else {
                                                    editBooking(
                                                        booking_id,
                                                        _nameController.text,
                                                        _selectedCompany.name,
                                                        _numberController.text,
                                                        _emailController.text,
                                                        service_id,
                                                        _dateController.text,
                                                        _starttimeController
                                                            .text,
                                                        _endtimeController.text,
                                                        _notesController.text,
                                                        servicestaff_id);
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
                                        )
                                ],
                              ),
                            )
                          ],
                        )));
              });
        });
  }

  _showDatePicker() async {
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 0)),
        lastDate: DateTime(2100));
    int dd = picker.day;
    String ddd;
    if (dd < 9) {
      ddd = '0' + dd.toString();
    } else {
      ddd = dd.toString();
    }

    int mm = picker.month;
    String mmm;
    if (mm < 9) {
      mmm = '0' + mm.toString();
    } else {
      mmm = mm.toString();
    }

    int yy = picker.year;
    setState(() {
      _dateController.text = '$ddd-$mmm-$yy';
    });
  }

  _showStartTimePicker(String type, String type1) async {
    var picker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    setState(() {
      if (type == 'start') {
        start_hour = picker.hour;
        _starttimeController.text = _addLeadingZeroIfNeeded(picker.hour) +
            ':' +
            _addLeadingZeroIfNeeded(picker.minute);
        if (type1 == 'edit') {
          if (_endtimeController.text != '') {
            var parts = _endtimeController.text.split(':');
            int etime = int.parse(parts[0]);
            if (start_hour > etime) {
              _endtimeController.text = '';
            }
          }
        } else {
          if (start_hour > end_hour) {
            _endtimeController.text = '';
          }
        }
      } else {
        end_hour = picker.hour;
        if (end_hour > start_hour) {
          _endtimeController.text = _addLeadingZeroIfNeeded(picker.hour) +
              ':' +
              _addLeadingZeroIfNeeded(picker.minute);
        } else {
          _endtimeController.text = '';
          Toast.show("End time must be greater than start time!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
    });
  }

  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10) return '0$value';
    return value.toString();
  }
}

class _ServiceDialog extends StatefulWidget {
  _ServiceDialog({
    this.serviceData,
    this.serviceSelectedData,
    this.selectedService,
    this.selectedServiceId,
    this.onSelectedCitiesListChanged,
    this.onSelectedTaxIdListChanged,
    this.onSelectedTaxListChanged,
  });

  List<Service> serviceData = new List<Service>();
  List<Service> serviceSelectedData = new List<Service>();
  final List<String> selectedService;
  final List<String> selectedServiceId;
  final ValueChanged<List<String>> onSelectedCitiesListChanged;
  final ValueChanged<List<String>> onSelectedTaxIdListChanged;
  final ValueChanged<List<Service>> onSelectedTaxListChanged;

  @override
  _ServiceDialogState createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  List<String> _tempSelectedService = [];
  List<String> _tempSelectedId = [];
  List<Service> _serviceSelectedData = new List<Service>();

  @override
  void initState() {
    _tempSelectedService = widget.selectedService;
    _tempSelectedId = widget.selectedServiceId;
    _serviceSelectedData = widget.serviceSelectedData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
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
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.close,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Select service',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.serviceData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityName = widget.serviceData[index];
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            cityName.name,
                            style: Theme.of(context).textTheme.subtitle1.apply(),
                          ),
                        ),
                        onTap: () {
                          _serviceSelectedData.clear();
                          _tempSelectedService.clear();
                          _tempSelectedId.clear();

                          Service staff = new Service(
                              '', '', '', '', '', '', '', '', '', '', '');
                          staff.id = cityName.id;
                          staff.name = cityName.name;
                          _serviceSelectedData.add(staff);

                          _tempSelectedService.add(cityName.name);
                          _tempSelectedId.add(cityName.id);

                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedCitiesListChanged(
                                _tempSelectedService);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget
                                .onSelectedTaxListChanged(_serviceSelectedData);
                          });
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
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
  _StaffDialogState createState() => _StaffDialogState();
}

class _StaffDialogState extends State<_StaffDialog> {
  List<String> _tempSelectedService = [];
  List<String> _tempSelectedId = [];
  List<StaffList> _staffSelectedData = new List<StaffList>();

  @override
  void initState() {
    _tempSelectedService = widget.selectedStaff;
    _tempSelectedId = widget.selectedStaffId;
    _staffSelectedData = widget.staffSelectedData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
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
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.close,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Select staff',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.staffData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityName = widget.staffData[index];
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            cityName.staff_name,
                            style: Theme.of(context).textTheme.bodyText2.apply(),
                          ),
                        ),
                        onTap: () {
                          _staffSelectedData.clear();
                          _tempSelectedService.clear();
                          _tempSelectedId.clear();

                          StaffList staff =
                              new StaffList('', 0, '', '', '', '', [], []);
                          staff.id = cityName.id;
                          staff.staff_name = cityName.staff_name;
                          _staffSelectedData.add(staff);

                          _tempSelectedService.add(cityName.staff_name);
                          _tempSelectedId.add(cityName.id);

                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedCitiesListChanged(
                                _tempSelectedService);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget.onSelectedTaxListChanged(_staffSelectedData);
                          });
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
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
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Select service staff',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.staffData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityName = widget.staffData[index];
                      return InkWell(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            cityName.staff_name,
                            style: Theme.of(context).textTheme.bodyText2.apply(),
                          ),
                        ),
                        onTap: () {
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
                            widget.onSelectedCitiesListChanged(
                                _tempSelectedService);
                            widget.onSelectedTaxIdListChanged(_tempSelectedId);
                            widget.onSelectedTaxListChanged(_staffSelectedData);
                          });
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDialog extends StatefulWidget {
  _BookingDialog({
    this.bookingData,
    this.bookingSelectedName,
    this.bookingSelectedBookingId,
    this.selectedBookingCountryCode,
    this.selectedBookingContact,
    this.selectedBookingEmail,
    this.selectedBookingServiceId,
    this.selectedBookingDate,
    this.selectedBookingStartTime,
    this.selectedBookingEndTime,
    this.selectedBookingStaffId,
    this.selectedBookingNotes,
    this.onSelectedNameListChanged,
    this.onSelectedBookingIdListChanged,
    this.onSelectedBookingCountryCodeListChanged,
    this.onSelectedBookingContactListChanged,
    this.onSelectedBookingEmailListChanged,
    this.onSelectedBookingServiceIdListChanged,
    this.onSelectedBookingDateListChanged,
    this.onSelectedBookingStartTimeListChanged,
    this.onSelectedBookingEndTimeListChanged,
    this.onSelectedBookingStaffIdListChanged,
    this.onSelectedBookingNotesListChanged,
  });

  List<Booking> bookingData = new List<Booking>();
  List<String> bookingSelectedName = [];
  List<String> bookingSelectedBookingId = [];
  List<String> selectedBookingCountryCode = [];
  List<String> selectedBookingContact = [];
  List<String> selectedBookingEmail = [];
  List<String> selectedBookingServiceId = [];
  List<String> selectedBookingDate = [];
  List<String> selectedBookingStartTime = [];
  List<String> selectedBookingEndTime = [];
  List<String> selectedBookingStaffId = [];
  List<String> selectedBookingNotes = [];

  final ValueChanged<List<String>> onSelectedNameListChanged;
  final ValueChanged<List<String>> onSelectedBookingIdListChanged;
  final ValueChanged<List<String>> onSelectedBookingCountryCodeListChanged;
  final ValueChanged<List<String>> onSelectedBookingContactListChanged;
  final ValueChanged<List<String>> onSelectedBookingEmailListChanged;
  final ValueChanged<List<String>> onSelectedBookingServiceIdListChanged;
  final ValueChanged<List<String>> onSelectedBookingDateListChanged;
  final ValueChanged<List<String>> onSelectedBookingStartTimeListChanged;
  final ValueChanged<List<String>> onSelectedBookingEndTimeListChanged;
  final ValueChanged<List<String>> onSelectedBookingStaffIdListChanged;
  final ValueChanged<List<String>> onSelectedBookingNotesListChanged;

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  List<String> _tempSelectedBookingName = [];
  List<String> _tempSelectedBookingId = [];
  List<String> _tempSelectedBookingCountryCode = [];
  List<String> _tempSelectedBookingContact = [];
  List<String> _tempSelectedBookingEmail = [];
  List<String> _tempSelectedBookingServiceId = [];
  List<String> _tempSelectedBookingDate = [];
  List<String> _tempSelectedBookingStartTime = [];
  List<String> _tempSelectedBookingEndTime = [];
  List<String> _tempSelectedBookingStaffId = [];
  List<String> _tempSelectedBookingNotes = [];

  @override
  void initState() {
    _tempSelectedBookingName = widget.bookingSelectedName;
    _tempSelectedBookingId = widget.bookingSelectedBookingId;
    _tempSelectedBookingCountryCode = widget.selectedBookingCountryCode;
    _tempSelectedBookingContact = widget.selectedBookingContact;
    _tempSelectedBookingEmail = widget.selectedBookingEmail;
    _tempSelectedBookingServiceId = widget.selectedBookingServiceId;
    _tempSelectedBookingDate = widget.selectedBookingDate;
    _tempSelectedBookingStartTime = widget.selectedBookingStartTime;
    _tempSelectedBookingEndTime = widget.selectedBookingEndTime;
    _tempSelectedBookingStaffId = widget.selectedBookingStaffId;
    _tempSelectedBookingNotes = widget.selectedBookingNotes;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 10, right: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.close,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Booking List',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(height: 1),
                    itemCount: widget.bookingData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityName = widget.bookingData[index];
                      return InkWell(
                        child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  cityName.name,
                                  style: Theme.of(context).textTheme.bodyText2.apply(),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Date : ' + cityName.booking_date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .apply(color: Color(0xFFACACAC)),
                                      ),
                                      Text(
                                        '  Time : ' +
                                            cityName.booking_start_time +
                                            ' To ' +
                                            cityName.booking_end_time,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .apply(color: Color(0xFFACACAC)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                        onTap: () {
                          _tempSelectedBookingName.clear();
                          _tempSelectedBookingId.clear();
                          _tempSelectedBookingCountryCode.clear();
                          _tempSelectedBookingContact.clear();
                          _tempSelectedBookingEmail.clear();
                          _tempSelectedBookingServiceId.clear();
                          _tempSelectedBookingDate.clear();
                          _tempSelectedBookingStartTime.clear();
                          _tempSelectedBookingEndTime.clear();
                          _tempSelectedBookingStaffId.clear();
                          _tempSelectedBookingNotes.clear();

                          _tempSelectedBookingId.add(cityName.booking_id);
                          _tempSelectedBookingName.add(cityName.name);
                          _tempSelectedBookingCountryCode
                              .add(cityName.country_code);
                          _tempSelectedBookingContact.add(cityName.contact);
                          _tempSelectedBookingEmail.add(cityName.email);
                          _tempSelectedBookingServiceId
                              .add(cityName.service_id);
                          _tempSelectedBookingDate.add(cityName.booking_date);
                          _tempSelectedBookingStartTime
                              .add(cityName.booking_start_time);
                          _tempSelectedBookingEndTime
                              .add(cityName.booking_end_time);
                          _tempSelectedBookingStaffId.add(cityName.staff_id);
                          _tempSelectedBookingNotes.add(cityName.booking_notes);

                          Navigator.of(context).pop();
                          setState(() {
                            widget.onSelectedBookingIdListChanged(
                                _tempSelectedBookingId);
                            widget.onSelectedNameListChanged(
                                _tempSelectedBookingName);
                            widget.onSelectedBookingCountryCodeListChanged(
                                _tempSelectedBookingCountryCode);
                            widget.onSelectedBookingContactListChanged(
                                _tempSelectedBookingContact);
                            widget.onSelectedBookingEmailListChanged(
                                _tempSelectedBookingEmail);
                            widget.onSelectedBookingServiceIdListChanged(
                                _tempSelectedBookingServiceId);
                            widget.onSelectedBookingDateListChanged(
                                _tempSelectedBookingDate);
                            widget.onSelectedBookingStartTimeListChanged(
                                _tempSelectedBookingStartTime);
                            widget.onSelectedBookingEndTimeListChanged(
                                _tempSelectedBookingEndTime);
                            widget.onSelectedBookingStaffIdListChanged(
                                _tempSelectedBookingStaffId);
                            widget.onSelectedBookingNotesListChanged(
                                _tempSelectedBookingNotes);
                          });
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
