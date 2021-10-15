import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/apps/vaults/business/vault_upload_content_page.dart';
import 'package:tagcash/apps/vaults/models/album_content.dart';
import 'package:tagcash/apps/vaults/models/album_details.dart';
import 'package:tagcash/apps/vaults/user/vault_album_preview_page.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:provider/provider.dart';

class VaultAlbumCreatePage extends StatefulWidget {
  final AlbumDetails vaultObj;
  const VaultAlbumCreatePage({Key key, this.vaultObj}) : super(key: key);
  VaultAlbumCreatePageState createState() => VaultAlbumCreatePageState();
}

class VaultAlbumCreatePageState extends State<VaultAlbumCreatePage> {
  final globalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  StreamController<List<AlbumContent>> _streamcontroller;
  Future<List<Role>> rolesListData;

  Role roleSelected;
  bool enableAutoValidate = false;
  bool iscreateAlbumBo = false;
  bool isLoading = false;
  String albumId;

  List<AlbumContent> _data;
  int countApi = 10;
  bool hasMore = false;
  bool _isLoading;
  final titleInput = TextEditingController();
  var roleTypeID = "";
  var memberType;

  void initState() {
    _data = List<AlbumContent>();
    _streamcontroller = StreamController<List<AlbumContent>>.broadcast();
    _isLoading = false;
    hasMore = true;
    if (widget.vaultObj != null) {
      iscreateAlbumBo = true;
      albumId = widget.vaultObj.id;
      titleInput.text = widget.vaultObj.albumName;

      if (widget.vaultObj.visibility == "every_one") {
        roleTypeID = "-1";
      } else if (widget.vaultObj.visibility == "no_one") {
        roleTypeID = "-2";
      } else {
        roleTypeID = widget.vaultObj.visibility;
      }

      // hasMore = true;

      loadMoreItems();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          loadMoreItems();
        }
      });
    } else {
      // roleSelected = rolesListData[0]
    }
    rolesListData = rolesListLoad();
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
    apiBodyObj['page_count'] = countApi.toString();
    apiBodyObj['page_offset'] = _data.length.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/GetAlbumDetailsFromId', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    List<AlbumContent> getData = List<AlbumContent>();
    memberType = response['result']['member_type'];

    List responseList = response['result']['uploaded_albums'];

    if (responseList != null) {
      getData = responseList.map<AlbumContent>((json) {
        return AlbumContent.fromJson(json);
      }).toList();
    }
    return getData;
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();
    for (var i = 0; i < getData.length; i++) {
      if (getData[i].roleName == "Owner") {
        getData.remove(getData[i]);
      }
    }
    getData.insert(0, Role(id: -1, roleName: 'Every One'));
    getData.insert(1, Role(id: -2, roleName: 'No One'));
    if (iscreateAlbumBo == true) {
      if (roleTypeID == "-1") {
        roleSelected = getData[0];
      } else if (roleTypeID == "-2") {
        roleSelected = getData[1];
      } else {
        roleSelected =
            getData.firstWhere((item) => item.id.toString() == roleTypeID);
      }
    } else {
      roleSelected = getData[0];
    }
    return getData;
  }

  createAlbumRequest(BuildContext context) async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_name'] = titleInput.text.toString();

    if (roleSelected.id == -1) {
      apiBodyObj['visibility'] = "every_one";
    } else if (roleSelected.id == -2) {
      apiBodyObj['visibility'] = "no_one";
    } else {
      apiBodyObj['visibility'] = roleSelected.id.toString();
    }

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/AddAlbum', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      var msg = getTranslated(context, "vault_album_created");
      setState(() {
        final snackBar =
            SnackBar(content: Text(msg), duration: const Duration(seconds: 2));
        globalKey.currentState.showSnackBar(snackBar);
        albumId = response["album_id"];

        loadMoreItems(clearCachedData: true);
        iscreateAlbumBo = true;
      });
    } else {
      var errorMsg;
      if (response['error'] == 'switch_to_community_perspective') {
        errorMsg = getTranslated(context, "switch_to_community_perspective");
      } else if (response['error'] == 'role_is_not_exist_under_this_user_id') {
        errorMsg = getTranslated(
            context, "vault_role_is_not_exist_under_this_user_id");
      } else if (response['error'] == 'failed_to_add_the_album') {
        errorMsg = getTranslated(context, "vault_failed_to_add_the_album");
      } else if (response['error'] == 'album_already_added') {
        errorMsg = getTranslated(context, "vault_album_already_added");
      } else if (response['error'] == 'request_not_completed') {
        errorMsg = getTranslated(context, "request_not_completed");
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

  addContentHandler(BuildContext context) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          VaultUploadContentPage(albumId: albumId, memberType: memberType),
    ));
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          loadMoreItems(clearCachedData: true);
        }
      });
    }
  }

  listItemTapped(
    obj,
    BuildContext context,
  ) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VaultAlbumPreviewPage(fileObj: obj, albumId: null),
    ));
  }

  deleteAlbumById(index, context) async {
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
                    getTranslated(context, "vault_delete_content"),
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

    apiBodyObj['id'] = index.id.toString();

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/DeleteUploadData', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      var msg = getTranslated(context, "vault_content_deleted");
      final snackBar =
          SnackBar(content: Text(msg), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
      setState(() {
        loadMoreItems(clearCachedData: true);
      });
    } else {
      var msg;
      if (response['error'] == "switch_to_community_perspective") {
        msg = getTranslated(context, "switch_to_community_perspective");
      } else if (response['error'] == "permission_denied") {
        msg = getTranslated(context, "permission_denied");
      } else if (response['error'] == "unlocked_items_cannot_delete") {
        msg = getTranslated(context, "vault_unlocked_items_cannot_delete");
      } else if (response['error'] == "failed") {
        msg = getTranslated(context, "vault_failed");
      } else if (response['error'] == "request_not_completed") {
        msg = getTranslated(context, "request_not_completed");
      } else if (response['error'] == "album_details_not_found") {
        msg = getTranslated(context, "vault_album_details_not_found");
      } else {
        msg = response['error'];
      }
      showMessage(msg);
    }
  }

  Future<void> dataRefresh() {
    loadMoreItems(clearCachedData: true);
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    Widget roleListwidget = new Container(
        margin: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              iscreateAlbumBo == true
                  ? IgnorePointer(
                      child: TextFormField(
                      controller: titleInput,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "vault_album_name")),
                    ))
                  : TextFormField(
                      controller: titleInput,
                      decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "vault_album_name")),
                      validator: (titleInput) {
                        if (titleInput.isEmpty) {
                          return getTranslated(
                              context, "vault_album_name_require");
                        }
                        return null;
                      },
                    ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: rolesListData,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Role>> snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? iscreateAlbumBo == true
                            ? IgnorePointer(
                                child: DropdownButtonFormField<Role>(
                                decoration: const InputDecoration(
                                  border: const OutlineInputBorder(),
                                ),
                                value: roleSelected,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                items: snapshot.data
                                    .map<DropdownMenuItem<Role>>((Role value) {
                                  return DropdownMenuItem<Role>(
                                    value: value,
                                    child: Text(value.roleName),
                                  );
                                }).toList(),
                                onChanged: (Role newValue) {
                                  setState(() {
                                    roleSelected = newValue;
                                  });
                                },
                              ))
                            : DropdownButtonFormField<Role>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Role',
                                  border: const OutlineInputBorder(),
                                ),
                                value: roleSelected,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                items: snapshot.data
                                    .map<DropdownMenuItem<Role>>((Role value) {
                                  return DropdownMenuItem<Role>(
                                    value: value,
                                    child: Text(value.roleName),
                                  );
                                }).toList(),
                                onChanged: (Role newValue) {
                                  setState(() {
                                    roleSelected = newValue;
                                  });
                                },
                              )
                        : Center(child: Loading());
                  }),
            ],
          ),
        ));
    Widget albumContentWidget = new Expanded(
        child: Stack(
      children: [
        iscreateAlbumBo
            ? RefreshIndicator(
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
                            return ClipRect(
                                child: Slidable(
                              key: ValueKey(index),
                              actionPane: SlidableDrawerActionPane(),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                    caption: getTranslated(context, "delete"),
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () => deleteAlbumById(
                                        snapshot.data[index], context)),
                              ],
                              child: new GestureDetector(
                                  onTap: () {
                                    listItemTapped(
                                        snapshot.data[index], context);
                                  },
                                  child: Card(
                                    child: ListTile(
                                      leading: snapshot
                                                  .data[index].uploadType ==
                                              "image"
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: CachedNetworkImage(
                                                imageUrl: snapshot
                                                    .data[index].fileUrl,
                                                height: 48.0,
                                                width: 48.0,
                                                fit: BoxFit.fill,
                                              ))
                                          : snapshot.data[index].uploadType ==
                                                  "video"
                                              ? Container(
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: snapshot
                                                              .data[index]
                                                              .thumbnail,
                                                          height: 48.0,
                                                          width: 48.0,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      Icon(Icons.videocam,
                                                          size: 24,
                                                          color: Colors.grey),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  height: 48.0,
                                                  width: 48.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.grey[400],
                                                      shape:
                                                          BoxShape.rectangle),
                                                ),
                                      title:
                                          Text(snapshot.data[index].photoName),
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
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              snapshot.data[index]
                                                          .priceAmount ==
                                                      "0"
                                                  ? Text(
                                                      getTranslated(context,
                                                          "vault_free"),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Text(
                                                      snapshot.data[index]
                                                              .priceAmount +
                                                          " " +
                                                          getTranslated(context,
                                                              "vault_credits"),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  )),
                            ));
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
              )
            : SizedBox(),
      ],
    ));
    Widget addContentWidget = new Container(
        margin: EdgeInsets.all(8),
        child: iscreateAlbumBo
            ? Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      child: Text(getTranslated(context, "vault_add_content")),
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        addContentHandler(context);
                      },
                    ),
                  ),
                ],
              )
            : RaisedButton(
                child: Text(getTranslated(context, "vault_create")),
                color: kPrimaryColor,
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    createAlbumRequest(context);
                  }
                }));

    return Scaffold(
        key: globalKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "vault_create_album"),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                roleListwidget,
                albumContentWidget,
                addContentWidget,
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}
