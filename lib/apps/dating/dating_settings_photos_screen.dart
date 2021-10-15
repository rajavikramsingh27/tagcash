import 'package:flutter/material.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/apps/dating/models/dating_profiledetails.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class DatingSettingsPhotoScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  List<UploadedImages> uploadedImages;
  VoidCallback onImageAddedOrDeleted;
  final Function(bool) onLoading;
  final Function(DatingProfileDetails) datingProfileDetails;

  DatingSettingsPhotoScreen(
      {@required this.uploadedImages,
      this.onImageAddedOrDeleted,
      this.onLoading,
      this.datingProfileDetails,
      this.scaffoldKey});

  @override
  _DatingSettingsPhotoScreen createState() => _DatingSettingsPhotoScreen(
      uploadedImages, onImageAddedOrDeleted, onLoading, datingProfileDetails);
}

class _DatingSettingsPhotoScreen extends State<DatingSettingsPhotoScreen> {
  Future<DatingProfileDetails> datingprofileDetailsData;
  bool isLoading = true;
  File _imageFile;
  final picker = ImagePicker();
  List<UploadedImages> uploadedImages;
  VoidCallback onImageAddedOrDeleted;
  Function(bool) onLoading;
  Function(DatingProfileDetails) datingProfileDetails;
  int color = 0XFF686666;
  Uint8List _uploadImageBytes;

  _DatingSettingsPhotoScreen(
      uploadedImages, onImageAddedOrDeleted, onLoading, datingProfileDetails) {
    this.uploadedImages = uploadedImages;
    this.onImageAddedOrDeleted = onImageAddedOrDeleted;
    this.onLoading = onLoading;
    this.datingProfileDetails = datingProfileDetails;
  }

  @override
  void initState() {
    super.initState();
  }

