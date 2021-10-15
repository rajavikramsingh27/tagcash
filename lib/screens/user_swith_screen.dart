import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class UserSwithScreen extends StatefulWidget {
  @override
  _UserSwithScreenState createState() => _UserSwithScreenState();
}

class _UserSwithScreenState extends State<UserSwithScreen> {
  @override
  void initState() {
    super.initState();

    switchPerspective();
  }

  switchPerspective() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('perspective/switch/');

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      Provider.of<PerspectiveProvider>(context, listen: false)
          .setActivePerspective(responseMap['type']);

      goToHomePage();
    }
  }

  goToHomePage() {
    if (AppConstants.appHomeMode == 'whitelabel') {
      Navigator.pushNamedAndRemoveUntil(
          context, '/business', (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 56,
            color: Color(0xFFe44933),
          ),
          Expanded(child: Container(child: Center(child: Loading()))),
        ],
      ),
    );
  }
}
