import 'dart:convert';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:video_compress/video_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as Io;
import 'dart:async';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';

class VaultUploadContentPage extends StatefulWidget {
  final albumId;
  final memberType;
  const VaultUploadContentPage({Key key, this.albumId, this.memberType})
      : super(key: key);
  VaultUploadContentPageState createState() => VaultUploadContentPageState();
}

class VaultUploadContentPageState extends State<VaultUploadContentPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final contentNameInput = TextEditingController();
  final contentNotesInput = TextEditingController();
  final amountInput = TextEditingController();
  final picker = ImagePicker();
  bool enableAutoValidate = false;
  bool uploadContentBo = false;
  bool uploadVideoContentBo = false;
  bool isLoading = false;
  bool compressVideoBo = false;
  bool uploadThumbanilBo = false;
  bool imageCropperBo = false;
  bool paidBo = true;

  PlatformFile pfile;
  PlatformFile thumnailFile;

  Subscription _subscription;
  double progressd = 0;
  List<int> _receiptFile;
  int adTypeIndex = 0;
  File _iconImageFile;

  PickedFile pickedFile;
  Uint8List _iconImageBytes;
  var thumbName;
  var fileExtension;
  var filePath;
  var thumbnailPath;
  String albumId;
  void initState() {
    imageCropperBo = false;
    fileExtension = "";
    paidBo = true;
    progressd = 0;
    albumId = widget.albumId;
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        progressd = progress;
      });
    });
  }

  @override
  void dispose() {
    contentNameInput.dispose();
    contentNotesInput.dispose();
    amountInput.dispose();

    super.dispose();
    _subscription.unsubscribe();
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Uint8List uploadedImage;
  var fileName;
  var kk;
  void attachImageClick() async {
    setState(() {
      imageCropperBo = false;
    });

    FilePickerResult result = await FilePicker.platform.pickFiles(
      withReadStream: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        'mov',
        'wmv',
        'flv',
        'avi',
        'jpg',
        'png',
        'pdf'
      ],
    );
    if (result != null) {
      pfile = result.files.first;
      fileName = pfile.name;
      fileExtension = pfile.extension;

      if (pfile.extension == "mp4" ||
          pfile.extension == "mov" ||
          pfile.extension == "avi" ||
          pfile.extension == "flv" ||
          pfile.extension == "wmv") {
        fileExtension = "video";
      } else if (pfile.extension == "jpg" ||
          pfile.extension == "png" ||
          pfile.extension == "PNG" ||
          pfile.extension == "JPG" ||
          pfile.extension == "JPEG" ||
          pfile.extension == "jpeg" ||
          pfile.extension == "gif") {
        fileExtension = "image";
      }

      if (pfile.extension == "pdf") {
        fileExtension = "pdf";
      }

      setState(() {
        filePath = fileName;
        uploadContentBo = true;
        if (pfile.extension == "mp4") {
          uploadVideoContentBo = true;
        } else {
          uploadVideoContentBo = false;
        }
      });
      if (kIsWeb) {
        //  pfile.readStream.listen((event) {
        //  var  _blogImage= Image.memory(event);
        // notifyListeners();
        // });

      } else {
        if (fileExtension == "image") {
          File croppedFile = await ImageCropper.cropImage(
            sourcePath: pfile.path,
            maxWidth: 256,
            maxHeight: 256,
            compressFormat: ImageCompressFormat.png,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            androidUiSettings: AndroidUiSettings(
                toolbarColor: Color(0xFFe44933),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
          );

          if (croppedFile != null) {
            _iconImageFile = croppedFile;
            setState(() {
              imageCropperBo = true;
            });
          }
          // await croppedFile
          // .readAsBytes()
          // .then((value) => _iconImageBytes = value);
        }
      }
    } else {}
  }

  void attachThumbnailImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      //withReadStream: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      thumnailFile = result.files.first;
      thumbName = thumnailFile.name;
      _receiptFile = thumnailFile.bytes;

      setState(() {
        thumbnailPath = thumbName;
        uploadThumbanilBo = true;
      });
    } else {}
  }

  uploadfile() async {
    if (fileExtension == "") {
      var msg = getTranslated(context, "vault_album_upload");
      showMessage(msg);

      return;
    }
    if (fileExtension == "video" && _receiptFile == null) {
      var msg = getTranslated(context, "vault_thumbnail_upload");
      showMessage(msg);

      return;
    }
    setState(() {
      isLoading = true;
    });
    if (kIsWeb) {
      uploadServer(null);
    } else {
      if (pfile.extension == "mp4") {
        compressVideoBo = true;
        await VideoCompress.setLogLevel(0);
        final MediaInfo info = await VideoCompress.compressVideo(
          pfile.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
          includeAudio: true,
        );
        setState(() {
          compressVideoBo = false;
        });

        uploadServer(info.file);
      } else {
        uploadServer(null);
      }
    }
  }

  uploadServer(file) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(AppConstants.getServerPath() + "Vaults/UploadData"),
    );

    request.fields["access_token"] = AppConstants.accessToken;
    request.fields['album_id'] = albumId.toString();
    request.fields['upload_type'] = fileExtension.toString();

    request.fields['photo_name'] = contentNameInput.text.toString();
    request.fields['photo_notes'] = contentNotesInput.text.toString();

    request.fields['price_wallet_id'] = "1152";
    if (paidBo == false) {
      request.fields['price_amount'] = "0";
    } else {
      request.fields['price_amount'] = amountInput.text.toString();
    }

    if (pfile.extension == "mp4") {
      if (_receiptFile != null) {
        request.fields['thumbnail'] = base64Encode(_receiptFile);
      } else {}
    }
    if (imageCropperBo == true) {
      request.files.add(http.MultipartFile('file_data',
          _iconImageFile.readAsBytes().asStream(), _iconImageFile.lengthSync(),
          filename: pfile.name));
    } else {
      if (file != null) {
        request.files.add(http.MultipartFile(
            'file_data', file.readAsBytes().asStream(), file.lengthSync(),
            filename: pfile.name));
      } else {
        request.files.add(new http.MultipartFile(
            "file_data", pfile.readStream, pfile.size,
            filename: pfile.name));
      }
    }

    var resp = await request.send();

    String result = await resp.stream.bytesToString();

    setState(() {
      isLoading = false;
    });

    var response = jsonDecode(result);

    var status = response["status"];

    if (status == "failed") {
      var error = response["error"];
      setState(() {
        request.files.clear();
        uploadContentBo = false;
        fileExtension = "";
      });
      var errorMsg;
      if (error == 'photo_already_added') {
        errorMsg = getTranslated(context, "vault_photo_already_added");
      } else if (error == 'switch_to_community_perspective') {
        errorMsg = getTranslated(context, "switch_to_community_perspective");
      } else if (error == 'failed_to_upload_album') {
        errorMsg = getTranslated(context, "vault_failed_to_upload_album");
      } else if (error == 'price_should_be_greather_than_0') {
        errorMsg =
            getTranslated(context, "vault_price_should_be_greather_than_0");
      } else if (error == 'file_upload_failed') {
        errorMsg = getTranslated(context, "vault_file_upload_failed");
      } else if (error == 'permission_denied') {
        errorMsg = getTranslated(context, "permission_denied");
      } else if (error == 'request_not_completed') {
        errorMsg = getTranslated(context, "request_not_completed");
      } else if (error == 'upload_type_should_be_image_or_video_or_pdf') {
        errorMsg = getTranslated(
            context, "vault_upload_type_should_be_image_or_video_or_pdf");
      } else {
        errorMsg = error;
      }
      showMessage(errorMsg);
    } else {
      Navigator.of(context).pop({'status': 'createSuccess'});
    }
    return jsonDecode(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "vault_upload_content"),
        ),
        body: AbsorbPointer(
            absorbing: isLoading,
            child: Stack(children: [
              Form(
                  key: _formKey,
                  autovalidateMode: enableAutoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: ListView(
                    padding: EdgeInsets.all(kDefaultPadding),
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
                                    child: uploadContentBo
                                        ? ListTile(
                                            leading: Icon(Icons.note),
                                            title: Text(filePath),
                                          )
                                        : ListTile(
                                            leading: Icon(Icons.note),
                                            title: Text(getTranslated(
                                                context, "vault_video_image")),
                                            subtitle: Text(getTranslated(
                                                context,
                                                "vault_select_content")),
                                          ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      compressVideoBo
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 20,
                                  child: LinearProgressIndicator(
                                    value: progressd / 100,
                                    backgroundColor: Colors.cyan[100],
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.green),
                                  ),
                                ),
                                new Text(getTranslated(
                                    context, "vault_compressing_video")),
                              ],
                            )
                          : SizedBox(),
                      uploadVideoContentBo
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
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
                                            onTap: () => attachThumbnailImage(),
                                            child: Container(
                                              child: uploadThumbanilBo
                                                  ? ListTile(
                                                      leading: Icon(Icons.note),
                                                      title:
                                                          Text(thumbnailPath),
                                                    )
                                                  : ListTile(
                                                      leading: Icon(Icons.note),
                                                      title: Text(getTranslated(
                                                          context,
                                                          "vault_thumbnail")),
                                                      subtitle: Text(getTranslated(
                                                          context,
                                                          "vault_thumbnail_upload")),
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
                                )
                              ],
                            )
                          : SizedBox(),
                      TextFormField(
                        controller: contentNameInput,
                        decoration: InputDecoration(
                            labelText: getTranslated(context, "vault_name")),
                        validator: (titleInput) {
                          if (titleInput.isEmpty) {
                            return getTranslated(
                                context, "vault_title_require");
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        minLines: 2,
                        maxLines: null,
                        controller: contentNotesInput,
                        decoration: InputDecoration(
                            labelText: getTranslated(context, "vault_notes")),
                        validator: (titleInput) {
                          if (titleInput.isEmpty) {
                            return getTranslated(
                                context, "vault_notes_require");
                          }
                          return null;
                        },
                      ),
                      widget.memberType == "1"
                          ? Row(
                              children: [
                                Expanded(
                                    child: RadioListTile(
                                  value: 0,
                                  title: Text(
                                      getTranslated(context, "vault_paid")),
                                  groupValue: adTypeIndex,
                                  onChanged: (value) {
                                    setState(() {
                                      adTypeIndex = value;
                                      paidBo = true;
                                    });
                                  },
                                )),
                                Expanded(
                                    child: RadioListTile(
                                  value: 1,
                                  title: Text(
                                      getTranslated(context, "vault_free")),
                                  groupValue: adTypeIndex,
                                  onChanged: (value) {
                                    setState(() {
                                      adTypeIndex = value;
                                      paidBo = false;
                                    });
                                  },
                                )),
                              ],
                            )
                          : SizedBox(),
                      paidBo
                          ? TextFormField(
                              controller: amountInput,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                  labelText:
                                      getTranslated(context, "vault_price")),
                              validator: (titleInput) {
                                if (titleInput.isEmpty) {
                                  return getTranslated(
                                      context, "vault_price_require");
                                }
                                return null;
                              })
                          : SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          child: Text(getTranslated(context, "vault_save")),
                          onPressed: () {
                            setState(() {
                              enableAutoValidate = true;
                            });
                            if (_formKey.currentState.validate()) {
                              uploadfile();
                            }
                          }),
                    ],
                  )),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ])));
  }
}
