import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:toast/toast.dart';

class CompanyLogoScreen extends StatefulWidget {
  String company_logo;

  CompanyLogoScreen({Key key, this.company_logo}) : super(key: key);

  @override
  _CompanyLogoScreenState createState() =>
      _CompanyLogoScreenState(company_logo);
}

enum AppState {
  free,
  picked,
  cropped,
}

class _CompanyLogoScreenState extends State<CompanyLogoScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String company_logo;

  File imageFile;
  List<String> image = [];
  List<String> selectedimages = [];
  String image_File = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    clearToSF();
  }

  _CompanyLogoScreenState(String company_logo) {
    this.company_logo = company_logo;
  }

  clearToSF() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  void uploadImage(String base64) async {
    setState(() {
      isLoading = true;
    });
//
    Map<String, String> apiBodyObj = {};
    apiBodyObj['image'] = base64;
//
    Map<String, dynamic> response =
        await NetworkHelper.request('invoicing/uploadlogoImage', apiBodyObj);

//
    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Company logo',
        ),
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    GestureDetector(
                                      child: image_File == ''
                                          ? Container(
                                              width: 150,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.brown,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      company_logo),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 150,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.brown,
                                                image: DecorationImage(
                                                    image: FileImage(
                                                        File(image_File)),
                                                    fit: BoxFit.fill),
                                              ),
                                            ),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return _ImageDialog(
                                                  selectedImage: selectedimages,
                                                  onSelectedImageChanged:
                                                      (cities) {
                                                    selectedimages = cities;
                                                    setState(() {
                                                      if (selectedimages
                                                              .length !=
                                                          0) {
                                                        image_File = selectedimages
                                                            .reduce((value,
                                                                    element) =>
                                                                value +
                                                                ',' +
                                                                element);
                                                        print(
                                                            'imagefile $image_File');
                                                      }
                                                    });
                                                  });
                                            });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Text(
                            getTranslated(context, 'invoice_uploadlogo'),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            getTranslated(context, 'invoice_uploadlogotxt'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .apply(color: Color(0xFFACACAC)),
                            textAlign: TextAlign.start,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ButtonTheme(
                      height: 45,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: kPrimaryColor,
                        onPressed: () {
                          getSFData();
                        },
                        child: Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }

  getSFData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String base64 = prefs.getString('img_base64');
    print(base64);
    if (base64.isNotEmpty) {
      uploadImage(base64);
    } else {
      Toast.show("Please Select image", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}

class _ImageDialog extends StatefulWidget {
  _ImageDialog({
    this.selectedImage,
    this.onSelectedImageChanged,
  });

  final List<String> selectedImage;
  final ValueChanged<List<String>> onSelectedImageChanged;

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  File imageFile;
  AppState state;
  List<String> _image_path;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    _image_path = widget.selectedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'SELECT IMAGE',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ButtonTheme(
                      height: 45,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: kPrimaryColor,
                        onPressed: () {
                          if (state == AppState.free)
                            _openCamera(context);
                          else if (state == AppState.picked)
                            _cropImage();
                          else if (state == AppState.cropped) _clearImage();
                        },
                        child: Text(
                          'Take Picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    ButtonTheme(
                      height: 45,
                      minWidth: MediaQuery.of(context).size.width,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        color: kPrimaryColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openGallery(context);
                        },
                        child: Text(
                          'Select Picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void _openGallery(BuildContext context) async {
    ImagePicker picker = ImagePicker();

    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    imageFile = File(pickedFile.path);

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    if (decodedImage.width <= 1080 && decodedImage.height <= 1080) {
      List<int> imageBytes = imageFile.readAsBytesSync();
      _image_path.add(imageFile.path);
      widget.onSelectedImageChanged(_image_path);
      String imageB64 = base64Encode(imageBytes);
      addStringToSF(imageB64);
    } else {
      Toast.show(
          "Please select image with size of width less than 640 pixel and height less than 640 pixel.",
          context,
          duration: 5,
          gravity: Toast.BOTTOM);
    }
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    ImagePicker picker = ImagePicker();

    PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);

    imageFile = File(pickedFile.path);

    if (pickedFile != null) {
      setState(() {
        state = AppState.picked;
        _cropImage();
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        maxHeight: 640,
        maxWidth: 640,
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
      print(decodedImage.width);
      print(decodedImage.height);

      if (decodedImage.width <= 640 && decodedImage.height <= 640) {
        List<int> imageBytes = imageFile.readAsBytesSync();
        _image_path.add(imageFile.path);
        widget.onSelectedImageChanged(_image_path);

        String imageB64 = base64Encode(imageBytes);
        addStringToSF(imageB64);
      } else {
        Toast.show(
            "Please select image with size of width less than 640 pixel and height less than 640 pixel.",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM);
      }

      Navigator.of(context).pop();
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;

    setState(() {
      state = AppState.free;
    });
  }

  addStringToSF(String base64) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('img_base64', base64);
  }
}
