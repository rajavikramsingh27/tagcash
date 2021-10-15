import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

class KYCProofofAddressPage extends StatefulWidget {
  @override
  _KYCProofofAddressState createState() => _KYCProofofAddressState();
}

class _KYCProofofAddressState extends State<KYCProofofAddressPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  var kycProofofAddressVerifyStatus;

  List<CameraDescription> cameras;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool imageCapture = true;
  XFile imageFile;
  int cameraIndex = 0;

  @override
  void initState() {
    getKYCverifiedProof();
    super.initState();
  }

  getKYCverifiedProof() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['verification_type'] = "proof_of_address";
    Map<String, dynamic> response =
        await NetworkHelper.request('verification/status', apiBodyObj);

    isLoading = false;

    if (response["status"] == "success") {
      var verifyStatus = response['result'];
      if (verifyStatus[0]["status"] == "pending") {
        kycProofofAddressVerifyStatus = verifyStatus[0]["status"];
      } else if (verifyStatus[0]["status"] == "unapproved") {
        kycProofofAddressVerifyStatus = verifyStatus[0]["status"];
      } else if (verifyStatus[0]["status"] == "approved") {
        kycProofofAddressVerifyStatus = verifyStatus[0]["status"];
      } else {
        kycProofofAddressVerifyStatus = "new";
        setupCameras();
      }
    } else if (response["error"] == "info_missing") {
      kycProofofAddressVerifyStatus = "new";
      setupCameras();
    }
    setState(() {});
  }

  void uploadselfiePhoto() {
    setState(() {
      kycProofofAddressVerifyStatus = "new";
    });
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();

      _controller =
          CameraController(cameras[cameraIndex], ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
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

    if (mounted) {
      setState(() {});
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
    var apiBodyObj = {};
    apiBodyObj['data'] = base64Encode(receiptImageBytes);
    apiBodyObj['upload_type'] = "proof_of_address";
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
        await NetworkHelper.request('verification/Upload', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      setState(() {
        getKYCverifiedProof();
      });
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

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "kyc_proof_of_address"),
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Stack(
          children: [
            if (kycProofofAddressVerifyStatus == "new") ...[
              ListView(
                children: [
                  if (imageCapture) ...[
                    SizedBox(
                      height: 360,
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(
                              _controller,
                              // child: Stack(
                              //   fit: StackFit.expand,
                              //   children: [
                              //     Positioned(
                              //       bottom: 10,
                              //       right: 10,
                              //       child: IconButton(
                              //         icon: Icon(Icons.cached_rounded),
                              //         color: Colors.red,
                              //         onPressed: () => onNewCameraSelect(),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(getTranslated(context, "kyc_capture")),
                      onPressed: () {
                        onTakePictureButtonPressed();
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      getTranslated(context, "kyc_proof_txt"),
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (!imageCapture) ...[
                    SizedBox(
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(imageFile.path),
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  imageFile = null;
                                  imageCapture = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(getTranslated(context, "kyc_upload_photo")),
                      onPressed: () {
                        onUploadPhotoClickHandler();
                      },
                    ),
                  ],
                ],
              ),
            ],
            if (kycProofofAddressVerifyStatus == "pending") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_pending_verification"),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (kycProofofAddressVerifyStatus == "unapproved") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      color: Colors.red,
                      label: getTranslated(context, "kyc_verification_faild"),
                      onPressed: uploadselfiePhoto,
                    ),
                  ),
                ],
              ),
            ],
            if (kycProofofAddressVerifyStatus == "approved") ...[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      label: getTranslated(context, "kyc_verified"),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      )),
    );
  }
}
