import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/app_category_menu.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog_animated.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/module.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class AppListScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const AppListScreen({Key key, this.onBackPressed}) : super(key: key);
  @override
  _AppListScreenState createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  StreamController<List<Module>> _streamcontroller;
  List<Module> _modules;

  Future<List<Module>> privateListData;

  bool favoritePossible = false;
  bool isLoading = false;

  String searchKey;

  int categorySelected = 0;

  @override
  void initState() {
    super.initState();

    _modules = <Module>[];
    _streamcontroller = StreamController<List<Module>>.broadcast();

    if (AppConstants.getServer() == 'live') {
      favoritePossible = true;
    }

    modulesListLoad(true);
    privateListData = appPrivateListLoad();
  }

  Future<List<Module>> appPrivateListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/PrivateModuleList');

    List<Module> getData = [];
    List responseList = response['list'];
    if (responseList != null) {
      getData = responseList.map<Module>((json) {
        return Module.fromJson(json);
      }).toList();
    }

    return getData;
  }

  searchClicked(String searchValue) {
    searchKey = searchValue.trim();
    modulesListLoad(true);
  }

  filterModules() {
    modulesListLoad(true);
  }

  void modulesListLoad(bool clearData) {
    if (clearData) {
      _modules = <Module>[];
      _streamcontroller.add(_modules);
      // hasMore = true;
    }

    setState(() {
      isLoading = true;
    });

    appModulesListLoad().then((res) {
      setState(() {
        isLoading = false;
      });
      if (res.length != 0) {
        _modules.addAll(res);
      }
      // hasMore = (res.length == 20);

      _streamcontroller.add(_modules);
    });
  }

  Future<List<Module>> appModulesListLoad() async {
    Map<String, String> apiBodyObj = {};

    if (searchKey != null && searchKey.isNotEmpty) {
      apiBodyObj['search_key'] = searchKey;
    }

    if (categorySelected != 0) {
      apiBodyObj['category_id'] = categorySelected.toString();
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/ModuleList', apiBodyObj);

    List<Module> getData = <Module>[];
    List responseList = response['list'];

    if (responseList != null) {
      getData = responseList.map<Module>((json) {
        return Module.fromJson(json);
      }).toList();
    }

    return getData;
  }

  showPopupMenu(Offset offset, Module moduleItem) async {
    final screenSize = MediaQuery.of(context).size;
    double rightOffset = 300;
    if (offset.dx > screenSize.width * .5) {
      rightOffset = -300;
    }

    final selection = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        rightOffset,
        offset.dy,
        // screenSize.width - (offset.dx + 310),
        // screenSize.height - offset.dy,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(moduleItem.favorite
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline),
              Text(getTranslated(context, 'favorites')),
            ],
          ),
          value: 'favorite',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(moduleItem.personal
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline),
              Text(Provider.of<PerspectiveProvider>(context, listen: false)
                          .getActivePerspective() ==
                      'user'
                  ? getTranslated(context, 'publicprogram')
                  : getTranslated(context, 'publicprogram_webapp')),
            ],
          ),
          value: 'personal',
        ),
      ],
      elevation: 8.0,
    );
    print(selection);
    if (selection == 'favorite') {
      toogleFavoritesClickHandler(moduleItem);
    } else if (selection == 'personal') {
      tooglePersonalClickHandler(moduleItem);
    }
  }

  toogleFavoritesClickHandler(Module moduleItem) async {
    setState(() {
      moduleItem.favorite = !moduleItem.favorite;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = moduleItem.id.toString();

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModulesFavorites/ToogleFavorites', apiBodyObj);

    if (response['status'] == 'success') {}
  }

  tooglePersonalClickHandler(Module moduleItem) async {
    if (Provider.of<PerspectiveProvider>(context, listen: false)
                .getActivePerspective() ==
            'user' &&
        Provider.of<UserProvider>(context, listen: false).userData.userName ==
            '') {
      showAnimatedDialog(context,
          title: getTranslated(context, 'error'),
          message:
              getTranslated(context, 'add_username_before_public_listing'));
      return;
    }

    setState(() {
      moduleItem.personal = !moduleItem.personal;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = moduleItem.id.toString();

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModulesPersonal/TooglePersonal', apiBodyObj);

    if (response['status'] == 'success') {}
  }

  onModuleClickHandler(Module moduleData) {
    ModuleHandler.load(context, moduleData);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.onBackPressed,
      child: Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'miniprogram'),
          onSearch: searchClicked,
        ),
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
            ? Colors.black
            : Color(0xFFE8E7E7),
        body: Stack(
          children: [
            Column(
              children: [
                FutureBuilder(
                  future: privateListData,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Module>> snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? Container(
                            height: snapshot.data.length != 0 ? 120 : 0,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            // color: Colors.amber,
                            child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              padding: EdgeInsets.only(left: kDefaultPadding),
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () => onModuleClickHandler(
                                      snapshot.data[index]),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 100,
                                    margin: EdgeInsets.only(right: 10),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    snapshot.data[index].icon),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          snapshot.data[index].name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : SizedBox();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: kDefaultPadding, right: kDefaultPadding, bottom: 4),
                  child: AppCategoryMenu(onCategoryChange: (value) {
                    categorySelected = value;
                    filterModules();
                  }),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _streamcontroller.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Module>> snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? GridView.builder(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 80),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 130.0,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: .9,
                              ),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () => onModuleClickHandler(
                                      snapshot.data[index]),
                                  onLongPressStart:
                                      (LongPressStartDetails details) {
                                    if (favoritePossible) {
                                      showPopupMenu(details.globalPosition,
                                          snapshot.data[index]);
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  // color: Colors.grey,
                                                  image: DecorationImage(
                                                    image: NetworkImage(snapshot
                                                        .data[index].icon),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              snapshot.data[index].favorite
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Icon(
                                                        Icons.check_circle,
                                                        size: 16,
                                                        color: Colors.green,
                                                      ))
                                                  : SizedBox(),
                                              snapshot.data[index].personal
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ))
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          snapshot.data[index].name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox();
                    },
                  ),
                ),
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
