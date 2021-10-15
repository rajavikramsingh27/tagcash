import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_create_screen.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_history_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_gifts_screen.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_history_screen.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_created_screen.dart';
import 'package:tagcash/providers/perspective_provider.dart';

class RedEnvelopesScreen extends StatefulWidget {
  @override
  RedEnvelopesScreenState createState() => RedEnvelopesScreenState();
}

class RedEnvelopesScreenState extends State<RedEnvelopesScreen> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

//Provider.of<PerspectiveProvider>(context).getActivePerspective() == 'user'
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppTopBar(
          appBar: Provider.of<PerspectiveProvider>(context).getActivePerspective() == 'user' ? AppBar(
              bottom: new TabBar(controller: controller, tabs: <Tab>[
            new Tab(text: getTranslated(context, "red_envelopes_gift")),
            new Tab(text: getTranslated(context, "red_envelopes_history")),
            new Tab(text: getTranslated(context, "red_envelopes_created"))
          ])):AppBar(),
          title: getTranslated(context, "red_envelopes"),
        ),
        body: Provider.of<PerspectiveProvider>(context).getActivePerspective() == 'user' ? 
        new TabBarView(controller: controller, children: <Widget>[
          new RedEnvelopeGiftsScreen(),
          new RedEnvelopeHistoryScreen(),
          new RedEnvelopeCreatedScreen()
        ]): RedEnvelopeCreatedScreen(),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RedEnvelopeCreateScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: getTranslated(context, "red_envelopes_create"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      );
  }
}