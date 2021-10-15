import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'models/module_details.dart';

class DetailsModuleBetaScreen extends StatefulWidget {
  final int moduleId;

  const DetailsModuleBetaScreen({Key key, this.moduleId}) : super(key: key);

  @override
  _DetailsModuleBetaScreenState createState() =>
      _DetailsModuleBetaScreenState();
}

class _DetailsModuleBetaScreenState extends State<DetailsModuleBetaScreen> {
  ModuleDetails moduleData;
  bool isLoading = false;

  Future<ModuleDetails> moduleDetails;

  List<Map> previewList = <Map>[];

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

    // if (response['status'] == 'success') {
    Map responseMap = response['list'];

    moduleData = ModuleDetails.fromJson(responseMap);
    return ModuleDetails.fromJson(responseMap);
    // }
  }

  void appUrlCopyClicked(String moduleUrl) {
    Clipboard.setData(ClipboardData(text: moduleUrl));
    Fluttertoast.showToast(msg: getTranslated(context, 'copied_clipboard'));
  }

  showAppQr() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          String moduleUrl = 'https://web.tagcash.com/m/${widget.moduleId}';
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  QrImage(
                    data: moduleUrl,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    size: 240,
                    embeddedImage: AssetImage('assets/images/logo.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(60, 60),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(moduleUrl),
                    trailing: IconButton(
                      icon: Icon(Icons.copy_outlined),
                      onPressed: () => appUrlCopyClicked(moduleUrl),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void gitUrlCopy(String url) {
    Clipboard.setData(new ClipboardData(text: url));
    showSnackBar('URL copied to clipboard');
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
