import 'package:flutter/material.dart';
import 'package:tagcash/apps/helptutorial/tutorial_favourite_list_screen.dart';
import 'package:tagcash/apps/helptutorial/tutorial_user_list_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class TutorialUserHomeScreen extends StatefulWidget {
  const TutorialUserHomeScreen({Key key}) : super(key: key);

  @override
  _TutorialUserHomeScreenState createState() => _TutorialUserHomeScreenState();
}

class _TutorialUserHomeScreenState extends State<TutorialUserHomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Tab> tutorialTabs = <Tab>[];

  TabController _tabController;
  bool _isTemplate =
      false; //If ithere is input parametes chnage this value to true
  List<String> inputTutorialIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tutorialTabs.length);
    /*
    Please uncomment this part with input parameters for template
    inputTutorialIds .add("60e2d94550fa0987198b4567");
    inputTutorialIds .add("60e2db7350fa09f41a8b4567");
    String jsonInputTutorilsIds = jsonEncode( inputTutorialIds);
    print(jsonInputTutorilsIds);
    */
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isTemplate
        ? new Scaffold(
            appBar: AppTopBar(
              appBar: AppBar(),
              title: getTranslated(context, "tutorial_title"),
            ),
            body: TutorialUserListScreen(
              inputTutorialIds: inputTutorialIds,
            ))
        : Scaffold(
            body: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppTopBar(
                title: getTranslated(context, "tutorials_title"),
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(
                          text:
                              getTranslated(context, "tutorial_alltutorials")),
                      Tab(text: getTranslated(context, "tutorial_mytutorials")),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  TutorialUserListScreen(
                    inputTutorialIds: null,
                  ),
                  TutorialFavouritesListScreen(),
                ],
              ),
            ),
          ));
  }
}
