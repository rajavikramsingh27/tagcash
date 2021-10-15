import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/models/template.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class TemplateScreen extends StatefulWidget {
  @override
  _TemplateScreenState createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  PageController _scrollController;
  double _scrollPosition;

  String index = '';
  String path = '';
  String layout = '';
  String tmp_name = '';
  String name = '';

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.page;
    });
  }

  List<Template> getData = new List<Template>();

  @override
  void initState() {
    // TODO: implement initState
    _scrollController = PageController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    getTemplate();
  }

  addStringToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_tmp_index', index);
    prefs.setString('config_tmp_path', path);
    prefs.setString('config_tmp_layout', layout);
    prefs.setString('config_tmp_name', name);
    prefs.setString('config_tmp_label', tmp_name);
  }

  void getTemplate() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/getTemplate');

    if (response['status'] == 'success') {
      List responseList = response['result'];

      getData = responseList.map<Template>((json) {
        return Template.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Choose Template'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
              ),
              onPressed: () {
                if (_scrollPosition == null || _scrollPosition == 0.0) {
                  index = '1';
                  path = getData[0].path;
                  layout = 'Tab2';
                  name = 'Page2';
                  tmp_name = 'Modern';
                } else if (_scrollPosition == 1.0) {
                  index = '2';
                  path = getData[1].path;
                  layout = 'Tab3';
                  name = 'Page3';
                  tmp_name = 'Contemporary';
                } else if (_scrollPosition == 2.0) {
                  index = '0';
                  path = getData[2].path;
                  layout = 'Tab1';
                  name = 'Page1';
                  tmp_name = 'Classic';
                }
                addStringToSF();
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            PageIndicatorContainer(
              child: PageView.builder(
                controller: _scrollController,
                itemBuilder: (context, position) {
                  return Container(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              image: DecorationImage(
                                image: NetworkImage(getData[position].path),
                                fit: BoxFit.fill,
                              ),
                            ),
                          )),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            getData[position].label,
                            style: TextStyle(
                              color: kUserBackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ));
                },
                scrollDirection: Axis.horizontal,
                itemCount: getData.length,
              ),
              align: IndicatorAlign.bottom,
              length: getData.length,
              indicatorColor: kUserBackColor,
              indicatorSelectorColor: kPrimaryColor,
              shape: IndicatorShape.circle(size: 8),
              indicatorSpace: 10.0,
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
