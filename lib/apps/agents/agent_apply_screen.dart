import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagcash/apps/agents/agent_locations_screen.dart';
import 'package:tagcash/apps/agents/agent_video_screen.dart';
import 'package:tagcash/apps/agents/models/quiz_question.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import '../../components/image_source_select.dart';

class AgentApplyScreen extends StatefulWidget {
  @override
  _AgentApplyScreenState createState() => _AgentApplyScreenState();
}

class _AgentApplyScreenState extends State<AgentApplyScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String agentStatus;
  bool quizCompletedStatus = false;
  int verificationLevel = 0;

  //File _receiptFile;
  PickedFile _receiptFile1;
  PickedFile _receiptFile2;
  PickedFile _receiptFile3;
  bool _hasLicence = false;
  bool declinedTryAgain = false;
  List<Object> images = List<Object>();
  Future<File> _imageFile;
  int receiptFileCount = 0;

  //File _imageFile;

  @override
  void initState() {
    super.initState();
    getAgentStatus();
    setState(() {
      images.add('Add Image');
      images.add('Add Image');
      images.add('Add Image');
    });
  }

  getAgentStatus() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/GetAgentStatus');

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      setState(() {
        agentStatus = response['agent_status'];
        quizCompletedStatus = response['quiz_completed_status'];
      });
      declinedTryAgain = false;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "become_an_agent"),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "register_become_an_agent"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "register_become_an_agent_fees"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "register_become_an_agent_verify"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "become_an_agent_pay_bills"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "become_an_agent_sell_load"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                Text(
                  getTranslated(context, "become_an_agent_license"),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 10),
                if (agentStatus == 'not_requested' || declinedTryAgain)
                  Column(
                    children: [
                      CheckboxListTile(
                        //checkColor: Colors.red[600],
                        activeColor: kPrimaryColor,
                        value: _hasLicence,
                        title: Text(
                          getTranslated(
                              context, "become_an_agent_exchange_license"),
                          style: TextStyle(fontSize: 14),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            _hasLicence = value;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      _hasLicence
                          ? Column(children: [
                              buildGridView(),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_receiptFile1 == null &&
                                        _receiptFile2 == null &&
                                        _receiptFile3 == null) {
                                      final snackBar = SnackBar(
                                          content: Text(
                                            getTranslated(context,
                                                "please_upload_license"),
                                          ),
                                          duration: const Duration(seconds: 3));
                                      globalKey.currentState
                                          .showSnackBar(snackBar);
                                    } else {
                                      applyAsAgent();
                                    }
                                  },
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(10.0),
                                  color: kPrimaryColor,
                                  child: Text(
                                      getTranslated(context, "upload_license"),
                                      style: TextStyle(fontSize: 16)),
                                ),
                              )
                            ])
                          : (quizCompletedStatus)
                              ? Container()
                              : Container(
                                  width: double.infinity,
                                  child: RaisedButton(
                                    onPressed: () {
                                      takeTest();
                                    },
                                    textColor: Colors.white,
                                    padding: EdgeInsets.all(10.0),
                                    color: kPrimaryColor,
                                    child: Text(
                                        getTranslated(context,
                                            "watch_video_and_take_test"),
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                    ],
                  ),
                if (agentStatus == 'rejected' && !declinedTryAgain)
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          declinedTryAgain = true;
                        });
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: kPrimaryColor,
                      child: Text(getTranslated(context, "declined_agent"),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                if (agentStatus == 'requested')
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        //getKYCLevel();
                      },
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      color: Colors.grey,
                      child: Text(getTranslated(context, "pending_agent"),
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                if (agentStatus == 'accepted')
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () {
                            //getKYCLevel();
                          },
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          color: Colors.green[700],
                          child: Text(getTranslated(context, "verified_agent"),
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgentLocationsScreen(),
                              ),
                            );
                          },
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          color: kPrimaryColor,
                          child: Text(getTranslated(context, "add_locations"),
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(child: Loading()))
              : SizedBox(),
        ],
      ),
    );
  }

  applyAsAgent() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/ApplyAsAgent');
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      if (_receiptFile1 != null) uploadLicence(_receiptFile1);
      if (_receiptFile2 != null) uploadLicence(_receiptFile2);
      if (_receiptFile3 != null) uploadLicence(_receiptFile3);
    } else {}
  }

  uploadLicence(PickedFile _receiptFile) async {
    setState(() {
      isLoading = true;
    });
    //List<int> receiptImageBytes = _receiptFile.readAsBytesSync();
    List<int> receiptImageBytes = await _receiptFile.readAsBytes();

    var apiBodyObj = {};
    apiBodyObj['license'] = base64Encode(receiptImageBytes);

    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/UploadAgentLicense', apiBodyObj);

    if (response['status'] == 'success') {
      //widget.onSuccess(true);
      receiptFileCount--;
      if (receiptFileCount == 0) {
        setState(() {
          isLoading = false;
        });
        final snackBar = SnackBar(
            content: Text(getTranslated(context, "success_apply_an_agent")),
            duration: const Duration(seconds: 3));
        globalKey.currentState.showSnackBar(snackBar);
        getAgentStatus();
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  takeTest() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('AgentQuiz/GetAllAgentQuiz');
    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      List responseList = response['result'];
      List<QuizQuestion> questions = responseList.map<QuizQuestion>((json) {
        return QuizQuestion.fromJson(json);
      }).toList();
      startPlay(response['agent_video_url'], questions);
    } else {}
  }

  Future startPlay(String video, List<QuizQuestion> questions) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          AgentVideoScreen(video: video, questions: questions),
    ));
    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          getAgentStatus();
          //widget.onAgentCreated(true);
          final snackBar = SnackBar(
              content:
                  Text(getTranslated(context, "success_registered_an_agent")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'failed') {
          //Navigator.of(context).pop({'status': 'failed'});

        }
      });
    }
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
//                Image.file(
//                  uploadModel.imageFile,
//                  width: 300,
//                  height: 300,
//                ),

                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.black,

                    image: DecorationImage(
                      image:  kIsWeb
                          ? NetworkImage(uploadModel.imageFile.path)
                          : FileImage(uploadModel.imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        images.replaceRange(index, index + 1, ['Add Image']);
                        if (index == 0) {
                          _receiptFile1 = null;
                        } else if (index == 1)
                          _receiptFile2 = null;
                        else if (index == 2) _receiptFile3 = null;

                        receiptFileCount--;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
      }),
    );
  }

  final picker = ImagePicker();

  Future<File> getImage(ImageSource imageSource, int index) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
