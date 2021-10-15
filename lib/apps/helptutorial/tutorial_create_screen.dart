import 'package:flutter/material.dart';
import 'package:tagcash/services/networking.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/components/custom_button.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:tagcash/components/loading.dart';
import 'package:storage_path/storage_path.dart';
import 'dart:convert';
import 'package:tagcash/apps/helptutorial/models//file_model.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/helptutorial/models/tutorial_detail_model.dart';
import 'package:tagcash/apps/helptutorial/tutorial_lesson_detail_screen.dart';
import 'package:tagcash/apps/helptutorial/tutorial_custom_videoplayer.dart';
import 'package:tagcash/apps/helptutorial/models/chapterlessonmodel.dart';
import 'package:tagcash/apps/helptutorial/tutorial_chapterlesson_create_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagcash/components/image_source_select.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class TutorialCreateScreen extends StatefulWidget {
  final String tutorial_id;

  // In the constructor, require a Todo.
  TutorialCreateScreen({Key key, @required this.tutorial_id}) : super(key: key);

  @override
  _TutorialCreateScreenState createState() => _TutorialCreateScreenState();
}

class _TutorialCreateScreenState extends State<TutorialCreateScreen>
    with TickerProviderStateMixin {
  List<ChapterLessonModel> chapterLessonList = [];
  String lessonVideoLengthinseconds;
  String tutorialTotalTime;
  String uploadedLessonVideoFilename;
  bool tutorialEditMode = false;
  bool chapterEditMode = false;
  bool lessonEditMode = false;
  Future<TutorialDetailModel> tutorialDetail;
  String tutorial_id;
  String chapterId;
  String lessonId;
  var walletId = "1152";
  String currencyCode;
  String defaultCurrencyCode;
  String videoFilePath;
  File _tutorialImgFile;
  bool _isLoading = false;
  String imgUrl = null;
  bool enableAutoValidate = false;
  bool enableAutoValidateLesson = false;
  final _tutorialAmountInputController = TextEditingController();
  final _tutorialDescriptionController = TextEditingController();
  final _tutorialNameController = TextEditingController();
  final _chapterNameController = TextEditingController();
  final _lessonNameController = TextEditingController();
  final _lessonPriceController = TextEditingController();
  final _videoDurationController = TextEditingController();
  static const List<IconData> icons = const [Icons.folder, Icons.theaters];
  final globalKey = GlobalKey<ScaffoldState>();
  final _formKeyTutorial = GlobalKey<FormState>();
  AnimationController _controller;
  Future<List<Role>> rolesListData;
  Role roleSelected;
  bool onePriceStatus = true;
  final textFieldDescriptionFocusNode = FocusNode();
  final textFieldTutorialPriceFocusNode = FocusNode();
  bool _showLessonChapterCreateButtonFlag = false;
  int lessonSelectedID;
  double heightValue = 1;
  int freeorPaidRadioValue = 0;
  int totlaLessonCount = 0;
  final picker = ImagePicker();
  PickedFile pickedFile;

  @override
  void initState() {
    super.initState();
    //  getExternalStoragePermission();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.tutorial_id == null) {
      _showLessonChapterCreateButtonFlag = false;
    } else {
      _showLessonChapterCreateButtonFlag = true;
      tutorial_id = widget.tutorial_id;
      tutorialEditMode = true;
    }
    rolesListData = rolesListLoad();

    rolesListData.then((res) {
      if (tutorialEditMode == true) {
        getTutorialDetails();
      }
    });
  }

  @override
  void dispose() {
    _tutorialAmountInputController.dispose();
    _lessonNameController.dispose();
    _videoDurationController.dispose();
    _lessonPriceController.dispose();
    _tutorialDescriptionController.dispose();

    super.dispose();
  }

  void getVideoDuration(File videoFile) async {
    double duration = 0;
    String selectedFileName = path.basename(videoFile.path);
    String videospath = await StoragePath.videoPath;
    var response = jsonDecode(videospath);

    var imageList = response as List;
    for (int i = 0; i < imageList.length; i++) {
      List responseList = response[i]["files"];
      List<Files> list =
          responseList.map<Files>((json) => Files.fromJson(json)).toList();
      Files fileObj = list.firstWhere(
          (element) => element.displayName == selectedFileName, orElse: () {
        return null;
      });
      if (fileObj != null) {
        lessonVideoLengthinseconds = fileObj.duration;
        duration = double.parse(fileObj.duration);

        videoFilePath = fileObj.path;
        break;
      } else {
        duration = 0;
      }
    }
    if (duration != 0) {
      setState(() {
        _videoDurationController.text =
            getTimeInSenondsMinHour(double.parse(duration.toString()));
      });
    } else {
      _videoDurationController.text = "00:00";
    }
  }

  String getTimeInSenondsMinHour(double time) {
    String formattedTime;

    if ((time > 999) & (time < 60000)) {
      double t = time / 1000;
      int timeseconds = t.toInt();

      formattedTime = "00:" + "00:" + timeseconds.toString();
      return formattedTime;
    } else if ((time > 59999) & (time < 3600000)) {
      String timeinMinString, timeinSecondsString;
      double timemin = time / 1000;
      int timemini = timemin.toInt();
      double timeMinDouble = timemini / 60;
      int timeMinInt = timeMinDouble.toInt();
      int timeInSecondsMod = timemini % 60;
      if (timeInSecondsMod < 10) {
        timeinSecondsString = "0" + timeInSecondsMod.toString();
      } else {
        timeinSecondsString = timeInSecondsMod.toString();
      }
      if (timeMinInt < 10) {
        timeinMinString = "0" + timeMinInt.toString();
      } else {
        timeinMinString = timeMinInt.toString();
      }

      formattedTime = "00:" + timeinMinString + ":" + timeinSecondsString;
      return formattedTime;
    } else if (time > 3600000) {
      double timeSeconds = time / 1000;

      int timeSecondsInt = timeSeconds.toInt();

      double timeMinDouble = timeSecondsInt / 60;
      int timeMinInt = timeMinDouble.toInt();
      int timeSecondsmod = timeSecondsInt % 60; //seconds value
      double timeHourDouble = timeMinInt / 60;
      int timeHourInt = timeHourDouble.toInt(); //Hour value
      int timeMinMod = timeMinInt % 60; //min value

      String timeHourIntS, timeMinModS, timeSecondsmodS;
      if (timeHourInt < 10) {
        timeHourIntS = "0" + timeHourInt.toString();
      } else {
        timeHourIntS = timeHourInt.toString();
      }
      if (timeMinMod < 10) {
        timeMinModS = "0" + timeMinMod.toString();
      } else {
        timeMinModS = timeMinMod.toString();
      }
      if (timeSecondsmod < 10) {
        timeSecondsmodS = "0" + timeSecondsmod.toString();
      } else {
        timeSecondsmodS = timeSecondsmod.toString();
      }

      formattedTime = timeHourIntS + ":" + timeMinModS + ":" + timeSecondsmodS;
      return formattedTime;
    } else {
      formattedTime = "00:00";
      return formattedTime;
    }
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
    getData.insert(0, Role(id: 0, roleName: 'Any Role'));
    //getData

    return getData;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void navigateToVideoPlayer(String videoFilePath) {
    if (videoFilePath == null) {
      Fluttertoast.showToast(msg: 'Invalid Video File');
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Add Your Code here.
        MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
                  videoUrl: videoFilePath,
                  lessonId: lessonId,
                ));
      });
    }
  }

  void saveTutorialCreateHandler() {
    if (onePriceStatus == true) {
      if (walletId == null) {
        showMessage("Please select a valid Wallet");
        return;
      }
    }
    if (_tutorialImgFile != null) {
      saveTutorialImageFileHandler();
    } else {
      saveTutorialData(null);
    }
  }

  void saveTutorialImageFileHandler() async //Here we upload image file
  {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> fileData;
    if (_tutorialImgFile != null) {
      var file = _tutorialImgFile;
      fileData = {};
      String basename = path.basename(_tutorialImgFile.path);
      fileData['key'] = 'file_data';
      fileData['fileName'] = basename;
      fileData['path'] = _tutorialImgFile.path;
      fileData['bytes'] = await pickedFile.readAsBytes();
    }
    Map<String, String> apiBodyObj = {};
    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/UploadHelpTutorialImage', apiBodyObj, fileData);

    ;
    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      saveTutorialData(response['image_name']);
    }
  }

  void saveTutorialData(String imageName) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> response;
    Map<String, String> apiBodyObj = {};

    apiBodyObj['name'] = _tutorialNameController.text;
    apiBodyObj['description'] = _tutorialDescriptionController.text;

    if (roleSelected != null) {
      apiBodyObj['role_id'] = roleSelected.id.toString();
    }

    if (imageName != null) {
      apiBodyObj['image_name'] = imageName;
    }

    if (freeorPaidRadioValue == 1) {
      apiBodyObj['price_free'] = "0";
    } else {
      apiBodyObj['price_free'] = "1";
    }
    if (tutorialEditMode == false) {
      response = await NetworkHelper.request(
          'HelpTutorial/HelpTutorialCreate', apiBodyObj);
    } else {
      apiBodyObj['_id'] = tutorial_id.toString();
      response = await NetworkHelper.request(
          'HelpTutorial/HelpTutorialEdit', apiBodyObj);
    }

    setState(() {
      _isLoading = false;
    });
    if (response['status'] == 'success') {
      if (tutorialEditMode == false) {
        tutorial_id = response['tutorial_id'];

        tutorialEditMode = true;
        showMessage(getTranslated(context, 'tutorial_save_success'));
      } else {
        Navigator.pop(context, "reload");
        showMessage(getTranslated(context, 'tutorial_update_success'));
      }

      setState(() {
        _showLessonChapterCreateButtonFlag = true;
      });
    } else {
      if (response['error'] == "switch_to_community_perspective") {
        showMessage(getTranslated(context, 'tutorial_switch_group'));
      } else if (response['error'] == "price_wallet_id_is_required") {
        showMessage(getTranslated(context, 'tutorial_pricewalletid_missing'));
      } else {
        showMessage(getTranslated(context, "tutorial_error_unspecifiederror"));
      }
    }
  }

  void getTutorialDetails() {
    tutorialDetail = tutorialDetailLoad();
    tutorialDetail.then((TutorialDetailModel tutorialDetailModel) {
      setTutorialValues(tutorialDetailModel);
    });
  }

  void setTutorialValues(TutorialDetailModel tutorialDetailModel) {
    setState(() {
      totlaLessonCount = tutorialDetailModel.totalLessonCount;
      tutorialTotalTime =
          getTutorialTime(tutorialDetailModel.lessonTotalLength);
      _tutorialNameController.text = tutorialDetailModel.name;
      _tutorialDescriptionController.text = tutorialDetailModel.description;
      imgUrl = tutorialDetailModel.imageUrl;

      if (tutorialDetailModel.priceFree == 0) {
        freeorPaidRadioValue = 1;
        if (tutorialDetailModel.priceAdded == "1") {
          onePriceStatus = true;
          _tutorialAmountInputController.text = tutorialDetailModel.priceAmount;
        } else {
          onePriceStatus = false;
        }
      } else {
        freeorPaidRadioValue = 0;
      }
      if (tutorialDetailModel.roleId != null) {
        rolesListData.then((List<Role> roleList) {
          Role role = roleList.firstWhere(
              (element) => element.id == int.parse(tutorialDetailModel.roleId),
              orElse: () {
            return null;
          });
          roleSelected = role;
        });
      }
      List<Chapters> chapters = tutorialDetailModel.chapters;
      for (int i = 0; i < chapters.length; i++) {
        Chapters chObj = chapters[i];
        ChapterLessonModel chapterModel = ChapterLessonModel(
            chapterLessonId: chObj.id,
            chapterLessonName: chObj.chapterName,
            type: "chapter",
            chapterid: chObj.id,
            chapterLessonIndex: (i + 1).toString());
        chapterLessonList.add(chapterModel);
        List<Lessons> lessons = chObj.lessons;
        for (int j = 0; j < lessons.length; j++) {
          Lessons lessonObj = lessons[j];
          ChapterLessonModel lessonModel = ChapterLessonModel(
              chapterLessonId: lessonObj.lessonId,
              chapterLessonName: lessonObj.lessonName,
              type: "lesson",
              chapterid: chObj.id,
              chapterLessonIndex: (j + 1).toString(),
              lessonpriceInCredits: lessonObj.priceInCredits,
              lessonVideofileName: lessonObj.fileName,
              lessonVideofileUrl: lessonObj.fileUrl,
              lessonvideolength: lessonObj.length);
          chapterLessonList.add(lessonModel);
        }
      }
    });
  }

  String getTutorialTime(String time) {
    String hour, minute, seconds;
    String formattedTime;
    List<String> timeList = time.split(":");

    hour = timeList[0];
    minute = timeList[1];
    seconds = timeList[2];

    if (hour == "0" || hour == "00") {
      hour = "00";
    } else {
      hour = timeList[0];
    }
    if (minute == "0" || minute == "00") {
      minute = "00";
    } else {
      minute = timeList[1];
    }
    if (seconds == "0" || seconds == "00") {
      seconds = "00";
    } else {
      seconds = timeList[2];
    }
    if (hour == "00") {
      if (minute == "00" || minute == "0") {
        formattedTime = seconds + " Seconds ";
      } else {
        formattedTime = minute + " Minutes " + seconds + " Seconds ";
      }
    } else {
      formattedTime = hour + " Hour " + minute + " Minutes ";
    }
    return formattedTime;
  }

  Future<TutorialDetailModel> tutorialDetailLoad() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = tutorial_id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HelpTutorial/GetTutorialDetailsFromId', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      dynamic responseData = response['result'];

      return TutorialDetailModel.fromJson(responseData);
    } else {
      return null;
    }
  }

  void setLessonValues(Lessons lessonObj, String chapter_id) {
    setState(() {
      chapterId = chapter_id;
      lessonId = lessonObj.lessonId;

      _lessonNameController.text = lessonObj.lessonName;
      _videoDurationController.text = lessonObj.length;
      uploadedLessonVideoFilename = lessonObj.fileName;

      _lessonPriceController.text = lessonObj.priceInCredits;
    });
  }

  void deleteTutorialHandler() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['tutorial_id'] = tutorial_id;
    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/RemoveTutorial', apiBodyObj);

    setState(() {
      _isLoading = false;
    });
    if (response["status"] == "success") {
      showMessage(getTranslated(context, "tutorial_delete_success"));
      Navigator.pop(context, "reload");
    } else {
      if (response["error"] == "switch_to_community_perspective") {
        showMessage(
            getTranslated(context, "tutorial_switch_merchantperspective"));
      } else if (response["error"] == "failed_to_delete_the_tutorial") {
        showMessage(getTranslated(context, "tutorial_delete_failed"));
      } else if (response["error"] == "tutorial_id_not_found") {
        showMessage(getTranslated(context, "tutorial_id_notfound"));
      } else if (response["error"] == "tutorial_already_deleted") {
        showMessage(getTranslated(context, "tutorial_id_notfound"));
      } else if (response["error"] == "tutorial_already_purchased") {
        showMessage(
            getTranslated(context, "tutorial_purchasedtutorial_delete"));
      }
    }
  }

  void navigateToLessonDetailScreen() {
    tutorialDetail.then((TutorialDetailModel tutorialDetailModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialLessonDetailScreen(
            tutorialId: tutorialDetailModel.id,
            tutorialName: tutorialDetailModel.name,
            tutorialDescription: tutorialDetailModel.description,
            imageUrl: tutorialDetailModel.imageUrl,
            priceFree: tutorialDetailModel.priceFree,
          ),
        ),
      );
    });
  }

  void appUrlCopyClicked(String moduleUrl) {
    Clipboard.setData(ClipboardData(text: moduleUrl));
    Fluttertoast.showToast(
        msg: getTranslated(context, "tutorial_copied_clipboard"));
  }

  showAppQr() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          String moduleUrl = 'https://web.tagcash.com/123/?id=$tutorial_id';
          //   String moduleUrl = 'https://web.tagcash.com/{module_id}/?id=$tutorial_id';//Please replace module id, when it makes live
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

  void navigateToChapterLessonCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialChapterLessonCreateScreen(
          tutorial_id: tutorial_id,
        ),
      ),
    ).whenComplete(() => getTutorialDetails());
  }

  void attachImageClick() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ImageSourceSelect(
            onSelected: (ImageSource imageSource) => getImage(imageSource),
          );
        });
  }

  void getImage(ImageSource imageSource) async {
    pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      setState(() {
        _tutorialImgFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "tutorial_title"),
        ),
        floatingActionButton: _showLessonChapterCreateButtonFlag
            ? FloatingActionButton(
                onPressed: () {
                  navigateToChapterLessonCreateScreen();
                },
                child: Icon(Icons.add),
                tooltip: "help_tutorials_create",
                backgroundColor: Theme.of(context).primaryColor,
              )
            : Container(),
        body: Stack(children: [
          Form(
              key: _formKeyTutorial,
              autovalidateMode: enableAutoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  children: [
                    (_tutorialImgFile == null)
                        ? (imgUrl != null)
                            ? Container(
                                constraints: BoxConstraints(
                                    minWidth: double.infinity, maxHeight: 200),
                                child: GestureDetector(
                                  child: Container(
                                      child: CachedNetworkImage(
                                    alignment: Alignment.center,
                                    imageUrl: imgUrl,
                                    fit: BoxFit.cover,
                                  )),
                                  onTap: () {
                                    attachImageClick();
                                  },
                                ),
                              )
                            : Column(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(maxHeight: 200),
                                    child: Stack(
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            minWidth: double.infinity,
                                          ),
                                          child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () => attachImageClick(),
                                              child: Container(
                                                child: ListTile(
                                                  leading: Icon(Icons.note),
                                                  title: Text(getTranslated(
                                                      context,
                                                      "tutorials_image")),
                                                  subtitle: Text(getTranslated(
                                                      context,
                                                      "tutorials_add_image")),
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                        : kIsWeb
                            ? Container(
                                constraints: BoxConstraints(
                                    maxWidth: double.infinity, maxHeight: 200),
                                child: Image.network(
                                  _tutorialImgFile.path,
                                  fit: BoxFit.cover,
                                ))
                            : Container(
                                constraints: BoxConstraints(
                                    maxWidth: double.infinity, maxHeight: 200),
                                child: Image.file(
                                  File(_tutorialImgFile.path),
                                )),
                    Container(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
                          TextFormField(
                            controller: _tutorialNameController,
                            decoration: InputDecoration(
                              labelText:
                                  getTranslated(context, "tutorials_name"),
                            ),
                            validator: (tutorialName) {
                              if (tutorialName.isEmpty) {
                                return getTranslated(
                                    context, "tutorials_name_required");
                              }
                              return null;
                            },
                          ),
                          tutorialEditMode
                              ? IconButton(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    showAppQr();
                                  },
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _tutorialDescriptionController,
                      minLines: 3,
                      maxLines: null,
                      focusNode: textFieldDescriptionFocusNode,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: getTranslated(context, "description"),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value,
                            allowEmptySpaces: true)) {
                          return getTranslated(
                              context, "tutorials_description_required");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    (totlaLessonCount > 0)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getTranslated(
                                        context, "tutorials_total_length") +
                                    " " +
                                    tutorialTotalTime,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  navigateToLessonDetailScreen();
                                },
                                child: Icon(Icons.play_circle_filled,
                                    color: Colors.red[500], size: 46),
                              )
                            ],
                          )
                        : Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Text(
                              getTranslated(
                                  context, "tutorial_nolessonuploaded_message"),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: Colors.black),
                            ),
                          ),
                    SizedBox(height: 10),
                    FutureBuilder(
                        future: rolesListData,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Role>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);
                          return snapshot.hasData
                              ? DropdownButtonFormField<Role>(
                                  decoration: InputDecoration(
                                    labelText: getTranslated(
                                        context, "tutorials_role_editrights"),
                                    border: const OutlineInputBorder(),
                                  ),
                                  value: roleSelected,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  items: snapshot.data
                                      .map<DropdownMenuItem<Role>>(
                                          (Role value) {
                                    return DropdownMenuItem<Role>(
                                      value: value,
                                      child: Text(value.roleName),
                                    );
                                  }).toList(),
                                  onChanged: (Role newValue) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    setState(() {
                                      roleSelected = newValue;
                                      textFieldDescriptionFocusNode.unfocus();
                                    });
                                  },
                                )
                              : Center(child: Loading());
                        }),
                    SizedBox(height: 10),
                    SizedBox(height: 0),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(getTranslated(context, "free")),
                            value: 0,
                            groupValue: freeorPaidRadioValue,
                            onChanged: (value) {
                              setState(() {
                                freeorPaidRadioValue = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: Text(getTranslated(context, "paid")),
                            value: 1,
                            groupValue: freeorPaidRadioValue,
                            onChanged: (value) {
                              setState(() {
                                freeorPaidRadioValue = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    !tutorialEditMode
                        ? Container(
                            child: CustomButton(
                                label: getTranslated(context, "save"),
                                color: Colors.red[600],
                                onPressed: () {
                                  setState(() {
                                    enableAutoValidate = true;
                                  });
                                  if (_formKeyTutorial.currentState
                                      .validate()) {
                                    textFieldDescriptionFocusNode.unfocus();
                                    textFieldTutorialPriceFocusNode.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    saveTutorialCreateHandler();
                                  }
                                }))
                        : Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: CustomButton(
                                          label: getTranslated(context, "save"),
                                          color: Colors.red[600],
                                          onPressed: () {
                                            setState(() {
                                              enableAutoValidate = true;
                                            });
                                            if (_formKeyTutorial.currentState
                                                .validate()) {
                                              textFieldDescriptionFocusNode
                                                  .unfocus();
                                              textFieldTutorialPriceFocusNode
                                                  .unfocus();
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              saveTutorialCreateHandler();
                                            }
                                          }))),
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                    child: CustomButton(
                                        label: getTranslated(context, "delete"),
                                        color: Colors.grey,
                                        onPressed: () {
                                          deleteTutorialHandler();
                                        })),
                              ),
                            ],
                          ),
                  ])),
          _isLoading ? Center(child: Loading()) : SizedBox(),
        ]));
  }
}
