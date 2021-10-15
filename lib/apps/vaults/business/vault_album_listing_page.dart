import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/chat/constant.dart';
import 'package:tagcash/apps/vaults/business/vault_album_create_page.dart';
import 'package:tagcash/apps/vaults/models/album_details.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class VaultAlbumListingPage extends StatefulWidget {
  VaultAlbumListingPageState createState() => VaultAlbumListingPageState();
}

class VaultAlbumListingPageState extends State<VaultAlbumListingPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  StreamController<List<AlbumDetails>> _streamcontroller;
  List<AlbumDetails> _data;

  bool hasMore = false;
  bool _isLoading;
  bool isLoading = false;
  int countApi = 10;

  void initState() {
    _data = List<AlbumDetails>();
    _streamcontroller = StreamController<List<AlbumDetails>>.broadcast();
    _isLoading = false;
    isLoading = false;
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

    loadAlbumsList().then((res) {
      _isLoading = false;
      _data.addAll(res);
      hasMore = (res.length == countApi);

      _streamcontroller.add(_data);
    });
  }

  Future<List<AlbumDetails>> loadAlbumsList() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['page_count'] = countApi.toString();
    apiBodyObj['page_offset'] = _data.length.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/GetAddedAlbums', apiBodyObj);

    setState(() {
      _isLoading = false;
    });

    List<AlbumDetails> getData = List<AlbumDetails>();
    List responseList = response['result'];

    if (responseList != null) {
      getData = responseList.map<AlbumDetails>((json) {
        return AlbumDetails.fromJson(json);
      }).toList();
    }
    return getData;
  }

  Future listItemTapped(obj) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VaultAlbumCreatePage(vaultObj: obj),
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

  deleteAlbumById(index) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(getTranslated(context, "delete"),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.red)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    getTranslated(context, "vault_delete_album"),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text(getTranslated(context, "no")),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          child: Text(getTranslated(context, "yes")),
                          onPressed: () {
                            Navigator.of(context).pop();
                            deleteAlbum(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  deleteAlbum(index) async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_id'] = index.id.toString();

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/DeleteAlbum', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      var errorMsg = getTranslated(context, "vault_album_deleted");
      final snackBar = SnackBar(
          content: Text(errorMsg), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
      setState(() {
        loadMoreItems(clearCachedData: true);
      });
    } else {
      var errorMsg;
      if (response['error'] == 'switch_to_community_perspective') {
        errorMsg = getTranslated(context, "switch_to_community_perspective");
      } else if (response['error'] == 'album_id_is_required') {
        errorMsg = getTranslated(context, "vault_album_id_is_required");
      } else if (response['error'] == 'failed') {
        errorMsg = getTranslated(context, "vault_album_delete_faild");
      } else if (response['error'] == 'album_details_not_found') {
        errorMsg = getTranslated(context, "vault_album_details_not_found");
      } else if (response['error'] == 'request_not_completed') {
        errorMsg = getTranslated(context, "request_not_completed");
      } else if (response['error'] == 'unlocked_albums_cannot_delete') {
        errorMsg =
            getTranslated(context, "vault_unlocked_albums_cannot_delete");
      } else {
        errorMsg = response['error'];
      }
      showMessage(errorMsg);
    }
  }

  void showMessage(String message) {
    globalKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            listItemTapped(null);
          },
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: [
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
                                          snapshot.data[index].visibilityName,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          snapshot.data[index].filesCount
                                                  .toString() +
                                              getTranslated(
                                                  context, "vault_files"),
                                        ),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        //size: 20.0,
                                        // color: Colors.brown[900],
                                      ),
                                      onPressed: () {
                                        deleteAlbumById(snapshot.data[index]);
                                      },
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
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