  void showInSnackBar(String value) {
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFe44933),
        content: Text(value),
      ),
    );
    */
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(value),
      backgroundColor: Colors.red[600],
      duration: new Duration(seconds: 3),
    ));
  }

  /*Here we load  profile details to show the image recently uploaded and pass profile details data to Settings Screen*/
  void loadProfileDetails() {
    datingprofileDetailsData = fetchProfileDetails()
        .then((DatingProfileDetails datingprofileDetailsData) {
      setState(() {
        uploadedImages = [];
        uploadedImages = datingprofileDetailsData.profileDetails.uploadedImages;
      });
      datingProfileDetails(
          datingprofileDetailsData); //Using Function we pass latest profile details to Settings Screen
    }).catchError((error) {
      if (error == "profile not created") {}
    });
  }

  Future<DatingProfileDetails> fetchProfileDetails() async {
    onLoading(true);
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/GetMyProfileDetails', apiBodyObj);

    onLoading(false);
    if (response['status'] == 'success') {
      DatingProfileDetails datingprofileDetails =
          DatingProfileDetails.fromJson(response['profile_details']);

      return datingprofileDetails;
    } else if (response['error'] == 'failed_to_get_data') {
      throw ("profile not created");
    } else {
      throw ("error");
    }
  }

  void setMainImageProcess(imageId, index) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    apiBodyObj['image_id'] = imageId.toString();
    onLoading(true);
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/SetMainImage', apiBodyObj);

    onLoading(false);
    if (response["status"] == "success") {
      showInSnackBar(getTranslated(context, "dating_image_main"));
      List<UploadedImages> listUploadedImages1 = uploadedImages;
      uploadedImages = [];
      listUploadedImages1.forEach((images) {
        if (images.mainStatus == 1) {
          images.mainStatus = 0;
        } else {
          if (images.id == imageId) {
            images.mainStatus = 1;
          }
        }
        uploadedImages.add(images);
      });
      setState(() {});

      onImageAddedOrDeleted();
    } else {
      String err;
      if (response['error'] == "switch_to_user_perspective") {
        err = "Switch to User Perspective";
      } else if (response['error'] == "image_id_is_required") {
        err = "Image ID seems missing";
      } else if (response['error'] == "request_not_completed") {
        err = "Request not completed";
      } else {
        err = "Failed";
      }
      showInSnackBar(err);
    }
  }

  void clearImage() {
    setState(() {
      _imageFile = null;
      uploadedImages.removeAt(uploadedImages.length - 1);
      uploadedImages.add(UploadedImages(
          id: null,
          imageFileName: null,
          imageName: null,
          mainStatus: 0,
          uploadedDate: null));
    });
  }

  Future getImage(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (kIsWeb) {
      _imageFile = File(pickedFile.path);

      if (_imageFile != null) {}
      await pickedFile.readAsBytes().then((value) => _uploadImageBytes = value);
      setImage(_imageFile, pickedFile.path);
    } else {
      if (pickedFile != null) {
        File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 720,
          maxHeight: 720,
          compressQuality: 80,
          compressFormat: ImageCompressFormat.png,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Color(0xFFe44933),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        );

        if (croppedFile != null) {
          setImage(_imageFile = croppedFile, croppedFile.path);
        }
      }
    }
  }

  void setImage(File imageFile, String filePath) {
    setState(() {
      _imageFile = imageFile;

      int uploadedImageListLength = uploadedImages.length;
      uploadedImages.removeAt(uploadedImages.length - 1);
      uploadedImages.add(UploadedImages(
          id: 0,
          imageFileName: null,
          imageName: filePath,
          mainStatus: 0,
          uploadedDate: null));
    });
  }

  void selectImageClicked() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined),
                            Text(
                              'Camera',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        getImage(ImageSource.camera);
                      }),
                  SizedBox(width: 30),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 60),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo),
                            Text(
                              'Gallery',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      }),
                ],
              ),
            ),
          );
        });
  }

  void setasMainImage(imageid, mainstatus, index) {
    if (mainstatus == 0) {
      setMainImageProcess(imageid, index);
    } else {
      showInSnackBar(getTranslated(context, "dating_image_alreadymain"));
    }
  }

  void uploadImage() async {
    ;
    onLoading(true);
    Map<String, dynamic> fileData;
    if (_imageFile != null) {
      var file = _imageFile;
      if (!kIsWeb) {
        String basename = path.basename(file.path);
        fileData = {};
        fileData['key'] = 'file_data';
        fileData['fileName'] = basename;
        fileData['path'] = file.path;
      } else {
        /*If the platform is web,path is not available. So we send as bytes*/

        fileData = {};
        fileData['key'] = 'file_data';
        fileData['fileName'] = "dating_image";
        fileData['bytes'] = _uploadImageBytes;
      }
    }
    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/UploadImage', apiBodyObj, fileData);
    if (response['status'] == 'success') {}
    onLoading(false);
    loadProfileDetails();
  }

  void deleteUploadedImage(imageId, index) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['image_id'] = imageId.toString();
    apiBodyObj['module_id'] = AppConstants.activeModule;
    Map<String, dynamic> response =
        await NetworkHelper.request('Dating/DeleteUploadedImage', apiBodyObj);
    if (response['status'] == 'success') {
      onLoading(false);

      showInSnackBar(getTranslated(context, "dating_imagedelete_succeess"));
      setState(() {
        uploadedImages.removeAt(index);
      });
      onImageAddedOrDeleted();
    } else {
      if (response['error'] == "profile_details_not_found") {
        showInSnackBar(
            getTranslated(context, "dating_profiledetails_notfound"));
      } else if (response['error'] == "permission_denied_to_access_image_id") {
        showInSnackBar(getTranslated(context, "dating_image_permissiondenied"));
      } else if (response['error'] == "image_id_not_found") {
        showInSnackBar(getTranslated(context, "dating_imageidnotfound"));
      } else if (response['error'] == "request_not_completed") {
        showInSnackBar(
            getTranslated(context, "dating_profile_requestnotcompleted"));
      } else {
        showInSnackBar(getTranslated(context, "dating_imagedeletion_failed"));
      }
    }
  }

  void deleteImage(imageId, index) {
    if (imageId == 0) {
      /*It means user delete selected image from gallery or camera and not from the server*/
      clearImage();
    } else {
      onLoading(true);
      deleteUploadedImage(imageId, index);
    }
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
    Widget getImageWidget(imageId, imagename, index, mainstatus) {
      if (imageId != 0) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                child: kIsWeb
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: NetworkImage(imagename),
                            fit: BoxFit.contain,
                          ),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(imagename,
                                cacheKey: imageId.toString()),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.grey[400],
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                onTap: () {
                  showImage(imagename, imageId.toString());
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      height: 30,
                      margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                      child: RaisedButton(
                        color: Color(0xFFB8B3B3),
                        onPressed: () {
                          setasMainImage(imageId, mainstatus, index);
                        },
                        child: mainstatus == 0
                            ? Text('Main', style: TextStyle(fontSize: 16))
                            : Text('Main',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.red[700])),
                      ),
                    )),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: Icon(
                      Icons.delete,
                      size: 36,
                    ),
                    color: Colors.red,
                    onPressed: () {
                      deleteImage(imageId, index);
                    },
                  ),
                ),
              ],
            ),
            //SizedBox(height: 10),
          ],
        );
      } else {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  selectImageClicked();
                },
                child: (kIsWeb)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: NetworkImage(imagename),
                            fit: BoxFit.contain,
                          ),
                          border: Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0XFFB6B2B2),
                          image: DecorationImage(
                            image: FileImage(File(imagename)),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Color(0XFFFFFF),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                    child: RaisedButton(
                      color: Color(0xFFB8B3B3),
                      onPressed: () {
                        uploadImage();
                      },
                      child: Text('Upload', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    icon: Icon(
                      Icons.delete,
                      size: 36,
                    ),
                    color: Colors.red,
                    onPressed: () {
                      deleteImage(imageId, index);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }

    return (uploadedImages != null) && (uploadedImages.length > 0)
        ? Stack(
            children: [
              (kIsWeb)
                  ? Container(
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // to disable GridView's scrolling
                        itemCount: uploadedImages.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (uploadedImages[index].imageName != null) {
                            return getImageWidget(
                              uploadedImages[index].id,
                              uploadedImages[index].imageName,
                              index,
                              uploadedImages[index].mainStatus,
                            );
                          } else {
                            return GestureDetector(
                              child: Container(
                                child: Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 42,
                                    color: Colors.white,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFB6B2B2),
                                  border: Border.all(
                                    color: Color(0XFFFFFF),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onTap: () {
                                selectImageClicked();
                              },
                            );
                          }
                        },
                      ),
                    )
                  : GridView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // to disable GridView's scrolling
                      itemCount: uploadedImages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height * .7),
                          crossAxisCount: 2,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (uploadedImages[index].imageName != null) {
                          return getImageWidget(
                            uploadedImages[index].id,
                            uploadedImages[index].imageName,
                            index,
                            uploadedImages[index].mainStatus,
                          );
                        } else {
                          return GestureDetector(
                            child: Container(
                              child: Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0XFFB6B2B2),
                                border: Border.all(
                                  color: Color(0XFFFFFF),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onTap: () {
                              selectImageClicked();
                            },
                          );
                        }
                      },
                    ),
            ],
          )
        : Container();
  }
}
