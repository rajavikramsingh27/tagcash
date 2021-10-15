import 'dart:async';
import 'dart:ui';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/advertising/ad_video_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String type, gameId, winComb;

  const CustomDialogBox({Key key, this.type, this.gameId, this.winComb})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  List<Item> itemList = List();
  List<Item> winList;
  List<Item> selectedList;
  bool isLoading = false;
  bool loseMode = false;
  bool gameCompleteBo = false;
  bool playModeBo = false;
  bool winModeBo = false;
  bool cardTypePublic = false;
  bool selectMode = false;
  bool showAdDisplay = false;
  bool imageAdShow = false;
  int gridCol;
  String winComb = "";
  String adUrl;
  String adType;
  var gameId;
  var maxCardSelect;
  var winCombinationId;
  Timer _timer;
  int _start = 10;
  @override
  void initState() {
    gameCompleteBo = false;
    winModeBo = false;
    gameId = widget.gameId;
    if (widget.type != "") {
      if (widget.type == "public") {
        playModeBo = true;
        cardTypePublic = true;
      } else {
        selectMode = true;
        cardTypePublic = false;
      }
    } else {
      selectMode = true;
      cardTypePublic = false;
    }
    if (widget.winComb != "null") {
      winComb = widget.winComb;
    } else {
      winComb = "";
    }
    generateWinCombination();
    // loadList();
    super.initState();
  }

  List returnMovies = [];
  generateWinCombination() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['game_id'] = gameId.toString();
    if (winComb != "") {
      apiBodyObj['win_combination_id'] = winComb;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await NetworkHelper.request(
        'scratchCard/generateWinCombination', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      gridCol = response['result']['list']['no_rows'];
      winCombinationId = response['result']['list']['id'];
      maxCardSelect = response['result']['list']['no_clicks_per_attempt'];

      if (response['result']['list']['pay_for_ad'] == "yes") {
        if (response['result']['list']['ad_image'] != null) {
          imageAdShow = true;
          adUrl = response['result']['list']['ad_image'];
          showAdDisplay = true;
          startShowingAd();
        } else {
          if (response['result']['ad_details'] != null) {
            adFromModule(response['result']['ad_details']);
          }
        }
      } else {
        if (response['result']['ad_details'] != null) {
          adFromModule(response['result']['ad_details']);
        }
      }
      initializeGrid(gridCol);
    } else {
      var error = response["error"];

      var message;

      if (error == "player_has_already_won_game") {
        message = getTranslated(context, "scratchcard_already_played_msg");
        Navigator.pop(context, message);
      } else if (error == "24_hour_limit_exceeded") {
        message = getTranslated(context, "scratchcard_already_played_msg");
        Navigator.pop(context, message);
      } else if (error == "no_attempt_cannot_exceed_allowed_attempts") {
        message = getTranslated(context, "scratchcard_already_played_msg");
        Navigator.pop(context, message);
      } else if (error == "insufficient_balance") {
        message = getTranslated(context, "scratchcard_less_balace");

        Navigator.pop(context, message);
      } else if (error == "kyc_verification_needed") {
        message = getTranslated(context, "scratchcard_kyc_verification_msg");

        Navigator.pop(context, message);
      } else {
        message = error;
        Navigator.pop(context, message);
      }

      // showMessage('Unable to create scratchcard');
    }
  }

  adFromModule(adDetails) {
    if (adDetails['video_url'] != "") {
      adUrl = adDetails['video_url'];
      adType = 'video';
      showAdDisplay = true;
    } else if (adDetails['image_name'] != "") {
      imageAdShow = true;
      adType = 'image';
      adUrl = adDetails['image_name'];
      startShowingAd();
      showAdDisplay = true;
    }
  }

  startShowingAd() {
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            setState(() {
              showAdDisplay = false;
            });
          });
        } else {
          setState(() {
            // print(_start.toString());
            _start--;
          });
        }
      },
    );
  }

  List gridData;
  initializeGrid(gridNumber) {
    itemList = List();
    selectedList = List();
    if (gridNumber == 3) {}

    for (var i = 0; i < gridNumber; i++) {
      for (var j = 0; j < gridNumber; j++) {
        var pos = i.toString() + "_" + j.toString();
        var checked = false;
        var correct = false;
        itemList.add(Item(pos, checked, correct));
      }
    }
  }

  submitAttempts() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['game_id'] = gameId.toString();
    apiBodyObj['win_combination_id'] = winCombinationId.toString();
    var playerClicksStr = "";
    returnMovies.forEach((posItem) {
      if (playerClicksStr.length == 0) {
        playerClicksStr = posItem;
      } else {
        playerClicksStr = playerClicksStr + "," + posItem;
      }
    });
    apiBodyObj['player_clicks'] = playerClicksStr.toString();
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('scratchCard/SavePlayerClicks', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      if (response['result']['message'] ==
          "player_won_game_win_amount_transferred_to_player") {
        winModeBo = true;
      } else {
        loseMode = true;
        displayWinOptions(response['result']['win_combination']);
      }
    } else {
      var error = response["error"];

      var message;

      if (error == "game_result_already_published") {
        message = getTranslated(context, "scratchcard_already_played_msg");
        Navigator.pop(context, message);
      } else {
        message = error;
        Navigator.pop(context, message);
      }
    }
  }

  displayWinOptions(winCombination) {
    itemList.forEach((item) {
      for (var i = 0; i < winCombination.length; i++) {
        final tile =
            itemList.firstWhere((item) => item.pos == winCombination[i]);
        tile.checked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return showAdDisplay
        ? Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              if (adType == 'video')
                AdVideoScreen(
                  video: adUrl,
                  onFinishPlaying: (value) {
                    //deleteLoanHandler();
                    setState(() {
                      showAdDisplay = false;
                    });
                  },
                ),
              if (adType == 'image')
                Stack(alignment: Alignment.bottomCenter, children: [
                  Center(
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.network(
                              adUrl,
                              height: 500.0,
                              //width: 48.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      //child: Center(
                      child: Text("$_start",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    padding: EdgeInsets.only(bottom: 20),
                  )
                ])
            ]))
        : Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(context),
          );
  }

  contentBox(context) {
    return itemList.isNotEmpty
        ? Stack(children: [
            Container(
              padding:
                  EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 16),
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 5),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(getTranslated(context, "scratch_card"),
                      style: Theme.of(context).textTheme.headline5.apply(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red[400])),
                  SizedBox(
                    height: 10,
                  ),
                  selectMode
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslated(context, "congratulation"),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              getTranslated(context, "scratchcard_recived_msg"),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              getTranslated(context, "scratch_play_msg"),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(
                                  getTranslated(context, "later"),
                                ),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                child: Text(getTranslated(context, "play")),
                                color: kPrimaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    selectMode = false;
                                    playModeBo = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      : winModeBo
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 20),
                                Center(
                                  child: SizedBox(
                                    height: 120,
                                    child: Image.asset(
                                      'assets/images/winprize.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  getTranslated(context, "you_won_msg"),
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  getTranslated(
                                      context, "scratch_play_thanks_msg"),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                cardTypePublic
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          child: Text(
                                              getTranslated(context, "back")),
                                          color: kPrimaryColor,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context, "ok");
                                            });
                                          },
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          : Column(mainAxisSize: MainAxisSize.min, children: [
                              playModeBo
                                  ? Column(
                                      children: [
                                        Center(
                                            child: Text(
                                          getTranslated(
                                                  context, "scratch_rule_one") +
                                              maxCardSelect.toString() +
                                              getTranslated(
                                                  context, "scratch_rule_two"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          textAlign: TextAlign.center,
                                        )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              AbsorbPointer(
                                  absorbing: gameCompleteBo,
                                  child: Container(
                                      child: GridView.count(
                                    crossAxisCount: gridCol,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0,
                                    shrinkWrap: true,
                                    children: List.generate(gridCol * gridCol,
                                        (index) {
                                      return GridItem(
                                          item: itemList[index],
                                          checked: itemList[index].checked,
                                          isSelected: (bool value) {
                                            setState(() {
                                              if (value) {
                                                returnMovies
                                                    .add(itemList[index].pos);
                                              } else {
                                                returnMovies.remove(
                                                    itemList[index].pos);
                                              }
                                              if (returnMovies.length ==
                                                  maxCardSelect) {
                                                gameCompleteBo = true;
                                                playModeBo = false;
                                                submitAttempts();
                                              }
                                            });
                                          },
                                          key: Key(
                                              itemList[index].pos.toString()));
                                    }),
                                  ))),
                              loseMode
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          getTranslated(
                                              context, "scratch_lose_msg"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          getTranslated(
                                              context, "scratch_lose_msg_two"),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        cardTypePublic
                                            ? SizedBox(
                                                width: double.infinity,
                                                child: RaisedButton(
                                                  child: Text(getTranslated(
                                                      context, "back")),
                                                  color: kPrimaryColor,
                                                  textColor: Colors.white,
                                                  onPressed: () {
                                                    setState(() {
                                                      Navigator.pop(
                                                          context, "ok");
                                                    });
                                                  },
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    )
                                  : SizedBox(),
                            ]),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
          ])
        : isLoading
            ? Center(child: Loading())
            : SizedBox();
  }
}

class Item {
  String pos;
  bool checked;
  bool currect;

  Item(this.pos, this.checked, this.currect);
}

class GridItem extends StatefulWidget {
  final Key key;
  final Item item;
  final bool checked;
  final ValueChanged<bool> isSelected;

  GridItem({this.item, this.checked, this.isSelected, this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(() {
            isSelected = !isSelected;
            widget.isSelected(isSelected);
          });
        },
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black26,
                width: 2,
              ),
              // borderRadius: BorderRadius.circular(0),
            ),
            child: Card(
              color: isSelected ? kPrimaryColor : Colors.grey[300],
              shape: widget.checked
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(0),
                          topRight: Radius.circular(0)),
                      side: BorderSide(width: 3, color: Colors.green))
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                      child: isSelected
                          ? Align(
                              alignment: Alignment.center,
                              child: Text(
                                'TAG',
                                style: Theme.of(context).textTheme.headline6,
                              ))
                          : Center(
                              child: Text(
                              '?',
                              style: Theme.of(context).textTheme.headline6,
                            )))
                ],
              ),
            )));
  }
}
