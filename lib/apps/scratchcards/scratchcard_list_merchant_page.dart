import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/scratchcards/scratchcard_create_page.dart';
import 'models/scratch_card.dart';

class ScratchcardsListMerchantScreen extends StatefulWidget {
  ScratchcardsListMerchant createState() => ScratchcardsListMerchant();
}

class ScratchcardsListMerchant extends State<ScratchcardsListMerchantScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  Future<List<ScratchCard>> scratchCardList;
  TextEditingController searchKeyInput;

  void initState() {
    searchKeyInput = TextEditingController();
    searchKeyInput.text = '';
    scratchCardList = loadScratchCardList();
    super.initState();
  }

  @override
  void dispose() {
    searchKeyInput.dispose();
    super.dispose();
  }

  Future<List<ScratchCard>> loadScratchCardList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    if (searchKeyInput.text.length != 0) {
      apiBodyObj['search'] = searchKeyInput.text;
    }
    Map<String, dynamic> response = await NetworkHelper.request(
        'scratchCard/ListMerchantScratchCards', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List<ScratchCard> getData = List<ScratchCard>();
    List responseList = response['result']['list'];

    if (responseList != null) {
      getData = responseList.map<ScratchCard>((json) {
        return ScratchCard.fromJson(json);
      }).toList();
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          listItemTapped(null);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
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
                          scratchCardList = loadScratchCardList();
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
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: scratchCardList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ScratchCard>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: GestureDetector(
                                onTap: () {
                                  listItemTapped(snapshot.data[index]);
                                },
                                child: ListTile(
                                  leading: snapshot.data[index].image != ""
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: Image.network(
                                            snapshot.data[index].image,
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
                                                  BorderRadius.circular(5),
                                              color: Colors.grey[400],
                                              shape: BoxShape.rectangle),
                                        ),
                                  title: Text(
                                    snapshot.data[index].name,
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Text(
                                        getTranslated(
                                                context, "scratch_price") +
                                            snapshot.data[index].winningAmount
                                                .toString() +
                                            " " +
                                            snapshot.data[index].currencyCode
                                                .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        snapshot.data[index].noRows.toString() +
                                            "X" +
                                            snapshot.data[index].noRows
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
                      : Center(child: Loading());
                },
              ),
              // isLoading ? Center(child: Loading()) : SizedBox(),
            ),
          )
        ],
      ),
    );
  }

  Future listItemTapped(ScratchCard scratchObj) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScratchcardCreatePage(scratchObj: scratchObj),
    ));
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text(getTranslated(context, "scratch_created_success"))));
          scratchCardList = loadScratchCardList();
        } else if (status == 'updateSuccess') {
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text(getTranslated(context, "scratch_created_updated"))));
          scratchCardList = loadScratchCardList();
        } else if (status == 'deleteSuccess') {
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text(getTranslated(context, "scratch_created_deleted"))));
          scratchCardList = loadScratchCardList();
        }
      });
    }
  }
}
