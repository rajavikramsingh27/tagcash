import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:camera/camera.dart';

class KYCProfileImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KYCProfileImagePageState();
  }
}

class _KYCProfileImagePageState extends State<KYCProfileImagePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  var kycProfileVerifyStatus;

  List<CameraDescription> cameras;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool imageCapture = true;
  XFile imageFile;
  int cameraIndex = 0;
  IconData lensIcon;

  @override
  void initState() {
    getKYCverifiedImage();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }

    super.dispose();
  }

  getKYCverifiedImage() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['verification_type'] = "profile_image";
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/status', apiBodyObj);

    isLoading = false;

    if (response["status"] == "success") {
      var verifyStatus = response['result'];
      if (verifyStatus[0]["status"] == "pending") {
        kycProfileVerifyStatus = verifyStatus[0]["status"];
      } else if (verifyStatus[0]["status"] == "unapproved") {
        kycProfileVerifyStatus = verifyStatus[0]["status"];
      } else if (verifyStatus[0]["status"] == "approved") {
        kycProfileVerifyStatus = verifyStatus[0]["status"];
      } else {
        kycProfileVerifyStatus = "new";
        setupCameras();
      }
    } else if (response["error"] == "info_missing") {
      kycProfileVerifyStatus = "new";
      setupCameras();
    }
    setState(() {});
  }

  void uploadPassportPhoto() {
    setState(() {
      kycProfileVerifyStatus = "new";
    });
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();

      _controller =
          CameraController(cameras[cameraIndex], ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();

      setState(() {
        lensIcon = _getCameraLensIcon(cameras[cameraIndex]);
      });
    } on CameraException catch (_) {
      print('Error');
    }
  }

  void onNewCameraSelect() async {
    if (_controller != null) {
      await _controller.dispose();
    }
    cameraIndex++;
    if (cameraIndex >= cameras.length) {
      cameraIndex = 0;
    }

    _controller =
        CameraController(cameras[cameraIndex], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();

    setState(() {
      lensIcon = _getCameraLensIcon(cameras[cameraIndex]);
    });

    if (mounted) {
      setState(() {});
    }
  }

  IconData _getCameraLensIcon(CameraDescription selectedCamera) {
    CameraLensDirection lensDirection = selectedCamera.lensDirection;
    switch (lensDirection) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  Future<XFile> takePicture() async {
    if (!_controller.value.isInitialized) {
      // showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);

      return null;
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile file) {
      if (mounted) {
        if (file != null) {
          setState(() {
            imageFile = file;
            imageCapture = false;
          });
        }
      }
    });
  }

  onUploadPhotoClickHandler() async {
    File _receiptFile = File(imageFile.path);
    List<int> receiptImageBytes = _receiptFile.readAsBytesSync();

    Map<String, String> apiBodyObj = {};

    apiBodyObj['upload_type'] = "profile_image";
    apiBodyObj['data'] = base64Encode(receiptImageBytes);

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/Upload', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      getKYCverifiedImage();
    } else {
      if (response['error'] == 'email_verification_pending') {
        var msg = getTranslated(context, "kyc_email_verification_pending");
        showMessage(msg);
      } else if (response['error'] == 'sms_verification_pending') {
        var msg = getTranslated(context, "kyc_sms_verification_pending");
        showMessage(msg);
      } else if (response['error'] == 'already_data_approved') {
        var msg = getTranslated(context, "kyc_already_approved");
        showMessage(msg);
      } else if (response['error'] == 'file_waiting_for_approval') {
        var msg = getTranslated(context, "kyc_file_already_uploaded");
        showMessage(msg);
      } else {
        var msg = getTranslated(context, "error_occurred");
        showMessage(msg);
      }
    }
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          if (kycProfileVerifyStatus == "new") ...[
            if (imageCapture) ...[
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(
                        _controller,
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 80),
                  child: Image.asset('assets/images/profileplace.png'),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.flip_camera_ios),
                  color: Colors.white,
                  onPressed: () => onNewCameraSelect(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.0,
                        ),
                      ),
                    ),
                    onTap: () => onTakePictureButtonPressed(),
                  ),
                ),
              ),
            ],
            if (!imageCapture) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    child: Image.file(
                      File(imageFile.path),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(getTranslated(context, "kyc_retake")),
                            onPressed: () {
                              setState(() {
                                imageFile = null;
                                imageCapture = true;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                                getTranslated(context, "kyc_upload_photo")),
                            onPressed: () {
                              onUploadPhotoClickHandler();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (kycProfileVerifyStatus == "pending") ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        label:
                            getTranslated(context, "kyc_pending_verification"),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (kycProfileVerifyStatus == "unapproved") ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        color: Colors.red,
                        label: getTranslated(context, "kyc_verification_faild"),
                        onPressed: uploadPassportPhoto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (kycProfileVerifyStatus == "approved") ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        label: getTranslated(context, "kyc_verified"),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
