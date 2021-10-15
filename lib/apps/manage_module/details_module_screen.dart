import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/utils/validator.dart';

import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:universal_platform/universal_platform.dart';
import 'edit_module_screen.dart';
import 'models/module_details.dart';

class DetailsModuleScreen extends StatefulWidget {
  final int moduleId;

  const DetailsModuleScreen({Key key, this.moduleId}) : super(key: key);

  @override
  _DetailsModuleScreenState createState() => _DetailsModuleScreenState();
}

class _DetailsModuleScreenState extends State<DetailsModuleScreen> {
  bool isLoading = false;

  Future<ModuleDetails> moduleDetails;

  List<Map> previewList = <Map>[];
  String moduleName = '';

  @override
  void initState() {
    super.initState();

    moduleDetails = getModuleDetails();
  }

  Future<ModuleDetails> getModuleDetails() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/ModuleById', apiBodyObj);

    Map responseMap = response['list'];

    List developers = responseMap['developer'];
    for (var i = 0; i < developers.length; i++) {
      previewList.add({
        'id': developers[i]['developer_id'].toString(),
        'name':
            '${developers[i]['user_firstname']} ${developers[i]['user_lastname']}',
      });
    }

    moduleName = responseMap['module_name'].toString();
    setState(() {});

    return ModuleDetails.fromJson(responseMap);
  }

  showAppQr() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: QrExportArea(
                moduleId: widget.moduleId,
                moduleName: moduleName,
              ),
            ),
          );
        });
  }

  void gitUrlCopy(String url) {
    Clipboard.setData(new ClipboardData(text: url));
    showSnackBar('URL copied to clipboard');
  }

  void userSelectedAdd(Map userData) {
    setState(() {
      previewList.add({
        'id': userData['id'],
        'name': userData['name'],
      });

      final ids = previewList.map((e) => e['id']).toSet();
      previewList.retainWhere((x) => ids.remove(x['id']));
    });
    updateDeveloperId();
  }

  void updateDeveloperId() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();

    List<int> selectedUser = [];
    previewList.forEach((user) {
      selectedUser.add(int.parse(user['id']));
    });

    apiBodyObj['developer_id'] = jsonEncode(selectedUser);

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/Create', apiBodyObj);

    setState(() {
      isLoading = false;
    });
  }

  void addUserShow() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: PreviewUserAdd(
                  onUserSelect: (value) => userSelectedAdd(value),
                ),
              ),
            ),
          );
        });
  }

  void moduleDeleteClicked() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Are you sure you want to permanently delete this Mini Program? ',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
                'This Mini Program will be deleted immediately. You can’t undo this action.'),
            actions: [
              TextButton(
                child: Text(
                  'Continue',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  moduleDeleteConfirmed();
                },
              ),
              SizedBox(width: 20),
              TextButton(
                child: Text(
                  'Cancel',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void moduleDeleteConfirmed() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/DeleteModule', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Fluttertoast.showToast(msg: 'Mini Program removed successfully');

      Navigator.pop(context, true);
    }
  }

  void moduleStatusChangeClicked(bool enable) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();

    if (enable) {
      apiBodyObj['stages'] = 'published';
    } else {
      apiBodyObj['stages'] = 'inactive';
    }
    //(create ,review ,develop ,published and inactive)

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/Create', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      moduleDetails = getModuleDetails();
    }
  }

  editModuleClicked() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditModuleScreen(moduleId: widget.moduleId),
      ),
    );
    setState(() {
      moduleDetails = getModuleDetails();
    });
  }

  void modulePublishClicked() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();
    apiBodyObj['stages'] = 'review';

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/Create', apiBodyObj);

    setState(() {});
    isLoading = false;
    if (response['status'] == 'success') {
      Fluttertoast.showToast(msg: 'Submitted for review');
      moduleDetails = getModuleDetails();
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Details',
        ),
        body: Stack(
          children: [
            FutureBuilder(
              future: moduleDetails,
              builder: (BuildContext context,
                  AsyncSnapshot<ModuleDetails> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                ModuleDetails moduleData = snapshot.data;

                return snapshot.hasData
                    ? ListView(
                        padding: EdgeInsets.all(10),
                        children: [
                          ListTile(
                            title: Text(moduleData.moduleName),
                            subtitle: Text(moduleData.moduleType),
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: moduleData.icon != ''
                                    ? DecorationImage(
                                        image: NetworkImage(moduleData.icon),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.qr_code),
                              onPressed: showAppQr,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                          moduleData.stages == 'review'
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.timelapse,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'In Review',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(height: 10),
                          Text(
                            moduleData.shortDescription,
                          ),
                          if (moduleData.moduleType == 'flutter' ||
                              moduleData.moduleType == 'html')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Git Repository',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    trailing: IconButton(
                                      icon: Icon(Icons.copy),
                                      onPressed: () =>
                                          gitUrlCopy(moduleData.gitUrl),
                                    ),
                                    title: Text(moduleData.gitUrl),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(),
                          if (moduleData.accessModule != 'private' &&
                              (moduleData.moduleType == 'flutter' ||
                                  moduleData.moduleType == 'html')) ...[
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add_box,
                                  color: Colors.red,
                                ),
                                onPressed: () => addUserShow(),
                              ),
                              title: Text('Users with preview access'),
                            ),
                            previewList.length == 0
                                ? Text(
                                    'Users not added',
                                  )
                                : SizedBox(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: previewList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Slidable(
                                  key: ValueKey(index),
                                  actionPane: SlidableDrawerActionPane(),
                                  secondaryActions: [
                                    IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () {
                                          previewList
                                              .remove(previewList[index]);
                                          updateDeveloperId();
                                        }),
                                  ],
                                  child: Card(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(previewList[index]['name']),
                                      subtitle: Text(previewList[index]['id']),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          if (moduleData.stages == 'develop') ...[
                            Card(
                              margin: EdgeInsets.only(top: 20),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Publish Mini Program',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    Text(
                                      'When Mini Program is ready for public use please submit the app for review.',
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => modulePublishClicked(),
                                      child: Text('Submit for Review'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Row(
                              children: [
                                if (moduleData.appPublished == 0) ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => moduleDeleteClicked(),
                                      child: Text('DELETE'),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: editModuleClicked,
                                      child: Text('EDIT'),
                                    ),
                                  ),
                                ],
                                if (moduleData.appPublished == 1) ...[
                                  Expanded(
                                    child: moduleData.stages == 'inactive'
                                        ? ElevatedButton(
                                            onPressed: () =>
                                                moduleStatusChangeClicked(true),
                                            child: Text('ENABLE'),
                                          )
                                        : ElevatedButton(
                                            onPressed: () =>
                                                moduleStatusChangeClicked(
                                                    false),
                                            child: Text('DISABLE'),
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Center(child: Loading());
              },
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}

class QrExportArea extends StatefulWidget {
  final String moduleName;
  final int moduleId;

  const QrExportArea({
    Key key,
    this.moduleId,
    this.moduleName,
  }) : super(key: key);

  @override
  _QrExportAreaState createState() => _QrExportAreaState();
}

class _QrExportAreaState extends State<QrExportArea> {
  GlobalKey globalKey = new GlobalKey();
  String moduleUrl = '';

  @override
  void initState() {
    moduleUrl = 'https://web.tagcash.com/m/${widget.moduleId}';
    super.initState();
  }

  void appUrlCopyClicked() {
    Clipboard.setData(ClipboardData(text: moduleUrl));
    Fluttertoast.showToast(msg: getTranslated(context, 'copied_clipboard'));
  }

  Future<void> exportPrintClickHandler() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 5);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);

      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (UniversalPlatform.isWeb) {
        final path = await getSavePath();
        final name = 'qrexport.png';
        final mimeType = 'image/png';
        final file = XFile.fromData(pngBytes, name: name, mimeType: mimeType);
        await file.saveTo(path);
      } else {
        final Directory directory = await getTemporaryDirectory();
        final File file = File('${directory.path}/qrexport.png');
        await file.writeAsBytes(pngBytes);

        Share.shareFiles(['${directory.path}/qrexport.png'], text: 'QR image');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: globalKey,
          child: Column(
            children: [
              Text(widget.moduleName),
              QrImage(
                data: moduleUrl,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                size: 240,
                embeddedImage: AssetImage('assets/images/logo.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(60, 60),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          child: Text("EXPORT"),
          onPressed: () => exportPrintClickHandler(),
        ),
        SizedBox(height: 20),
        ListTile(
          title: Text(moduleUrl),
          trailing: IconButton(
            icon: Icon(Icons.copy_outlined),
            onPressed: () => appUrlCopyClicked(),
          ),
        ),
      ],
    );
  }
}

class PreviewUserAdd extends StatefulWidget {
  final Function(Map) onUserSelect;
  const PreviewUserAdd({
    Key key,
    this.onUserSelect,
  }) : super(key: key);

  @override
  _PreviewUserAddState createState() => _PreviewUserAddState();
}

class _PreviewUserAddState extends State<PreviewUserAdd> {
  TextEditingController _idController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  userAddProcess() async {
    setState(() {
      isLoading = true;
    });

    String checkId = _idController.text;

    Map<String, String> apiBodyObj = {};

    if (Validator.isEmail(checkId)) {
      apiBodyObj['email'] = checkId;
    } else if (Validator.isNumber(checkId)) {
      apiBodyObj['id'] = checkId;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];

      widget.onUserSelect(responseList[0]);
      Navigator.pop(context);
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: 'The ID or email you entered is not valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'User ID or email',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('ADD'),
              onPressed: () => userAddProcess(),
            )
          ],
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
