import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/apps/vaults/models/album_content.dart';
import 'package:tagcash/apps/vaults/models/album_details.dart';
import 'package:tagcash/apps/vaults/user/vault_album_preview_page.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class VaultAlbumContentListPage extends StatefulWidget {
  final AlbumDetails vaultObj;
  const VaultAlbumContentListPage({Key key, this.vaultObj}) : super(key: key);
  VaultAlbumContentListPageState createState() =>
      VaultAlbumContentListPageState();
}

class VaultAlbumContentListPageState extends State<VaultAlbumContentListPage> {
  final globalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Future<List<Role>> rolesListData;
  Role roleSelected;
  bool enableAutoValidate = false;
  bool iscreateAlbumBo = false;
  bool isLoading = false;
  String albumId;
  final titleInput = TextEditingController();
  var roleTypeID = "";
  String cardTypeValue;

  List<CARDTYPEITEMS> _cardTypes = CARDTYPEITEMS.getCardTypes();
  List<DropdownMenuItem<CARDTYPEITEMS>> _dropdownMenuItems;
  CARDTYPEITEMS _selectedCardTypes;

  StreamController<List<AlbumContent>> _streamcontroller;
  final scrollController = ScrollController();

  List<AlbumContent> _data;
  int countApi = 10;
  bool hasMore;
  bool _isLoading;
  var membershipStatus;
  var memberType;

  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_cardTypes);
    _selectedCardTypes = _dropdownMenuItems[0].value;
    cardTypeValue = _selectedCardTypes.value;

    _data = List<AlbumContent>();
    _streamcontroller = StreamController<List<AlbumContent>>.broadcast();
    _isLoading = false;
    hasMore = false;
    if (widget.vaultObj != null) {
      albumId = widget.vaultObj.id;
      titleInput.text = widget.vaultObj.albumName;
      roleTypeID = widget.vaultObj.visibility;
      hasMore = true;
      loadMoreItems();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          loadMoreItems();
        }
      });
    } else {}

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadMoreItems({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = List<AlbumContent>();
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

  Future<List<AlbumContent>> loadContactsList() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['album_id'] = albumId.toString();
    apiBodyObj['list_only'] = cardTypeValue.toString();
    apiBodyObj['page_count'] = countApi.toString();
    apiBodyObj['page_offset'] = _data.length.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/GetAlbumDetailsFromId', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List<AlbumContent> getData = List<AlbumContent>();
    List responseList = response['result']['uploaded_albums'];
    membershipStatus = response['result']['membership_status'];
    memberType = response['result']['member_type'];
    if (responseList.length != 0) {
      getData = responseList.map<AlbumContent>((json) {
        return AlbumContent.fromJson(json);
      }).toList();
    } else {
      var msg;
      if (cardTypeValue == "my_favourites") {
        msg = getTranslated(context, "vault_no_fav_found");
      } else if (cardTypeValue == "unlocked") {
        msg = getTranslated(context, "vault_unlocked_msg");
      } else if (cardTypeValue == "all") {
        msg = getTranslated(context, "vault_no_item_found");
      } else if (cardTypeValue == "locked") {
        msg = getTranslated(context, "vault_locked_msg");
      }
      showMessage(msg);
    }
    return getData;
  }

  List<DropdownMenuItem<CARDTYPEITEMS>> buildDropdownMenuItems(List cardTypes) {
    List<DropdownMenuItem<CARDTYPEITEMS>> items = List();
    for (CARDTYPEITEMS card in cardTypes) {
      items.add(
        DropdownMenuItem(
          value: card,
          child: Text(card.name),
        ),
      );
    }
    return items;
  }

  listItemTapped(
    obj,
    BuildContext context,
  ) async {
    if (obj.permittedToView == true) {
      Map results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            VaultAlbumPreviewPage(fileObj: obj, albumId: albumId),
      ));
    } else {
      if (obj.priceAmount == "0" && memberType == "1") {
        if (membershipStatus == 0) {
          var msg = getTranslated(context, "vault_membership_upgrade");
          showMessage(msg);
        }
      } else {
        showPurchaseWindow(obj);
      }
    }
  }

  void showMessage(String message) {
    globalKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> dataRefresh() {
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  onChangeDropdownItem(CARDTYPEITEMS selectedCard) {
    setState(() {
      _selectedCardTypes = selectedCard;
      cardTypeValue = _selectedCardTypes.value;
      loadMoreItems(clearCachedData: true);
    });
  }

  purchaseAlbumContent(index) async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_data_id'] = index.id.toString();

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('vaults/UnlockAlbumData', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Map results = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            VaultAlbumPreviewPage(fileObj: index, albumId: albumId),
      ));
      if (results == null) {
        setState(() {
          loadMoreItems(clearCachedData: true);
        });
      }
    } else {
      var errorMsg;
      if (response['error'] == 'switch_to_user_perspective') {
        errorMsg = getTranslated(context, "switch_to_user_perspective");
      } else if (response['error'] ==
          'insuffcient_balance_to_purchase_this_album_data') {
        errorMsg = getTranslated(
            context, "vault_insuffcient_balance_to_purchase_this_album_data");
      } else if (response['error'] == 'wallet_transfer_failed') {
        errorMsg = getTranslated(context, "vault_wallet_transfer_failed");
      } else if (response['error'] == 'failed') {
        errorMsg = getTranslated(context, "vault_failed");
      } else if (response['error'] == 'permission_denied') {
        errorMsg = getTranslated(context, "permission_denied");
      } else if (response['error'] == 'request_not_completed') {
        errorMsg = getTranslated(context, "request_not_completed");
      } else if (response['error'] == 'no_need_to_unlock_free_album_data_id') {
        errorMsg = getTranslated(
            context, "vault_no_need_to_unlock_free_album_data_id");
      } else if (response['error'] == 'album_is_already_locked') {
        errorMsg = getTranslated(context, "vault_album_is_already_locked");
      } else {
        errorMsg = response['error'];
      }
      showMessage(errorMsg);
    }
  }

  showPurchaseWindow(index) {
    showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      getTranslated(context, "vault_content_purchase_msg_one") +
                          index.priceAmount +
                          getTranslated(
                              context, "vault_content_purchase_msg_two"),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                        getTranslated(context, "vault_payment_continew_msg"),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .apply(color: Colors.black)),
                  ),
                  SizedBox(height: 40),
                  Divider(
                    thickness: .5,
                    color: Colors.grey,
                  ),
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(getTranslated(context, "no")),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Container(
                            height: 40,
                            child: VerticalDivider(
                                thickness: .5, color: Colors.grey)),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(getTranslated(context, "yes")),
                            onPressed: () {
                              Navigator.of(context).pop();
                              purchaseAlbumContent(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget roleListwidget = new Container(
        margin: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _selectedCardTypes,
                items: _dropdownMenuItems,
                onChanged: onChangeDropdownItem,
              ),
            ],
          ),
        ));
    Widget albumContentWidget = new Expanded(
        child: Stack(children: [
      RefreshIndicator(
        onRefresh: dataRefresh,
        child: StreamBuilder(
          stream: _streamcontroller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            if (!snapshot.hasData) {
              return Center(child: Loading());
            } else {
              return ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < snapshot.data.length) {
                    return new GestureDetector(
                      onTap: () {
                        listItemTapped(snapshot.data[index], context);
                      },
                      child: Card(
                        child: ListTile(
                          leading: snapshot.data[index].uploadType == "image"
                              ? snapshot.data[index].fileUrl != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data[index].fileUrl,
                                        height: 48.0,
                                        width: 48.0,
                                        fit: BoxFit.fill,
                                      ))
                                  : Container(
                                      height: 48.0,
                                      width: 48.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey[400],
                                          shape: BoxShape.rectangle),
                                      child: Icon(Icons.lock_outlined,
                                          size: 30, color: Colors.white),
                                    )
                              : snapshot.data[index].uploadType == "video"
                                  ? snapshot.data[index].thumbnail != ""
                                      ? Container(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot
                                                      .data[index].thumbnail,
                                                  height: 48.0,
                                                  width: 48.0,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              Icon(Icons.videocam,
                                                  size: 30, color: Colors.grey),
                                            ],
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
                                          child: Icon(Icons.lock_outlined,
                                              size: 30, color: Colors.white),
                                        )
                                  : SizedBox(),
                          title: Text(snapshot.data[index].photoName),
                          subtitle: Row(
                            children: [
                              Expanded(
                                  child: Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.black45,
                                  ),
                                  Text(
                                    snapshot.data[index].viewsCount,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.black45,
                                  ),
                                  Text(
                                    snapshot.data[index].favCount,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Row(
                                children: [
                                  snapshot.data[index].priceAmount == "0"
                                      ? Text(
                                          getTranslated(context, "vault_free"),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text(
                                          snapshot.data[index].priceAmount +
                                              " " +
                                              getTranslated(
                                                  context, "vault_credits"),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (hasMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      //  child: Center(child: CircularProgressIndicator()),
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
      _isLoading ? Center(child: Loading()) : SizedBox(),
    ]));

    return Scaffold(
        key: globalKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: widget.vaultObj.albumName,
        ),
        body: Stack(
          // This makes each child fill the full width of the screen

          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                roleListwidget,
                albumContentWidget,
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}

class CARDTYPEITEMS {
  String value;
  String name;

  CARDTYPEITEMS(this.value, this.name);

  static List<CARDTYPEITEMS> getCardTypes() {
    return <CARDTYPEITEMS>[
      CARDTYPEITEMS("my_favourites", 'Show favorites'),
      CARDTYPEITEMS("unlocked", 'Show unlocked only'),
      CARDTYPEITEMS("all", 'Show locked and unlocked'),
      CARDTYPEITEMS("locked", 'Show locked only'),
    ];
  }
}
