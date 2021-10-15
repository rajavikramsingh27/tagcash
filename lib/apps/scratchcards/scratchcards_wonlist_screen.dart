import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'models/scratch_card.dart';

class ScratchcardsWonListScreen extends StatefulWidget {
  ScratchWoncardsList createState() => ScratchWoncardsList();
}

class ScratchWoncardsList extends State<ScratchcardsWonListScreen> {
  bool isLoading = false;

  Future<List<ScratchCard>> scratchCardList;
  TextEditingController searchKeyInput;
  final globalKey = GlobalKey<ScaffoldState>();

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

  String dateDisplay(String date) {
    DateTime serverDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String formattedDate = formatter.format(serverDate);
    return formattedDate;
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
        'ScratchCard/ListUserWonScratchCards', apiBodyObj);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
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
                          child: ListTile(
                            leading: snapshot.data[index].image != ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
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
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey[400],
                                        shape: BoxShape.rectangle),
                                  ),
                            title: Text(
                              snapshot.data[index].name,
                            ),
                            subtitle: Column(
                              children: [
                                Text(
                                  snapshot.data[index].winAmount.toString() +
                                      " " +
                                      snapshot.data[index].currencyCode
                                          .toString(),
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                                SizedBox(width: 5),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.black, size: 12),
                                    SizedBox(width: 5),
                                    Text(
                                      dateDisplay(snapshot.data[index].winDate),
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        );
                      })
                  : Center(child: Loading());
            },
          ),
        ],
      ),
    );
  }
}
