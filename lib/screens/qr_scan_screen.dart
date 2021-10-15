import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:ai_barcode/ai_barcode.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagcash/apps/user_merchant/merchant_detail_screen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_merchant_screen.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/apps/wallet/charge_screen.dart';
import 'package:tagcash/apps/wallet/quickpay_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/apps/coupons/coupon_purchase_screen.dart';
import 'package:tagcash/apps/coupons/coupon_qr_redeem_screen.dart';
import 'package:tagcash/apps/coupons/models/coupon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';

class QrScanScreen extends StatefulWidget {
  final bool returnScan;

  const QrScanScreen({Key key, this.returnScan = false}) : super(key: key);

  @override
  _QrScanScreenState createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  StreamController<String> scanController =
      StreamController<String>.broadcast();

  bool isLoading = false;
  bool transferClickPossible = true;

  bool _isGranted = false;
  bool _useCameraScan = false;

  @override
  void initState() {
    super.initState();

    _requestPermission();

    if (widget.returnScan) {
      _useCameraScan = true;
    }
  }

  void _requestPermission() async {
    if (kIsWeb) {
      setState(() {
        _isGranted = true;
      });
    } else {
      if (await Permission.camera.request().isGranted) {
        setState(() {
          _isGranted = true;
        });
      }
    }
  }

  void scanStateEnable() {
    scanController.add('resume');
  }

  qrScanComplete(String result) {
    print(result);
    if (widget.returnScan) {
      Navigator.pop(context, result);
    } else {
      processScanData(result);
    }
  }

  processScanData(String scanData) {
    if (Validator.isJSON(scanData)) {
      Map resultJson = jsonDecode(scanData);

      if (resultJson.containsKey('action')) {
        String actionInput = resultJson['action'].toUpperCase();
        // print(actionInput);

        if (actionInput == "PAY") {
          // processingPayAction = true;

          // payAmount = resultJson.amount;
          // payAddress = resultJson.address;
          // paytype = resultJson.type;
          // payuser = resultJson.user;
          // payFull_name = resultJson.full_name;
          // payRemarks = resultJson.remarks;
          // payRemarksShow.value = resultJson.remarks;

          // payNotifyCustomData = "";
          // if (resultJson.notify_url_custom_data) {
          //     payNotifyCustomData = JSON.stringify(resultJson.notify_url_custom_data);
          // }

          // varificationComplete.value = false;
          // walletDetailsLoad(resultJson.currency);

        } else if (actionInput == "VOUCHER") {
          //{"action":"VOUCHER","id":sdasdasdasasfasfsdf"}
          //("vouchersManagePage", { scan: true }, "vouchersRedeemPage", { code: resultJson.id });
        } else if (actionInput == "QUICKPAY") {
          // {"action":"QUICKPAY","id":"yVWuFCcMTh"}
          quickpayRedume(resultJson['id']);
        } else if (actionInput == "CHARGE") {
          scanStateEnable();
          showSnackBar(getTranslated(context, 'redeem_from_charge'));
        } else if (actionInput == "COUPON") {
          loadCouponDetails(resultJson);
        } else {
          //not valid
          scanStateEnable();
          showSnackBar(getTranslated(context, 'not_valid_qr_code'));
        }
      } else {
        searchIdentifierList(scanData);
      }
    } else {
      String resultData = scanData;
      if (resultData.indexOf("https://tagcash.com/") != -1) {
        String scanDataCheck =
            resultData.replaceFirst("https://tagcash.com/", '');

        if (scanDataCheck.startsWith('C') || scanDataCheck.startsWith('c')) {
          searchCommunityHandler(scanDataClean(scanDataCheck));
        } else {
          searchUsersHandler(scanDataClean(scanDataCheck));
        }
      } else if (resultData.indexOf("https://web.tagcash.com/") != -1) {
        Uri initialUri = Uri.parse(resultData);
      } else {
        searchIdentifierList(resultData);
      }
    }
  }

  String scanDataClean(String value) {
    String returnId = value.substring(1);
    if (returnId.startsWith('/')) {
      returnId = returnId.substring(1);
    }
    return returnId;
  }

  void searchIdentifierList(String identifierValue) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['search'] = identifierValue;

