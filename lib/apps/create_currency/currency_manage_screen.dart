import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/create_currency/currency_details_screen.dart';
import 'package:tagcash/apps/create_currency/models/token.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/apps/create_currency/currency_report.dart';

class CurrencyManageScreen extends StatefulWidget {
  const CurrencyManageScreen({this.token});

  final Token token;

  @override
  CurrencyManageScreenState createState() => CurrencyManageScreenState();
}

class CurrencyManageScreenState extends State<CurrencyManageScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;

  Token _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    controller = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(
            bottom: new TabBar(controller: controller, tabs: <Tab>[
          new Tab(text: getTranslated(context, "details")),
          new Tab(text: getTranslated(context, "report"))
        ])),
        title: getTranslated(context, "create_currency_token_details"),
      ),
      body: new TabBarView(controller: controller, children: <Widget>[
        new CurrencyDetailsScreen(token: _token),
        new CurrencyReport(token: _token)
      ]),
    );
  }
}