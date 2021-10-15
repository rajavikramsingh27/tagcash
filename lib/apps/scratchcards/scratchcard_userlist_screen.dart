import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/scratchcards/scratch_play.dart';
import 'models/scratch_card_list.dart';

class ScratchcardUserListScreen extends StatefulWidget {
  ScratchcardUserListState createState() => ScratchcardUserListState();
}

class ScratchcardUserListState extends State<ScratchcardUserListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool rewardBo = false;
  Future<ScratchCardList> scratchCardCollectionList;
  TextEditingController searchKeyInput;

  final globalKey = GlobalKey<ScaffoldState>();

  void initState() {
    searchKeyInput = TextEditingController();
    searchKeyInput.text = '';
    scratchCardCollectionList = loadScratchCardList();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<ScratchCardList> loadScratchCardList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['location'] = 'no';
    if (searchKeyInput.text.length != 0) {
      apiBodyObj['search'] = searchKeyInput.text;
    }
    Map<String, dynamic> response =
        await NetworkHelper.request('scratchCard/ListScratchcards', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    Map responseLoanStatus = response['result']['list'];
    setState(() {
      isLoading = false;
    });
    ScratchCardList getData = ScratchCardList.fromJson(responseLoanStatus);
    return getData;
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
                controller: searchKeyInput,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blueAccent,
                ),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          scratchCardCollectionList = loadScratchCardList();
                        });
                      },
                    ),
                    hintText: getTranslated(context, "scratch_search"),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 32.0),
                        borderRadius: BorderRadius.circular(25.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white, width: 32.0),
                        borderRadius: BorderRadius.circular(25.0)))),
          ),
          Expanded(
            child: ListView(
              children: [
                FutureBuilder(
                  future: scratchCardCollectionList,
                  builder: (BuildContext context,
                      AsyncSnapshot<ScratchCardList> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 0),
                                      child: Text(
                                          getTranslated(
                                              context, "scratch_recived"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6)),
                                  if (snapshot.data.reward.length != 0) ...[
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.reward.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Card(
                                            child: GestureDetector(
                                              onTap: () {
                                                openScratchCard(snapshot
                                                    .data.reward[index]);
                                              },
                                              child: ListTile(
                                                leading: snapshot
                                                            .data
                                                            .reward[index]
                                                            .image !=
                                                        ""
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        child: Image.network(
                                                          snapshot
                                                              .data
                                                              .reward[index]
                                                              .image,
                                                          height: 48.0,
                                                          width: 48.0,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )
                                                    : Container(
                                                        height: 48.0,
                                                        width: 48.0,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .grey[400],
                                                            shape: BoxShape
                                                                .rectangle),
                                                      ),
                                                title: Text(
                                                  snapshot
                                                      .data.reward[index].name,
                                                ),
                                                subtitle: Column(
                                                  children: [
                                                    Text(
                                                      getTranslated(context,
                                                              "scratch_price") +
                                                          snapshot
                                                              .data
                                                              .reward[index]
                                                              .winningAmount
                                                              .toString() +
                                                          " " +
                                                          snapshot
                                                              .data
                                                              .reward[index]
                                                              .currencyCode
                                                              .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      getTranslated(context,
                                                              "scratch_price") +
                                                          snapshot
                                                              .data
                                                              .reward[index]
                                                              .noRows
                                                              .toString() +
                                                          "X" +
                                                          snapshot
                                                              .data
                                                              .reward[index]
                                                              .noRows
                                                              .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ],
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                  ] else ...[
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 0),
                                        child: Text(
                                            getTranslated(
                                                context, "scratch_not_recive"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1))
                                  ],
                                ])
                          : SizedBox();
                    } else {
                      return Center(child: Loading());
                    }
                  },
                ),
                FutureBuilder(
                  future: scratchCardCollectionList,
                  builder: (BuildContext context,
                      AsyncSnapshot<ScratchCardList> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 0),
                                      child: Text(
                                          getTranslated(
                                              context, "scratch_public"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6)),
                                  if (snapshot.data.public.length != 0) ...[
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.public.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Card(
                                            child: GestureDetector(
                                              onTap: () {
                                                openScratchCard(snapshot
                                                    .data.public[index]);
                                              },
                                              child: ListTile(
                                                leading: snapshot
                                                            .data
                                                            .public[index]
                                                            .image !=
                                                        ""
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        child: Image.network(
                                                          snapshot
                                                              .data
                                                              .public[index]
                                                              .image,
                                                          height: 48.0,
                                                          width: 48.0,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )
                                                    : Container(
                                                        height: 48.0,
                                                        width: 48.0,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .grey[400],
                                                            shape: BoxShape
                                                                .rectangle),
                                                      ),
                                                title: Text(
                                                  snapshot
                                                      .data.public[index].name,
                                                ),
                                                subtitle: Column(
                                                  children: [
                                                    Text(
                                                      getTranslated(context,
                                                              "scratch_price") +
                                                          snapshot
                                                              .data
                                                              .public[index]
                                                              .winningAmount
                                                              .toString() +
                                                          " " +
                                                          snapshot
                                                              .data
                                                              .public[index]
                                                              .currencyCode
                                                              .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      getTranslated(context,
                                                              "scratch_price") +
                                                          snapshot
                                                              .data
                                                              .public[index]
                                                              .noRows
                                                              .toString() +
                                                          "X" +
                                                          snapshot
                                                              .data
                                                              .public[index]
                                                              .noRows
                                                              .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1,
                                                    ),
                                                  ],
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                  ] else ...[
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 0, 0),
                                        child: Text(
                                            getTranslated(
                                                context, "scratch_not_found"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1))
                                  ],
                                ])
                          : SizedBox();
                    } else {
                      return Center(child: Loading());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  openScratchCard(data) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            type: "public",
            gameId: data.id.toString(),
            winComb: data.winCombinationId.toString(),
          );
        }).then((valueFromDialog) {
      if (valueFromDialog == "ok") {
        scratchCardCollectionList = loadScratchCardList();
      } else {
        showMessage(valueFromDialog);
        scratchCardCollectionList = loadScratchCardList();
      }
    });
  }
}