    Map<String, dynamic> response =
        await NetworkHelper.request('Identifiers/', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      List responseList = response['result'];

      if (responseList.length != 0) {
        if (responseList[0]['linked_to'] == "user") {
          searchUsersHandler(responseList[0]['user_id'].toString());
        } else {
          searchCommunityHandler(responseList[0]['merchant_id'].toString());
        }
      } else {
        scanStateEnable();
        showSnackBar(getTranslated(context, 'not_valid_qr_code'));
      }
    } else {
      scanStateEnable();
      showSnackBar(getTranslated(context, 'not_valid_qr_code'));
    }
  }

  searchUsersHandler(String value) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('user/searchuser', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      List responseList = response['result'];
      scanStateEnable();

      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailUserScreen(
              userData: responseList[0],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailMerchantScreen(
              userData: responseList[0],
            ),
          ),
        );
      }

      // if (_model.activePerspectiveType == "user") {
      //         router.push("userScanMenuPage", { resultUser: resultUser, identifier: identifierValue, datId: Math.random() });
      // } else {
      //         router.push("merchantSearchResultPage", { username: nameUserScaned.value, rating: ratingUserScaned.value, role: roleNameScaned.value, role_status: roleStatusScaned, role_type: roleTypeScaned.value, userID: idUserScaned.value, identifier: identifierValue, datId: Math.random() });
      // }
    } else {
      scanStateEnable();

      showSnackBar(getTranslated(context, 'not_valid_qr_code'));
    }
  }

  searchCommunityHandler(String value) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = value;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success' && response['result'].length != 0) {
      List responseList = response['result'];
      scanStateEnable();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantDetailScreen(
            merchantData: responseList[0],
          ),
        ),
      );

      // router.push("merchantScanMenuPage", { resultUser: resultUser, perspective: "user", identifier: identifierValue, datId: Math.random() });

    } else {
      scanStateEnable();
      showSnackBar(getTranslated(context, 'not_valid_qr_code'));
    }
  }

  void quickpayRedume(String code) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['voucher'] = code;

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/redeem', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      showSimpleDialog(context,
          title: getTranslated(context, 'transaction_confirmed'),
          message:
              '${responseMap['voucher_amount']} ${responseMap['currency_code']}');
    } else {
      if (response['error'] == 'invalid_or_expired_voucher') {
        showSnackBar(getTranslated(context, 'coupon_code_invalid'));
      } else if (response['error'] == 'expired_voucher') {
        showSnackBar(getTranslated(context, 'coupon_code_expired'));
      } else if (response['error'] == 'Insufficient') {
        showSnackBar(
            getTranslated(context, 'vouchers_error_insufficient_funds'));
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
  }

  loadCouponDetails(Map resultJson) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};
    String purchaseId;
    if (resultJson.containsKey('purchase_id')) {
      purchaseId = resultJson['purchase_id'];
      print(purchaseId);
      apiBodyObj['purchase_id'] = purchaseId;
    }
    String couponId = resultJson['coupon_id'];
    print(couponId);
    apiBodyObj['coupon_id'] = couponId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'Coupon/GetCouponDetailsFromId', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    int nowCommunityID = 0;
    if (response['status'] == 'success') {
      Coupon coupon = Coupon.fromJson(response['result']);
      print(coupon.id);
      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'user') {
        Map results = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CouponPurchaseScreen(coupon: coupon),
        ));
        if (results != null && results.containsKey('status')) {
          setState(() {
            String status = results['status'];
            if (status == 'purchaseSuccess') {
              showSnackBar(
                  getTranslated(context, 'coupon_purchased_successfully'));

              Timer timer = new Timer(new Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            }
          });
        }
      } else {
        nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
            .merchantData
            .id;
        print(nowCommunityID.toString() +
            " " +
            coupon.ownerId.toString() +
            " " +
            coupon.redeemStatus.toString());
        if (nowCommunityID == coupon.ownerId) {
          if (purchaseId != null) {
            Map results = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CouponQrRedeemScreen(coupon: coupon, purchaseId: purchaseId),
            ));
            if (results != null && results.containsKey('status')) {
              setState(() {
                String status = results['status'];
                if (status == 'redeemSuccess') {
                  showSnackBar(
                      getTranslated(context, 'coupon_redeemed_successfully'));

                  Timer timer = new Timer(new Duration(seconds: 1), () {
                    Navigator.of(context).pop();
                  });
                }
              });
            }
          } else {
            showSnackBar(getTranslated(context, 'business_cant_redeem_coupon'));
            Timer timer = new Timer(new Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
          }
        } else {
          showSnackBar(getTranslated(context, 'business_cant_redeem_coupon'));
          Timer timer = new Timer(new Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
        }
      }
    } else {
      scanStateEnable();
      if (response['status'] == 'failed' &&
          response['error'] == 'coupon_id_is_required')
        showSnackBar(getTranslated(context, 'coupon_id_required'));
      else if (response['status'] == 'failed' && response['error'] == 'failed')
        showSnackBar(getTranslated(context, 'not_valid_qr_code'));
      else if (response['status'] == 'failed' &&
          response['status'] == 'request_not_completed')
        showSnackBar(getTranslated(context, 'error_occurred'));
      else
        showSnackBar(getTranslated(context, 'not_valid_qr_code'));
    }
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'qr_scan'),
        qr: false,
      ),
      body: _isGranted
          ? Stack(
              children: [
                _useCameraScan
                    ? BarcodeScannerWidget(
                        resultCallback: qrScanComplete,
                        stream: scanController.stream,
                      )
                    : MyQrView(),
                _useCameraScan
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            getTranslated(context, 'position_scanning_area'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    : SizedBox(),
                !widget.returnScan
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          constraints: BoxConstraints(maxWidth: 320),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _useCameraScan = false;
                                    });
                                  },
                                  child: Container(
                                    child: Center(
                                        child: Text(
                                      getTranslated(context, 'my_qr'),
                                      textScaleFactor: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(color: Colors.white),
                                    )),
                                    height: 44,
                                    decoration: BoxDecoration(
                                        color: _useCameraScan
                                            ? Colors.grey
                                            : Colors.red,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8))),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _useCameraScan = true;
                                    });
                                  },
                                  child: Container(
                                    child: Center(
                                        child: Text(
                                      getTranslated(context, 'qr_scanner'),
                                      textScaleFactor: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(color: Colors.white),
                                    )),
                                    height: 44,
                                    decoration: BoxDecoration(
                                        color: _useCameraScan
                                            ? Colors.red
                                            : Colors.grey,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(),
                isLoading ? Center(child: Loading()) : SizedBox(),
              ],
            )
          : Center(
              child: OutlineButton(
                onPressed: () {
                  _requestPermission();
                },
                child: Text(getTranslated(context, 'permission_use_camera')),
              ),
            ),
    );
  }
}

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String result) resultCallback;
  final Stream<String> stream;

  const BarcodeScannerWidget({
    Key key,
    this.resultCallback,
    this.stream,
  }) : super(key: key);

  @override
  _BarcodeScannerWidgetState createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  ScannerController _scannerController;
  StreamSubscription<String> scanStreamSubscription;

  @override
  void initState() {
    super.initState();

    _scannerController = ScannerController(scannerResult: (result) {
      widget.resultCallback(result);
    }, scannerViewCreated: () {
      TargetPlatform platform = Theme.of(context).platform;
      if (TargetPlatform.iOS == platform) {
        Future.delayed(Duration(seconds: 2), () {
          _scannerController.startCamera();
          _scannerController.startCameraPreview();
        });
      } else {
        _scannerController.startCamera();
        _scannerController.startCameraPreview();
      }
    });

    scanStreamSubscription = widget.stream.listen((value) {
      resumeScan();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scanStreamSubscription.cancel();

    _scannerController.stopCameraPreview();
    _scannerController.stopCamera();
  }

  void resumeScan() {
    _scannerController.startCamera();
    _scannerController.startCameraPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _getScanWidgetByPlatform(),
    );
  }

  Widget _getScanWidgetByPlatform() {
    return PlatformAiBarcodeScannerWidget(
      platformScannerController: _scannerController,
    );
  }
}

