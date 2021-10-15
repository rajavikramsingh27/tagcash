import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/module.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';

class HomeModuleScreen extends StatefulWidget {
  const HomeModuleScreen({Key key}) : super(key: key);

  @override
  _HomeModuleScreenState createState() => _HomeModuleScreenState();
}

class _HomeModuleScreenState extends State<HomeModuleScreen> {
  String moduleId;
  String moduleSubData;

  @override
  void initState() {
    super.initState();

    moduleDetailsProcess();
  }

  moduleDetailsProcess() {
    String moduleString = AppConstants.siteOwner;
    List moduleDat = moduleString.split('/');
    if (moduleDat.length != 0) {
      moduleId = moduleDat[0];
      if (moduleDat.length > 1) {
        moduleSubData = moduleDat[1];
      }
      getModuleDetails();
    } else {
      showInvalidUserError();
    }
  }

  void getModuleDetails() async {
    Map<String, String> apiBodyObj = {};

    // beta
    // apiBodyObj['id'] = moduleId;
    // Map<String, dynamic> response =
    //     await NetworkHelper.request('DynamicModules/ModuleById', apiBodyObj);

    apiBodyObj['module_id'] = moduleId;
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/ModuleList', apiBodyObj);

    if (response['status'] == 'success') {
      if (response['list'] != null) {
        Map responseMap = response['list'][0];

        Module moduleData = Module.fromJson(responseMap);
        ModuleHandler.load(context, moduleData);
      } else {
        showInvalidUserError();
      }
    }
  }

  modulePermissionCheck(Map responseMap) {
    bool loadModule = true;
    if (!responseMap.containsKey('id')) {
      loadModule = false;
    }
    // if (responseMap['stages'] != 'published') {
    //   loadModule = false;
    // }
    if (responseMap['access_module'] != 'public') {
      loadModule = false;
    }

    if (Provider.of<PerspectiveProvider>(context, listen: false)
                .getActivePerspective() ==
            'user' &&
        responseMap['access_visible'] == '2') {
      loadModule = false;
    }
    if (Provider.of<PerspectiveProvider>(context, listen: false)
                .getActivePerspective() ==
            'community' &&
        responseMap['access_visible'] == '1') {
      loadModule = false;
    }

    //   "owner_id": "0",
    // "owner_type": "1",
    //  "geo_country_id": "174",
    // "geo_latitude": null,
    // "geo_Longitude": null,
    // "geo_radius": null,
    // "access_module_role": "0",

    if (loadModule) {
      Module moduleData = Module.fromJson(responseMap);
      ModuleHandler.load(context, moduleData);
    } else {
      showInvalidUserError();
    }
  }

  void showInvalidUserError() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'invalid_mini_program')),
            content:
                Text(getTranslated(context, 'invalid_mini_program_message')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppConstants.siteOwner = '';
                  AppConstants.appHomeMode = 'normal';

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (Route<dynamic> route) => false);
                },
                child: Text(getTranslated(context, 'ok')),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: Center(child: Loading()),
    );
  }
}