//      File croppedFile = await ImageCropper.cropImage(
//        sourcePath: pickedFile.path,
//        androidUiSettings: AndroidUiSettings(
//            toolbarColor: Color(0xFFe44933),
//            toolbarWidgetColor: Colors.white,
//            initAspectRatio: CropAspectRatioPreset.original,
//            lockAspectRatio: false),
//      );
//      if (croppedFile != null) {
        //setImage(_imageFile = croppedFile);
        setState(() {
          File croppedFile = File(pickedFile.path);
          ImageUploadModel imageUpload = new ImageUploadModel();
          imageUpload.isUploaded = false;
          imageUpload.uploading = false;
          imageUpload.imageFile = croppedFile;
          imageUpload.imageUrl = '';
          images.replaceRange(index, index + 1, [imageUpload]);
          if (index == 0)
            _receiptFile1 = pickedFile;
          else if (index == 1)
            _receiptFile2 = pickedFile;
          else if (index == 2) _receiptFile3 = pickedFile;
          receiptFileCount++;
        });
      }
    //}
  }

  Future _onAddImageClick(int index) async {
    setState(() {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return ImageSourceSelect(
              onSelected: (ImageSource imageSource) =>
                  getImage(imageSource, index),
            );
          });
//      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
//      getFileImage(index);
    });
  }

  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();

    _imageFile.then((file) async {
      setState(() {
        ImageUploadModel imageUpload = new ImageUploadModel();
        imageUpload.isUploaded = false;
        imageUpload.uploading = false;
        imageUpload.imageFile = file;
        imageUpload.imageUrl = '';
        images.replaceRange(index, index + 1, [imageUpload]);
      });
    });
  }
}

class ImageUploadModel {
  bool isUploaded;
  bool uploading;
  File imageFile;
  String imageUrl;

  ImageUploadModel({
    this.isUploaded,
    this.uploading,
    this.imageFile,
    this.imageUrl,
  });
}
