import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class UpdateNewsFeedScreen extends StatefulWidget {
  final String newsfeedId, newsfeedName;
  List<String> images;
  List<String> videos;
  _UpdateNewsFeedScreenState createState() => _UpdateNewsFeedScreenState();

  UpdateNewsFeedScreen(
      {Key key, this.newsfeedId, this.newsfeedName, this.images, this.videos})
      : super(key: key);
}

class _UpdateNewsFeedScreenState extends State<UpdateNewsFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  File imageFile;
  TextEditingController newsfeedText = TextEditingController();

  List<String> _logoList = [''];
  List<String> _logoUrlList = [''];
  List<String> _apilogoUrlList = [''];

  bool isLoading = false, isImage = false;

  int logoindex;

  String image_File = '';
  File videoFile;
  String isType = 'video';

  @override
  void initState() {
    super.initState();
    _logoList.clear();
    _logoUrlList.clear();
    _apilogoUrlList.clear();
    newsfeedText.text = widget.newsfeedName;
    if (widget.images.length != 0) {
      _logoList.addAll(widget.images);
      _logoUrlList.addAll(widget.images);
      _apilogoUrlList.addAll(widget.images);
    } else if (widget.videos.length != 0) {
      _logoList.addAll(widget.videos);
      _logoUrlList.addAll(widget.videos);
      _apilogoUrlList.addAll(widget.videos);
    } else {
      _logoList.add('');
      _logoUrlList.add('');
      _apilogoUrlList.add('');
    }
  }

  getLogo(String url) {
    if (url != null && url != '') {
      return url != null
          ? FileImage(File(url))
          : NetworkImage(
              "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    } else {
      return NetworkImage(
          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Logo");
    }
  }

  Widget showdiag(BuildContext context, data) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: data,
      ),
    );
  }

  Widget dialogContent(BuildContext context, data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: data,
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectedImageContent(call) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              "Select Image", //getTranslated(context, 'select_image'),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: Theme.of(context).textTheme.subtitle1.fontWeight,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Center(
            child: SizedBox(
              width: 40,
              height: 2.5,
              child: DecoratedBox(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                call("camera");
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Take a pic",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                call("image");
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Select Picture",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                call("video");
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Select Video",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Future<void> _getLogoFromGallary([type]) async {
    var selectedLogo;
    isType = type;
    if (type == "camera") {
      widget.videos.clear();
      selectedLogo = await ImagePicker().getImage(
        source: ImageSource.camera,
      );
    } else if (type == "video") {
      widget.videos.clear();

      FilePickerResult result =
          await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null) {
        String filePath = result.files.single.path;

        videoFile = File(filePath);
        isType = type;
      }
    } else {
      selectedLogo = await ImagePicker().getImage(source: ImageSource.gallery);
    }

    if (type == "video") {
      setState(() {
        widget.images.clear();
        _logoList.removeAt(logoindex);
        _logoList.insert(logoindex, 'video');
        _logoUrlList.removeAt(logoindex);
        _logoUrlList.insert(logoindex, 'video');
        widget.videos.add(videoFile.path);
      });
    } else {
      if (selectedLogo != null) {
        setState(() {
          _cropImage(selectedLogo.path, selectedLogo);
        });
      }
//      imageFile = selectedLogo.path;
      var decodedImage =
          await decodeImageFromList(selectedLogo.readAsBytesSync());

      print(decodedImage.width);
      print(decodedImage.height);

      List<int> imageBytes = selectedLogo.readAsBytesSync();

      String imageB64 = base64Encode(imageBytes);

      setState(() {
        isImage = true;
        _logoList.removeAt(logoindex);
        _logoList.insert(logoindex, img2base64(selectedLogo));
        _logoUrlList.removeAt(logoindex);
        _logoUrlList.insert(logoindex, selectedLogo.path);
      });
      print(File(selectedLogo.path).readAsBytes());
    }
  }

  img2base64(image) {
    File imageFile = new File(image.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<Null> _cropImage(String path, var selectedImage) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

      print(decodedImage.width);
      print(decodedImage.height);

      List<int> imageBytes = imageFile.readAsBytesSync();

      String imageB64 = base64Encode(imageBytes);

      setState(() {
        isImage = true;
        _logoList.removeAt(logoindex);
        _logoList.insert(logoindex, img2base64(imageFile));
        _logoUrlList.removeAt(logoindex);
        _logoUrlList.insert(logoindex, imageFile.path);
        widget.images.add(imageFile.path);
      });
      print(File(imageFile.path).readAsBytes());
    }
  }

  void updateNewsFeed(newsfeedId, newsfeedText) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = newsfeedId;
    apiBodyObj['news_feed_text'] = newsfeedText;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/EditNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      String id = response['news_feed_id'];

      if (videoFile != null) {
        uploadVideo(id, videoFile);
      } else if (imageFile != null) {
        if (_logoList.length != 0) {
          for (int i = 0; i < _logoList.length; i++) {
            uploadImage(id, _logoList[i]);
          }
        }
      }
      setState(() {
        Timer(Duration(seconds: 5), () {
          isLoading = false;
          Navigator.pop(context, true);
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadVideo(id, File video) async {
    var request = http.MultipartRequest('POST',
        Uri.parse(AppConstants.getServerPath() + 'NewsFeed/UploadVideo'));
    request.headers['Authorization'] = 'Bearer ${AppConstants.accessToken}';
    request.fields['news_feed_id'] = id;
    request.files
        .add(await http.MultipartFile.fromPath('file_data', video.path));
    var response = await request.send();
    print(response.stream);
    print(response.statusCode);
    final res = await http.Response.fromStream(response);
    print(res.body);
  }

  void uploadImage(id, image) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = id;
    apiBodyObj['image'] = image;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/UploadImage', apiBodyObj);

    if (response['status'] == 'success') {
      print('upload_image' + response['status']);
    } else {}
  }

  void deleteImage(newsfeedId, image_url) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;
    apiBodyObj['image_url'] = image_url;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/RemoveImage', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteVideo(newsfeedId, video_url) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;
    apiBodyObj['uploaded_videos'] = video_url;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/RemoveVideo', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Provider.of<PerspectiveProvider>(context)
                      .getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text('UPDATE NEWSFEED'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home_outlined,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _logoList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                      onTap: () {
                                        logoindex = index;
                                        if (widget.images.length != 0) {
                                          if (_apilogoUrlList[index] != '') {
                                            Widget cancelButton = FlatButton(
                                              child: Text("No"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            );
                                            Widget continueButton = FlatButton(
                                              child: Text("Yes"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteImage(widget.newsfeedId,
                                                    _logoList[index]);
                                              },
                                            );

                                            AlertDialog alert = AlertDialog(
                                              title: Text(""),
                                              content: Text(
                                                  'Are you sure you want to delete this image?'),
                                              actions: [
                                                continueButton,
                                                cancelButton,
                                              ],
                                            );

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    showdiag(
                                                        context,
                                                        selectedImageContent(
                                                            _getLogoFromGallary)));
                                          }
                                        } else if (widget.videos.length != 0) {
                                          if (_apilogoUrlList[index] != '') {
                                            Widget cancelButton = FlatButton(
                                              child: Text("No"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            );
                                            Widget continueButton = FlatButton(
                                              child: Text("Yes"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteVideo(widget.newsfeedId,
                                                    _logoList[index]);
                                              },
                                            );

                                            AlertDialog alert = AlertDialog(
                                              title: Text(""),
                                              content: Text(
                                                  'Are you sure you want to delete this video?'),
                                              actions: [
                                                continueButton,
                                                cancelButton,
                                              ],
                                            );

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    showdiag(
                                                        context,
                                                        selectedImageContent(
                                                            _getLogoFromGallary)));
                                          }
                                        } else {
                                          logoindex = index;
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  showdiag(
                                                      context,
                                                      selectedImageContent(
                                                          _getLogoFromGallary)));
                                        }
                                      },
                                      child: widget.images.length != 0
                                          ? _apilogoUrlList[index] != ''
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        fit: BoxFit.fill,
                                                        image: NetworkImage(
                                                            _apilogoUrlList[
                                                                index])),
                                                  ),
                                                  width: 100.0,
                                                  height: 100.0,
                                                )
                                              : _logoUrlList[index] != null &&
                                                      _logoUrlList[index] != ''
                                                  ? _logoUrlList[index] != null
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey,
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: getLogo(
                                                                  _logoUrlList[
                                                                      index]),
                                                            ),
                                                          ),
                                                          width: 100.0,
                                                          height: 100.0,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .add_photo_alternate_outlined,
                                                          size: 100,
                                                          color: Colors.grey)
                                                  : Icon(
                                                      Icons
                                                          .add_photo_alternate_outlined,
                                                      size: 100,
                                                      color: Colors.grey)
                                          : widget.videos.length != 0
                                              ? Icon(Icons.video_call_rounded,
                                                  size: 100, color: Colors.grey)
                                              : Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 100,
                                                  color: Colors.grey));
                                }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: newsfeedText,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      decoration: InputDecoration(
                        labelText:
                            "Text to be entered here.", //getTranslated(context, 'amount'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value,
                            allowEmptySpaces: true)) {
                          return 'Text required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      onPressed: () async {
                        setState(() {
                          enableAutoValidate = true;
                        });
                        FocusScope.of(context).unfocus();
                        updateNewsFeed(widget.newsfeedId, newsfeedText.text);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          "UPDATE",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ));
  }
}
