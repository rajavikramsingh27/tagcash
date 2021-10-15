import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/apps/scratchcards/scratchcard_userlist_screen.dart';
import 'package:tagcash/apps/scratchcards/scratchcard_list_merchant_page.dart';
import 'package:tagcash/apps/scratchcards/scratchcards_wonlist_screen.dart';

class ScratchcardsListScreen extends StatefulWidget {
  ScratchcardsListState createState() => ScratchcardsListState();
}

class ScratchcardsListState extends State<ScratchcardsListScreen> {
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppTopBar(
              appBar: AppBar(
                  bottom:
                      (Provider.of<PerspectiveProvider>(context, listen: false)
                                  .getActivePerspective() ==
                              'user')
                          ? TabBar(
                              tabs: [
                                Tab(
                                  text: "SCRATCHCARDS",
                                ),
                                Tab(
                                  text: "WON",
                                ),
                              ],
                            )
                          : null),
              title: getTranslated(context, "scratch_cards"),
            ),
            body: (Provider.of<PerspectiveProvider>(context, listen: false)
                        .getActivePerspective() ==
                    'user')
                ? TabBarView(children: [
                    ScratchcardUserListScreen(),
                    ScratchcardsWonListScreen()
                  ])
                : ScratchcardsListMerchantScreen()));
  }
}
