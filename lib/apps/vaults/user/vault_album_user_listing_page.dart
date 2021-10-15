import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/vaults/models/album_details.dart';
import 'package:tagcash/apps/vaults/user/vault_album_content_listing_page.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class VaultAlbumuserListingPage extends StatefulWidget {
  VaultAlbumuserListingPageState createState() =>
      VaultAlbumuserListingPageState();
}

class VaultAlbumuserListingPageState extends State<VaultAlbumuserListingPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  StreamController<List<AlbumDetails>> _streamcontroller;
  final scrollController = ScrollController();

  List<AlbumDetails> _data;
  int countApi = 10;
  bool hasMore;
  bool _isLoading;
  void initState() {
    _data = List<AlbumDetails>();
    _streamcontroller = StreamController<List<AlbumDetails>>.broadcast();
    _isLoading = false;
    hasMore = true;

    loadMoreItems();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        loadMoreItems();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<AlbumDetails>();
      _streamcontroller.add(_data);
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    loadContactsList().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == countApi);

      _streamcontroller.add(_data);
    });
  }

  Future<List<AlbumDetails>> loadContactsList() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['page_count'] = countApi.toString();
    apiBodyObj['page_offset'] = _data.length.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/ListAlbums', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List<AlbumDetails> getData = List<AlbumDetails>();
    List responseList = response['result'];
    if (responseList.length != 0) {
      if (responseList != null) {
        getData = responseList.map<AlbumDetails>((json) {
          return AlbumDetails.fromJson(json);
        }).toList();
      }
    } else {
      var msg;
      msg = getTranslated(context, "vault_no_item_found");
      showMessage(msg);
    }
    return getData;
  }

  void showMessage(String message) {
    globalKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future listItemTapped(obj) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VaultAlbumContentListPage(vaultObj: obj),
    ));

    if (results == null) {
      setState(() {
        loadMoreItems(clearCachedData: true);
      });
    }
  }

  Future<void> dataRefresh() {
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: dataRefresh,
          child: StreamBuilder(
            stream: _streamcontroller.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              if (!snapshot.hasData || snapshot.data.isEmpty) {
                return Center(child: Loading());
              } else {
                return ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < snapshot.data.length) {
                      return Card(
                          child: GestureDetector(
                              onTap: () {
                                listItemTapped(snapshot.data[index]);
                              },
                              child: ListTile(
                                title: Text(
                                  snapshot.data[index].albumName,
                                ),
                                subtitle: Column(
                                  children: [
                                    Text(
                                      snapshot.data[index].filesCount
                                              .toString() +
                                          getTranslated(context, "vault_files"),
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              )));
                    } else if (hasMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                );
              }
            },
          ),
        ),
      ]),
    );
  }
}
