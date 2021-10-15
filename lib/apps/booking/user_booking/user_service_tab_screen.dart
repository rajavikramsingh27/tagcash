import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/booking/components/custom_drop_down.dart';
import 'package:tagcash/apps/booking/models/all_service.dart';
import 'package:tagcash/apps/booking/models/user_service.dart';
import 'package:tagcash/apps/booking/user_booking/user_service_detail_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


import '../../../constants.dart';

class UserServiceTabScreen extends StatefulWidget {
  @override
  _UserServiceTabScreenState createState() => _UserServiceTabScreenState();
}

class _UserServiceTabScreenState extends State<UserServiceTabScreen> with SingleTickerProviderStateMixin  {

  TextEditingController _service_priceController = TextEditingController();

  List<UserService> getData = new List<UserService>();

  bool sync_google = false;

  bool isLoading = false;
  UserService selectedUser;

  List<AllService> _currency = AllService.getCurrency();
  List<CustomDropdownMenuItem<AllService>> _dropdownMenuItems;
  AllService _selectedCompany;
  List<UserService> searchData = [];

  @override
  void initState() {
    super.initState();
    getUserService('');

    List<CustomDropdownMenuItem<AllService>> buildDropdownMenuItems(List companies) {
      List<CustomDropdownMenuItem<AllService>> items = List();
      for (AllService company in companies) {
        items.add(
          CustomDropdownMenuItem(
            value: company,
            child: Text(company.name),
          ),
        );
      }
      return items;
    }

    _dropdownMenuItems = buildDropdownMenuItems(_currency);

    _selectedCompany = _dropdownMenuItems[0].value;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getUserService(String merchant_name) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['merchant_name'] = merchant_name;

    Map<String, dynamic> response =
    await NetworkHelper.request('BookingService/ServiceListUser', apiBodyObj);


    if (response['status'] == 'success') {
      List responseList = response['result'];

      getData = responseList.map<UserService>((json) {
        return UserService.fromJson(json);
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

  onSearchTextChanged(String text) async {
    searchData.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    getData.forEach((userDetail) {
      if (userDetail.owner_name.contains(text))
        searchData.add(userDetail);
    });

    print(searchData.length);
    setState(() {});
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
                        ],
                      )),

                  SizedBox(height: 10),
                  Container(
                    child: TextField(
                      controller: _service_priceController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 20),
                        hintText: "Search for business",
                        hintStyle: TextStyle(fontSize: 18.0, color: Color(0xFFACACAC)),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFACACAC),
                        ),
                      ),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                      onChanged: onSearchTextChanged,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: searchData.length != 0 || _service_priceController.text.isNotEmpty
                        ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchData.length,
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
                                          searchData[index].owner_id.toString() +
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
                                        searchData[index].owner_name,
                                        style: Theme.of(context).textTheme.subtitle2.apply(),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        searchData[index].owner_total_service.toString() + ' Services, '+ searchData[index].owner_total_staff.toString() + ' Staff',
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
                            FocusScope.of(context).unfocus();
                            _service_priceController.clear();
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => UserServiceDetailScreen(owner_id: searchData[index].owner_id, name: searchData[index].owner_name, service: searchData[index].owner_total_service.toString(), staff: searchData[index].owner_total_staff.toString())));
                          },
                        );
                      },
                    ):                    ListView.builder(
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
                                          getData[index].owner_id.toString() +
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
                                        getData[index].owner_name,
                                        style: Theme.of(context).textTheme.subtitle2.apply(),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        getData[index].owner_total_service.toString() + ' Services, '+ getData[index].owner_total_staff.toString() + ' Staff',
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
                            FocusScope.of(context).unfocus();
                            _service_priceController.clear();
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (context) => UserServiceDetailScreen(owner_id: getData[index].owner_id, name: getData[index].owner_name, service: getData[index].owner_total_service.toString(), staff: getData[index].owner_total_staff.toString())));
                          },
                        );
                      },
                    )
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}



