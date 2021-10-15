import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/apps/dating/models/dating_user_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:tagcash/apps/dating/models/favourite_profile_details.dart';
import 'package:tagcash/apps/dating/send_message_screen.dart';
import 'package:tcard/tcard.dart';
import 'package:flutter/foundation.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class ProfileDetailScreen extends StatefulWidget {
  final DatingUserDetails datingUserDetails;

  const ProfileDetailScreen({Key key, this.datingUserDetails})
      : super(key: key);

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;

  int imageIndex = 0;
  List<ProfileDetailUploadedImages> uploadedImages;
  Future<List<ProfileDetailUploadedImages>> futureUploadedImagesList;
  String showingImageUrl;
  String countryCode;
  String countryId;
  bool _isNoteAddedFlag = false;
  bool _isBlocked = false;
  String blockText = "Block";
  String lastLoggedinTime;
  TCardController _controller = TCardController();

  bool _isFavourite = false;
  String favouriteText = "Favourite";
  bool isLoading = false;
  List<String> reportReasonList = [];
  bool saveClickPossible = true;
  TextEditingController _reportTextInputController;
  TextEditingController _notesTextInputController;
  String reportReasonText;
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  final globalKey = GlobalKey<ScaffoldState>();
  Color _chatSelectedColor = Colors.grey;
  Color _chatSelectedBackgroundColor = Colors.white;

  Color _profileSelectedColor = Colors.white;
  Color _profileSelectedBackgroundColor = Colors.grey;

  Color _reportSelectedColor = Colors.grey;
  Color _reportSelectedBackgroundColor = Colors.white;

  Color _notesSelectedColor = Colors.grey;
  Color _notesSelectedBackgroundColor = Colors.white;

  Color _blockSelectedColor = Colors.grey;
  Color _blockSelectedBackgroundColor = Colors.white;

  Color _favouriteSelectedColor = Colors.grey;

  Color _favouriteSelectedBackgroundColor = Colors.white;

  bool nextPrevImageFlag = true;
  bool _isImagesLoaded = false;
  String gender = "male";

  @override
  void initState() {
    _reportTextInputController = TextEditingController();
    _notesTextInputController = TextEditingController();

    if (widget.datingUserDetails.uploadedImages != null) {
      if (widget.datingUserDetails.uploadedImages.length > 0) {
        showingImageUrl =
            widget.datingUserDetails.uploadedImages[0].imageFileName;
        nextPrevImageFlag = true;
      } else {
        nextPrevImageFlag = false;
      }
    }
    getFavouriteBlockNoteStatus();
    super.initState();
  }

  @override
  void dispose() {
    _reportTextInputController.dispose();
    _notesTextInputController.dispose();
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /*This list is required to get Index*/
    reportReasonList.add(getTranslated(context,"dating_report_badphotos"));
    reportReasonList.add(getTranslated(context,"dating_report_badmessages"));
    reportReasonList.add(getTranslated(context,"dating_report_spam"));
    reportReasonList.add(getTranslated(context, "dating_report_fake"));
    reportReasonList.add(getTranslated(context,"dating_report_others"));
    reportReasonText=reportReasonList[0].toString();
  }

  void showSnackBar(String message) {
    /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFFe44933),
          content: Text(message),
        ),
      );
      */
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[600]));
  }

  /*We call this APi to get Favourite,BLock,Note Status,  and storing visit profile details in backend*/
  void getFavouriteBlockNoteStatus() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/VisitAProfile', apiBodyObj);
    if (response['status'] == "success") {
      FavouriteProfileDetailsData favouriteUserData =
          FavouriteProfileDetailsData.fromJson(response['profile_details']);

      lastLoggedinTime = getLastLoggedinTime(favouriteUserData);
      uploadedImages = favouriteUserData.uploadedImages;
      if (uploadedImages.length < 1) {
        showSnackBar(getTranslated(context, "dating_imagelist_empty"));
        _isImagesLoaded = false;
      } else {
        _isImagesLoaded = true;
      }

      int index = uploadedImages.indexWhere((image) => image.mainStatus == 1);
      //showingImageUrl=uploadedImages.elementAt(index).imageName;

      imageIndex = index;

      if (favouriteUserData.favouriteStatus == 1) {
        _isFavourite = true;
        favouriteText = "Favourited";
        _favouriteSelectedColor = Colors.green;
      } else {
        _isFavourite = false;
        favouriteText = "Favourite";
        _favouriteSelectedColor = Colors.grey;
      }
      if (favouriteUserData.blockedStatus == 1) {
        _isBlocked = true;
        blockText = "Blocked";
        _blockSelectedColor = Colors.red;
      } else {
        _isBlocked = false;
        blockText = "Block";
        _blockSelectedColor = Colors.grey;
      }
      if (favouriteUserData.notes.length > 0) {
        _isNoteAddedFlag = true;
        _notesTextInputController.text = favouriteUserData.notes[0].note;
      } else {
        _isNoteAddedFlag = false;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void reportProcessHandler() async {
    setState(() {
      Navigator.pop(context);
    //  isLoading = true;
    });
    print(reportReasonText);

    int reportReasonIndex = reportReasonList.indexOf(reportReasonText);
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    apiBodyObj['report_type'] = (reportReasonIndex + 1).toString();
    apiBodyObj['additional_note'] = _reportTextInputController.text;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/ReportAProfile', apiBodyObj);
    if (response['status'] == "success") {
      showSnackBar(getTranslated(context, "dating_profilereport_success"));
    } else {
      if (response['error'] == 'request_not_completed') {
        showSnackBar(getTranslated(context, "Failed:Request not completed"));
      } else if (response['error'] == 'invalid_profile_id') {
        showSnackBar(getTranslated(context, "dating_invalid_profileid"));
      } else if (response['error'] == 'you_cannot_report_your_profile') {
        showSnackBar(getTranslated(context, "dating_cannot_reportownprofile"));
      } else {
        showSnackBar(getTranslated(context, "dating_reportprofile_failed"));
      }
    }
    setState(() {
      isLoading = false;
    });

  }

  void noteDeleteClickHandler() async {
    setState(() {
      Navigator.pop(context);
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    apiBodyObj['note'] =
        ""; //For deleting we are sending note parameter as empty;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/AddNotes', apiBodyObj);
    if (response['status'] == "success") {
      showSnackBar(getTranslated(context, "dating_deletenote_success"));
      _notesTextInputController.text = "";
      _isNoteAddedFlag = false;
    } else {
      if (response['error'] == 'failed_to_get_data') {
        showSnackBar(getTranslated(context, "dating_report_failedtogetdata"));
      } else if (response['error'] == 'request_not_completed') {
        showSnackBar(
            getTranslated(context, "dating_profile_requestnotcompleted"));
      } else if (response['error'] == 'switch_to_user_perspective') {
        showSnackBar(getTranslated(context, "dating_switchperspective"));
      } else {
        showSnackBar(getTranslated(context, "dating_unspecified_error"));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void noteSaveProcessHandler() async {
    setState(() {
      Navigator.pop(context);
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    apiBodyObj['note'] = _notesTextInputController.text;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/AddNotes', apiBodyObj);

    if (response['status'] == "success") {
      showSnackBar(getTranslated(context, "dating_notesaved_success"));
      _isNoteAddedFlag = true;
    } else {
      if (response['error'] == 'failed_to_get_data') {
        showSnackBar(getTranslated(context, "dating_report_failedtogetdata"));
      } else if (response['error'] == 'request_not_completed') {
        showSnackBar(
            getTranslated(context, "dating_profile_requestnotcompleted"));
      } else if (response['error'] == 'switch_to_user_perspective') {
        showSnackBar(getTranslated(context, "dating_switchperspective"));
      } else {
        showSnackBar(getTranslated(context, "dating_unspecified_error"));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void changeFavouriteStatusProcessHandler() async {
    Map<String, dynamic> response = null;
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    if (_isFavourite == false) {
      response =
          await NetworkHelper.request('Dating/AddToFavourites', apiBodyObj);
    } else {
      response =
          await NetworkHelper.request('Dating/UnfavouriteProfile', apiBodyObj);
    }
    if (response['status'] == "success") {
      if (_isFavourite == true) {
        showSnackBar(getTranslated(context, "dating_unfavourite_success"));
        _isFavourite = false;
        favouriteText = "Favorite";
      } else {
        showSnackBar(getTranslated(context, "dating_favourite_success"));
        _isFavourite = true;
        favouriteText = "Favorited";
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void changeBlockStatusProcessHandler() async {
    Map<String, dynamic> response = null;
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['profile_id'] = widget.datingUserDetails.id;
    if (_isBlocked == false) {
      response =
          await NetworkHelper.request('Dating/BlockAProfile', apiBodyObj);
    } else {
      response =
          await NetworkHelper.request('Dating/UnblockAProfile', apiBodyObj);
    }
    if (response['status'] == "success") {
      if (_isBlocked == true) {
        showSnackBar(getTranslated(context, "dating_unblock_success"));
        _isBlocked = false;
        blockText = "Block";
      } else {
        showSnackBar(getTranslated(context, "dating_block_success"));
        _isBlocked = true;
        blockText = "Blocked";
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  String getLastLoggedinTime(FavouriteProfileDetailsData favouriteUserData) {
    if (favouriteUserData.dateDiff.months > 0) {
      return favouriteUserData.dateDiff.months.toString() + " month ago";
    } else if (favouriteUserData.dateDiff.days > 0) {
      return favouriteUserData.dateDiff.days.toString() + " days ago";
    } else if (favouriteUserData.dateDiff.hours > 0) {
      return favouriteUserData.dateDiff.hours.toString() + " hours ago";
    } else if (favouriteUserData.dateDiff.minutes > 0) {
      return favouriteUserData.dateDiff.minutes.toString() + " minutes ago";
    } else {
      return "1 hour ago";
    }
  }

  void notesShowBottomSheetClickHandler() {
    showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Form(
                      key: _formKey,
                      autovalidateMode: enableAutoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Stack(children: [
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _notesTextInputController,
                                    minLines: 3,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        labelText:
                                            getTranslated(context, "notes"),
                                        hintText:
                                            getTranslated(context, "notes")),
                                    validator: (value) {
                                      if (!Validator.isRequired(value)) {
                                        return getTranslated(
                                            context, "dating_valid_note");
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  _isNoteAddedFlag
                                      ? Row(
                                          children: [
                                            Expanded(
                                                child: CustomButton(
                                              label: getTranslated(
                                                  context, "update"),
                                              onPressed: saveClickPossible
                                                  ? () {
                                                      setState(() {
                                                        enableAutoValidate =
                                                            true;
                                                      });
                                                      if (_formKey.currentState
                                                          .validate()) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                                FocusNode());
                                                        noteSaveProcessHandler();
                                                      }
                                                    }
                                                  : null,
                                            )),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: CustomButton(
                                                label: getTranslated(
                                                    context, "delete"),
                                                onPressed: () {
                                                  noteDeleteClickHandler();
                                                },
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          child: Container(
                                              child: CustomButton(
                                            label: getTranslated(
                                                context, "dating_save_note"),
                                            //color: AppColors.redButton,
                                            onPressed: saveClickPossible
                                                ? () {
                                                    setState(() {
                                                      enableAutoValidate =
                                                          false;
                                                    });
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode());
                                                      noteSaveProcessHandler();
                                                    }
                                                  }
                                                : null,
                                          )),
                                        )
                                ])
                          ])))));
        });
  }

  void reportShowBottomSheetClickHandler() {
    showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Form(
                      key: _formKey,
                      autovalidateMode: enableAutoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Stack(children: [
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, "dating_reason"),
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    textAlign: TextAlign.left,
                                  ),
                                  DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    icon: Icon(Icons.arrow_downward),
                                    iconSize: 18,
                                    elevation: 12,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    value: reportReasonText,
                                    onChanged: (String newValue) {
                                      reportReasonText = newValue;
                                    },
                                    items: <String>[
                                      getTranslated(
                                          context, "dating_report_badphotos"),
                                      getTranslated(
                                          context, "dating_report_badmessages"),
                                      getTranslated(
                                          context, "dating_report_spam"),
                                      getTranslated(
                                          context, "dating_report_fake"),
                                      getTranslated(
                                          context, "dating_report_others"),
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value.toString(),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  TextFormField(
                                    controller: _reportTextInputController,
                                    minLines: 2,
                                    maxLines: null,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: getTranslated(
                                          context, "dating_additional_note"),
                                      hintText: 'Any',
                                    ),
                                    validator: (value) {
                                      if (!Validator.isRequired(value)) {
                                        return getTranslated(
                                            context, "dating_valid_note");
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                        child: CustomButton(
                                      label: "REPORT",
                                      //color: AppColors.redButton,
                                      onPressed: saveClickPossible
                                          ? () {
                                              setState(() {
                                                enableAutoValidate = false;
                                              });
                                              if (_formKey.currentState
                                                  .validate()) {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                reportProcessHandler();
                                              }
                                            }
                                          : null,
                                    )),
                                  )
                                ])
                          ])))));
        });
  }

  void nextImageNavigationHandler() {
    if (imageIndex < uploadedImages.length - 1) {
      imageIndex++;
      showingImageUrl = uploadedImages.elementAt(imageIndex).imageName;
    }
    setState(() {});
  }

  void previousImageNavigationHandler() {
    if (imageIndex > 0) {
      imageIndex--;
      showingImageUrl = uploadedImages.elementAt(imageIndex).imageName;
    }
    setState(() {});
  }

  void showImage(String imagePath, String imageid) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(20.0),
                child: CachedNetworkImage(
                  cacheKey: imageid,
                  useOldImageOnUrlChange: true,
                  imageUrl: imagePath,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      height: 20,
                      width: 20,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getCards() {
      List<ProfileDetailUploadedImages> images =
          new List<ProfileDetailUploadedImages>();
      uploadedImages.forEach((ProfileDetailUploadedImages imgObj) {
        images.add(imgObj);
      });

      List<Widget> cards = List.generate(
        images.length,
        (int index) {
          return (!kIsWeb)
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 17),
                        blurRadius: 23.0,
                        spreadRadius: -13.0,
                        color: Colors.black54,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: CachedNetworkImage(
                      cacheKey: images[index].id.toString(),
                      imageUrl: images[index].imageName,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[400],
                        ),
                      ),
                      placeholder: (context, url) => Container(
                          height: 20,
                          width: 20,
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    /*
              Image.network(
                images[index],
                fit: BoxFit.cover,
              ),
              */
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 17),
                        blurRadius: 23.0,
                        spreadRadius: -13.0,
                        color: Colors.black54,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: CachedNetworkImage(
                        cacheKey: images[index].id.toString(),
                        imageUrl: images[index].imageName,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                            height: 20,
                            width: 20,
                            child: Center(child: CircularProgressIndicator())),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                );
        },
      );

      return cards;
    }

    Widget profileTextDetailSection = Container(
        child: Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.datingUserDetails.nickName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              )),
          SizedBox(
            height: 0,
          ),
          ConditionalSwitch.single<int>(
            context: context,
            valueBuilder: (BuildContext context) =>
                widget.datingUserDetails.genderId,
            caseBuilders: {
              1: (BuildContext context) => Text(
                  widget.datingUserDetails.age.toString() +
                      "/" +
                      getTranslated(context, "dating_male") +
                      "/ " +
                      widget.datingUserDetails.cityName.toString() +
                      "/" +
                      widget.datingUserDetails.occupation,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  )),
              2: (BuildContext context) => Text(
                  widget.datingUserDetails.age.toString() +
                      "/" +
                      getTranslated(context, "dating_female") +
                      "/ " +
                      widget.datingUserDetails.cityName.toString() +
                      "/" +
                      widget.datingUserDetails.occupation,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  )),
              3: (BuildContext context) => Text(
                  widget.datingUserDetails.age.toString() +
                      "/" +
                      getTranslated(context, "dating_transgender") +
                      "/ " +
                      widget.datingUserDetails.cityName.toString() +
                      "/" +
                      widget.datingUserDetails.occupation,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  )),
            },
            fallbackBuilder: (BuildContext context) =>
                Text(getTranslated(context, "dating_noneofthecase_matched")),
          ),
          SizedBox(
            height: 0,
          ),
          Text(
              lastLoggedinTime ??
                  getTranslated(context, "dating_profile_onehourago"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              )),
          SizedBox(
            height: 20,
          ),
          Text(getTranslated(context, "dating_profile_description"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              )),
          Text(widget.datingUserDetails.description,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    ));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "dating_profile_detail"),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isImagesLoaded
                      ? GestureDetector(
                          child: (!kIsWeb)
                              ? TCard(
                                  cards: getCards(),
                                  size: Size(
                                    MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.height * .40,
                                  ),
                                  controller: _controller,
                                  onForward: (index, info) {
                                    _index = index;
                                  },
                                  onBack: (index, info) {
                                    _index = index;
                                  },
                                  onEnd: () {
                                    _controller.reset(cards: getCards());
                                  },
                                )
                              : Container(
                                  child: Center(
                                    child: TCard(
                                      cards: getCards(),
                                      controller: _controller,
                                      onForward: (index, info) {
                                        _index = index;
                                      },
                                      onBack: (index, info) {
                                        _index = index;
                                      },
                                      onEnd: () {
                                        _controller.reset(cards: getCards());
                                      },
                                    ),
                                  ),
                                ),
                          onTap: () {
                            showImage(
                                uploadedImages.elementAt(_index).imageName,
                                uploadedImages.elementAt(_index).id.toString());
                          },
                        )
                      : Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * .80,
                            height: MediaQuery.of(context).size.height * .40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 17),
                                  blurRadius: 23.0,
                                  spreadRadius: -13.0,
                                  color: Colors.black54,
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 20, 8, 10),
                    child: Center(
                      child: (!kIsWeb)
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.4,
                                    //  height: 40,
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.person,
                                        color: _profileSelectedColor,
                                        size: 32,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        bottom: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        right: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        left: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                      ),
                                      color: _profileSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _profileSelectedBackgroundColor =
                                          Colors.grey;
                                      _profileSelectedColor = Colors.white;
                                      _chatSelectedBackgroundColor =
                                          Colors.white;
                                      _chatSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.white;
                                      _reportSelectedColor = Colors.grey;
                                      _notesSelectedBackgroundColor =
                                          Colors.white;
                                      _notesSelectedColor = Colors.grey;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.4,
                                    // height: 40,
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),

                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.chat,
                                        color: _chatSelectedColor,
                                        size: 30,
                                      ),
                                    ),

                                    decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78))),
                                      color: _chatSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _chatSelectedBackgroundColor =
                                          Colors.grey;
                                      _chatSelectedColor = Colors.white;
                                      _profileSelectedBackgroundColor =
                                          Colors.white;
                                      _profileSelectedColor = Colors.grey;
                                      _notesSelectedBackgroundColor =
                                          Colors.white;
                                      _notesSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.white;
                                      _reportSelectedColor = Colors.grey;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DatingISendMessageScreen(
                                            profileId:
                                                widget.datingUserDetails.id,
                                            profileNickname: widget
                                                .datingUserDetails.nickName,
                                            datingUserDetails:
                                                widget.datingUserDetails,
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.4,
                                    //    height: 40,
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.favorite,
                                        color: _favouriteSelectedColor,
                                        size: 30,
                                      ),
                                    ),

                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        bottom: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        right: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        left: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                      ),
                                      color: _favouriteSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _profileSelectedBackgroundColor =
                                          Colors.white;
                                      _profileSelectedColor = Colors.grey;
                                      _chatSelectedBackgroundColor =
                                          Colors.white;
                                      _chatSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.white;
                                      _reportSelectedColor = Colors.grey;
                                      _notesSelectedBackgroundColor =
                                          Colors.white;
                                      _notesSelectedColor = Colors.grey;
                                      _isFavourite
                                          ? _favouriteSelectedColor =
                                              Colors.grey
                                          : _favouriteSelectedColor =
                                              Colors.green;
                                      changeFavouriteStatusProcessHandler();
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.4,
                                    //   height: 40,

                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.block,
                                        color: _blockSelectedColor,
                                        size: 30,
                                      ),
                                    ),

                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        bottom: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                      ),
                                      color: _blockSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _profileSelectedBackgroundColor =
                                          Colors.white;
                                      _profileSelectedColor = Colors.grey;
                                      _chatSelectedBackgroundColor =
                                          Colors.white;
                                      _chatSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.white;
                                      _reportSelectedColor = Colors.grey;
                                      _notesSelectedBackgroundColor =
                                          Colors.white;
                                      _notesSelectedColor = Colors.grey;
                                      _isBlocked
                                          ? _blockSelectedColor = Colors.grey
                                          : _blockSelectedColor = Colors.red;
                                      changeBlockStatusProcessHandler();
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.2,
                                    //   height: 40,
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),

                                    child: Container(
                                      padding: const EdgeInsets.all(0.0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.report_problem,
                                          color: _reportSelectedColor,
                                          size: 30,
                                        ),
                                      ),
                                    ),

                                    decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78))),
                                      color: _reportSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _chatSelectedBackgroundColor =
                                          Colors.white;
                                      _chatSelectedColor = Colors.grey;
                                      _profileSelectedBackgroundColor =
                                          Colors.white;
                                      _profileSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.grey;
                                      _reportSelectedColor = Colors.white;
                                      _notesSelectedBackgroundColor =
                                          Colors.white;
                                      _notesSelectedColor = Colors.grey;
                                      reportShowBottomSheetClickHandler();
                                    });
                                  },
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 6.2,
                                    //  height: 40,
                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Container(
                                      padding: const EdgeInsets.all(0.0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.note_add,
                                          color: _notesSelectedColor,
                                          size: 30,
                                        ),
                                      ),
                                    ),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        bottom: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        right: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                        left: BorderSide(
                                            color: Color(0XFF7E7A78)),
                                      ),
                                      color: _notesSelectedBackgroundColor,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _chatSelectedBackgroundColor =
                                          Colors.white;
                                      _chatSelectedColor = Colors.grey;
                                      _profileSelectedBackgroundColor =
                                          Colors.white;
                                      _profileSelectedColor = Colors.grey;
                                      _reportSelectedBackgroundColor =
                                          Colors.white;
                                      _reportSelectedColor = Colors.grey;
                                      _notesSelectedBackgroundColor =
                                          Colors.grey;
                                      _notesSelectedColor = Colors.white;
                                      notesShowBottomSheetClickHandler();
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      //  height: 40,
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.person,
                                          color: _profileSelectedColor,
                                          size: 32,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          right: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          left: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                        ),
                                        color: _profileSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _profileSelectedBackgroundColor =
                                            Colors.grey;
                                        _profileSelectedColor = Colors.white;
                                        _chatSelectedBackgroundColor =
                                            Colors.white;
                                        _chatSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.white;
                                        _reportSelectedColor = Colors.grey;
                                        _notesSelectedBackgroundColor =
                                            Colors.white;
                                        _notesSelectedColor = Colors.grey;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      // height: 40,
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.chat,
                                          color: _chatSelectedColor,
                                          size: 30,
                                        ),
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                                color: Color(0XFF7E7A78)),
                                            bottom: BorderSide(
                                                color: Color(0XFF7E7A78))),
                                        color: _chatSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _chatSelectedBackgroundColor =
                                            Colors.grey;
                                        _chatSelectedColor = Colors.white;
                                        _profileSelectedBackgroundColor =
                                            Colors.white;
                                        _profileSelectedColor = Colors.grey;
                                        _notesSelectedBackgroundColor =
                                            Colors.white;
                                        _notesSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.white;
                                        _reportSelectedColor = Colors.grey;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DatingISendMessageScreen(
                                              profileId:
                                                  widget.datingUserDetails.id,
                                              profileNickname: widget
                                                  .datingUserDetails.nickName,
                                              datingUserDetails:
                                                  widget.datingUserDetails,
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      //    height: 40,
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.favorite,
                                          color: _favouriteSelectedColor,
                                          size: 30,
                                        ),
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          right: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          left: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                        ),
                                        color:
                                            _favouriteSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _profileSelectedBackgroundColor =
                                            Colors.white;
                                        _profileSelectedColor = Colors.grey;
                                        _chatSelectedBackgroundColor =
                                            Colors.white;
                                        _chatSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.white;
                                        _reportSelectedColor = Colors.grey;
                                        _notesSelectedBackgroundColor =
                                            Colors.white;
                                        _notesSelectedColor = Colors.grey;
                                        _isFavourite
                                            ? _favouriteSelectedColor =
                                                Colors.grey
                                            : _favouriteSelectedColor =
                                                Colors.green;
                                        changeFavouriteStatusProcessHandler();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      //   height: 40,

                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.block,
                                          color: _blockSelectedColor,
                                          size: 30,
                                        ),
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                        ),
                                        color: _blockSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _profileSelectedBackgroundColor =
                                            Colors.white;
                                        _profileSelectedColor = Colors.grey;
                                        _chatSelectedBackgroundColor =
                                            Colors.white;
                                        _chatSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.white;
                                        _reportSelectedColor = Colors.grey;
                                        _notesSelectedBackgroundColor =
                                            Colors.white;
                                        _notesSelectedColor = Colors.grey;
                                        _isBlocked
                                            ? _blockSelectedColor = Colors.grey
                                            : _blockSelectedColor = Colors.red;
                                        changeBlockStatusProcessHandler();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      //   height: 40,
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),

                                      child: Container(
                                        padding: const EdgeInsets.all(0.0),
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.report_problem,
                                            color: _reportSelectedColor,
                                            size: 30,
                                          ),
                                        ),
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: Color(0XFF7E7A78)),
                                            top: BorderSide(
                                                color: Color(0XFF7E7A78)),
                                            bottom: BorderSide(
                                                color: Color(0XFF7E7A78))),
                                        color: _reportSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _chatSelectedBackgroundColor =
                                            Colors.white;
                                        _chatSelectedColor = Colors.grey;
                                        _profileSelectedBackgroundColor =
                                            Colors.white;
                                        _profileSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.grey;
                                        _reportSelectedColor = Colors.white;
                                        _notesSelectedBackgroundColor =
                                            Colors.white;
                                        _notesSelectedColor = Colors.grey;
                                        reportShowBottomSheetClickHandler();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      //  height: 40,
                                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: Container(
                                        padding: const EdgeInsets.all(0.0),
                                        child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.note_add,
                                            color: _notesSelectedColor,
                                            size: 30,
                                          ),
                                        ),
                                      ),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          bottom: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          right: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                          left: BorderSide(
                                              color: Color(0XFF7E7A78)),
                                        ),
                                        color: _notesSelectedBackgroundColor,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _chatSelectedBackgroundColor =
                                            Colors.white;
                                        _chatSelectedColor = Colors.grey;
                                        _profileSelectedBackgroundColor =
                                            Colors.white;
                                        _profileSelectedColor = Colors.grey;
                                        _reportSelectedBackgroundColor =
                                            Colors.white;
                                        _reportSelectedColor = Colors.grey;
                                        _notesSelectedBackgroundColor =
                                            Colors.grey;
                                        _notesSelectedColor = Colors.white;
                                        notesShowBottomSheetClickHandler();
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                  profileTextDetailSection
                ],
              ),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
