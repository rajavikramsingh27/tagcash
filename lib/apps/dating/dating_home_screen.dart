import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/dating/dating_settings_screen.dart';
import 'package:tagcash/apps/dating/browse_matches_screen.dart';
import 'package:tagcash/apps/dating/inbox_outbox_screen.dart';
import 'package:tagcash/apps/dating/dating_search_home_screen.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


class DatingHomeScreen extends StatefulWidget {
  @override
  _DatingHomeScreen createState() => _DatingHomeScreen();
}

class _DatingHomeScreen extends State<DatingHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  int _selectedIndex = 0;
  String appbarTitle = "";
  static const TextStyle optionStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      changeAppBarTitle(_selectedIndex);
    });
  }

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      DatingSearchHomeScreen(scaffoldKey: _scaffoldKey),
      DatingBrowseMatchesScreen(scaffoldKey: _scaffoldKey),
      DatingInboxOutboxScreen(),
      DatingSettingsScreen(scaffoldKey: _scaffoldKey),
    ];
    fetchProfileDetails();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   appbarTitle=getTranslated(context, "dating_title");
  }
  void changeAppBarTitle(int index) {
    switch (index) {
      case 0:
        appbarTitle = getTranslated(context, "dating_title");
        break;
      case 1:
        appbarTitle = getTranslated(context, "dating_like");
        break;
      case 2:
        appbarTitle =  getTranslated(context, "dating_messages");
        break;
      case 3:
        appbarTitle = getTranslated(context, "dating_settings");
        break;
    }
  }

  void fetchProfileDetails() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetMyProfileDetails', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response == null) {
      showSnackbarMessage(getTranslated(context, "dating_server_noresponse"));
    } else {
      if (response['status'] == 'success') {
        _selectedIndex = 0;
      } else if (response['error'] == 'failed_to_get_data') {
        _selectedIndex = 3;
      }
    }
  }

  void showSnackbarMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(message),
      backgroundColor: Colors.red[600],
      duration: new Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget bottombarSection = BottomNavigationBar(
      showSelectedLabels: false,
      // <-- HERE
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items:  <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            label: getTranslated(context, "dating_search")),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: getTranslated(context, "dating_browse")),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.mail,
              size: 30,
            ),
            label:getTranslated(context,"dating_messages")),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 30,
            ),
            label: getTranslated(context, "dating_settings")),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.red[600],

      onTap: _onItemTapped,
    );
    List<Widget> buildActions() {

        return <Widget>[


          IconButton(
            icon: Icon(
              Icons.home_outlined,
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (Route<dynamic> route) => false);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.qr_code_outlined,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/scan');
            },
          ),
        ];


    }
    return Scaffold(
      key: _scaffoldKey,

        appBar: AppBar(
          backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
              'user'
              ? Colors.black
              : Color(0xFFe44933),

          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: ()
            {
              setState(() {
                if(_selectedIndex!=0) {
                  changeAppBarTitle(0);
                  _selectedIndex = 0;
                }
                else{
                  Navigator.pop(context);
                }
              });
            },
          ),
            title:Text(
            appbarTitle,
              style: TextStyle(fontSize: 16),
              textScaleFactor: 1,
            ),
          actions: buildActions(),
        ),


      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          isLoading ? Container(child: Center(child: Loading())) : SizedBox(),
        ],
      ),
      bottomNavigationBar: bottombarSection,
    );
  }
}