class MyQrView extends StatefulWidget {
  const MyQrView({
    Key key,
  }) : super(key: key);

  @override
  _MyQrViewState createState() => _MyQrViewState();
}

class _MyQrViewState extends State<MyQrView> {
  GlobalKey globalKey = new GlobalKey();

  String qrDataString;
  bool chargingPossible = false;

  //TODO:use api default wallet
  Wallet defaultWallet = Wallet(walletId: 1, currencyCode: 'PHP');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    String displayData;
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      displayData = "https://tagcash.com/c/" +
          Provider.of<MerchantProvider>(context, listen: false)
              .merchantData
              .id
              .toString();

      if (Provider.of<MerchantProvider>(context, listen: false)
          .merchantData
          .kycVerified) {
        chargingPossible = true;
      }
    } else {
      displayData = "https://tagcash.com/u/" +
          Provider.of<UserProvider>(context).userData.id.toString();
    }

    setState(() {
      qrDataString = displayData;
    });
  }

  quickpayClickHandler() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickpayScreen(
          wallet: defaultWallet,
        ),
      ),
    );
  }

  chargeClickHandler() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChargeScreen(
          wallet: defaultWallet,
        ),
      ),
    );
  }

  Future<void> exportPrintClickHandler() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 5);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (UniversalPlatform.isWeb) {
        final path = await getSavePath();
        final name = 'qrexport.png';
        final mimeType = 'image/png';
        final file = XFile.fromData(pngBytes, name: name, mimeType: mimeType);
        await file.saveTo(path);
      } else {
        final Directory directory = await getTemporaryDirectory();
        final File file = File('${directory.path}/qrexport.png');
        await file.writeAsBytes(pngBytes);

        print(file.path);
        Share.shareFiles(['${directory.path}/qrexport.png'], text: 'QR Image');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Center(
          child: RepaintBoundary(
            key: globalKey,
            child: QrImage(
              data: qrDataString,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              size: 240,
              embeddedImage: AssetImage('assets/images/logo.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(60, 60),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            getTranslated(context, 'show_this_qr_code'),
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          child: Text(getTranslated(context, 'generate_qr')),
          onPressed: () => quickpayClickHandler(),
        ),
        chargingPossible
            ? Padding(
                padding: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  child: Text(getTranslated(context, 'charge')),
                  onPressed: () => chargeClickHandler(),
                ),
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: ElevatedButton(
            child: Text(getTranslated(context, 'print_qr_code')),
            onPressed: () => exportPrintClickHandler(),
          ),
        ),
      ],
    );
  }
}
