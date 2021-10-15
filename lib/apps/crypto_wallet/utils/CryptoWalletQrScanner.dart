import 'dart:async';

import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter/material.dart';

class CryptoWalletQrScanner extends StatefulWidget {
  final Function(String result) resultCallback;
  final Stream<String> stream;

  const CryptoWalletQrScanner({
    Key key,
    this.resultCallback,
    this.stream,
  }) : super(key: key);

  @override
  _CryptoWalletQrScannerState createState() => _CryptoWalletQrScannerState();
}

class _CryptoWalletQrScannerState extends State<CryptoWalletQrScanner> {
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
      height: MediaQuery.of(context).size.width,
      width: double.maxFinite,
      child: _getScanWidgetByPlatform(),
    );
  }

  Widget _getScanWidgetByPlatform() {
    return PlatformAiBarcodeScannerWidget(
      platformScannerController: _scannerController,
    );
  }
}
