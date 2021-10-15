import 'package:flutter/material.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/utils/validator.dart';

import 'models/search_data.dart';
import 'models/merchant_search_data.dart';

class AddClaimUserScreen extends StatefulWidget {
  AddClaimUserPage createState() => AddClaimUserPage();
}

class AddClaimUserPage extends State<AddClaimUserScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Future<List<SearchData>> searchData;

  TextEditingController searchTxt = TextEditingController();
  bool isEnabled = false;

  int _radioValue;
  int tappedIndex;
  bool merchantSeachBo = false;
  bool isLoading = false;
  // String serchHintText;
  var searchUserId;

  void initState() {
    // serchHintText = getTranslated(context, "expnese_search_hint");
    tappedIndex = -1;
    _radioValue = 0;
    merchantSeachBo = false;
    super.initState();
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
      isEnabled = false;
      tappedIndex = -1;
      searchData = Future.delayed(
        Duration(seconds: 0),
        () => List<SearchData>(),
      );

      switch (_radioValue) {
        case 0:
          setState(() {
            merchantSeachBo = false;
          });

          //  serchHintText = getTranslated(context, "expnese_search_hint");
          break;
        case 1:
          setState(() {
            merchantSeachBo = true;
          });

          //  serchHintText = getTranslated(context, "expenses_search_id");
          break;
      }
    });
  }

  void onSearchSubmitted(String value) {
    onSearchTextChanged();
  }

  void onSearchTextChanged() {
    if (searchTxt.text == '') {
      return;
    }
    searchData = Future.delayed(
      Duration(seconds: 0),
      () => List<SearchData>(),
    );

    var apiBodyObj = {};

    if (merchantSeachBo) {
      if (Validator.isNumber(searchTxt.text)) {
        apiBodyObj['name'] = searchTxt.text;
        searchData = getSearchList(apiBodyObj);
      }
    } else {
      if (Validator.isEmail(searchTxt.text)) {
        apiBodyObj['email'] = searchTxt.text;
      } else if (Validator.isNumber(searchTxt.text)) {
        apiBodyObj['id'] = searchTxt.text;
      } else {
        apiBodyObj['name'] = searchTxt.text;
      }
      searchData = getSearchList(apiBodyObj);
    }
  }

  Future<List<SearchData>> getSearchList(apiBodyObj) async {
    setState(() {
      isEnabled = false;
      isLoading = true;
    });
    String apiUrl = '';

    if (merchantSeachBo) {
      apiUrl = 'community/searchNew';
    } else {
      apiUrl = 'user/searchuser';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      List responseList = response['result'];
      List<SearchData> getData = responseList.map<SearchData>((json) {
        return SearchData.fromJson(json);
      }).toList();

      return getData;
    } else {
      var msg = getTranslated(context, "expense_no_data_fount");
      showMessage(msg);
    }
    return [];
  }

  addClaimUserFunction() async {
    Map<String, String> apiBodyObj = {};
    if (merchantSeachBo == true) {
      apiBodyObj['user_id'] = searchUserId;
      apiBodyObj['user_type'] = "merchant";
    } else {
      apiBodyObj['user_id'] = searchUserId;
      apiBodyObj['user_type'] = "user";
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/AddClaimUser', apiBodyObj);

    if (response["status"] == "success") {
      Navigator.pop(context, true);
    } else {
      if (response['error'] == 'already_added') {
        var msg = getTranslated(context, "expense_already_add_group");
        showMessage(msg);
      } else if (response['error'] == 'not_verified') {
        var msg = getTranslated(context, "expense_verify_group");
        showMessage(msg);
      }
    }
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "add"),
      ),
      body: Column(
        key: _formKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(getTranslated(context, "expense_user")),
                  leading: Radio(
                    groupValue: _radioValue,
                    value: 0,
                    onChanged: _handleRadioValueChange,
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(getTranslated(context, "expense_group")),
                  leading: Radio(
                    groupValue: _radioValue,
                    value: 1,
                    onChanged: _handleRadioValueChange,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: TextField(
              controller: searchTxt,
              textInputAction: TextInputAction.search,
              onSubmitted: onSearchSubmitted,
              decoration: InputDecoration(
                  hintText: merchantSeachBo
                      ? getTranslated(context, "expense_search_id")
                      : getTranslated(context, "expnese_search_hint"),
                  suffixIcon: IconButton(
                    onPressed: () => onSearchTextChanged(),
                    icon: Icon(Icons.search),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  )),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: searchData,
              builder: (BuildContext context,
                  AsyncSnapshot<List<SearchData>> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? ListView.builder(
                        padding: EdgeInsets.all(kDefaultPadding),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: tappedIndex == index
                                ? Colors.grey[200]
                                : Theme.of(context).cardColor,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(merchantSeachBo
                                    ? AppConstants.getCommunityImagePath() +
                                        snapshot.data[index].id
                                    : AppConstants.getUserImagePath() +
                                        snapshot.data[index].id.toString() +
                                        "?kycImage=0"),
                              ),
                              title: Text(snapshot.data[index].name),
                              onTap: () {
                                setState(() {
                                  searchUserId = snapshot.data[index].id;
                                  tappedIndex = index;
                                  isEnabled = true;
                                });
                              },
                            ),
                          );
                        },
                      )
                    : SizedBox();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: ElevatedButton(
              child: Text(getTranslated(context, "add")),
              onPressed: isEnabled ? () => addClaimUserFunction() : null,
            ),
          ),
        ],
      ),
    );
  }
}
