import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/manage_module/create_module_screen.dart';
import 'package:tagcash/apps/manage_module/details_module_screen.dart';
import 'package:tagcash/apps/manage_module/details_module_beta_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'package:tagcash/constants.dart';
import 'models/my_module.dart';

class ManageModuleScreen extends StatefulWidget {
  @override
  _ManageModuleScreenState createState() => _ManageModuleScreenState();
}

class _ManageModuleScreenState extends State<ManageModuleScreen> {
  StreamController<List<MyModule>> _streamcontroller;
  List<MyModule> _modules;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _modules = <MyModule>[];
    _streamcontroller = StreamController<List<MyModule>>.broadcast();

    myModulesListLoad();
  }

  void myModulesListLoad({bool clearCachedData = false}) {
    if (clearCachedData) {
      _modules = <MyModule>[];
      _streamcontroller.add(null);

      // hasMore = true;
    }

    _isLoading = true;

    getModulesList().then((res) {
      _isLoading = false;
      if (res.length != 0) {
        _modules.addAll(res);
      }
      // hasMore = (res.length == 20);

      _streamcontroller.add(_modules);
    });
  }

  Future<List<MyModule>> getModulesList([String searchKey]) async {
    Map<String, String> apiBodyObj = {};
    // if (searchKey != null && searchKey.length != 0) {
    //   apiBodyObj['search'] = searchKey;
    // }
    String apiUrl;
    if (AppConstants.getServer() == 'beta') {
      apiUrl = 'DynamicModules/ModuleByDeveloper';
    } else {
      apiUrl = 'DynamicModules/ModuleByOwner';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    List<MyModule> getData = <MyModule>[];
    List responseList = response['list'];

    if (responseList != null) {
      getData = responseList.map<MyModule>((json) {
        return MyModule.fromJson(json);
      }).toList();
    }

    return getData;
  }

  moduleClicked(MyModule moduleData) async {
    if (AppConstants.getServer() == 'beta') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailsModuleBetaScreen(moduleId: moduleData.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsModuleScreen(moduleId: moduleData.id),
        ),
      ).then((value) {
        if (value != null) {
          myModulesListLoad(clearCachedData: true);
        }
      });
    }
  }

  moduleCreateClicked() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateModuleScreen(),
      ),
    );

    myModulesListLoad(clearCachedData: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'My Mini Programs',
      ),
      floatingActionButton: AppConstants.getServer() == 'live'
          ? FloatingActionButton(
              onPressed: () => moduleCreateClicked(),
              child: Icon(Icons.add),
            )
          : SizedBox(),
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<MyModule>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          if (!snapshot.hasData) {
            return Center(child: Loading());
          } else {
            return ListView.separated(
              physics: AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                MyModule moduleData = snapshot.data[index];
                return ListTile(
                  title: Text(moduleData.moduleName),
                  subtitle: Text(moduleData.moduleType),
                  leading: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      image: snapshot.data[index].icon != ''
                          ? DecorationImage(
                              image: NetworkImage(snapshot.data[index].icon),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onTap: () => moduleClicked(moduleData),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                );
              },
            );
          }
        },
      ),
    );
  }
}
