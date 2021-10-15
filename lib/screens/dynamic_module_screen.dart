import 'dart:async';
import 'dart:io';

import 'package:tagcash/providers/layout_provider.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:universal_ui/universal_ui.dart';
import "package:universal_html/html.dart" as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:webview_flutter/webview_flutter.dart';

class DynamicModuleScreen extends StatefulWidget {
  final String title;
  final String url;
  final String type;
  final String moduleId;

  const DynamicModuleScreen(
      {Key key, this.title, this.url, this.type, this.moduleId})
      : super(key: key);

  @override
  _DynamicModuleScreenState createState() => _DynamicModuleScreenState();
}

class _DynamicModuleScreenState extends State<DynamicModuleScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  WebViewController _webViewPlatformController;
  html.IFrameElement _iframeElement;

  String moduleUrl;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      isLoading = true;
    });

    if (widget.type == 'flutter' || widget.type == 'html') {
      createAccessToken();
    } else {
      moduleUrl = widget.url;

      setWebPage();
    }
  }

  createAccessToken() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('perspective/CreateMiniAppAccessToken');

    if (response['status'] == 'success') {
      String activeTheme = 'light';
      if (Provider.of<ThemeProvider>(context, listen: false).isDarkMode) {
        activeTheme = 'dark';
      }

      String perspective = 'user';
      if (Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective() ==
          'community') {
        perspective = 'community';
      }

      String accessToken = response['result']['access_token'];
      String url =
          '${widget.url}/?token=$accessToken&server=${AppConstants.getServer()}&type=$perspective&theme=$activeTheme#/';

      moduleUrl = url;
      setWebPage();
    }
  }

  setWebPage() {
    if (UniversalPlatform.isWeb) {
      _iframeElement = html.IFrameElement()
        ..src = moduleUrl
        ..id = 'iframe'
        ..style.border = 'none';
      ui.platformViewRegistry.registerViewFactory(
        'iframeElement${widget.moduleId}',
        (int viewId) => _iframeElement,
      );
    }

    setState(() {});
  }

  loadingStarted() {
    setState(() {
      isLoading = true;
    });
  }

  loadingComplete() {
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> backActionHandle() async {
    if (UniversalPlatform.isWeb) {
      Navigator.pop(context);
    } else {
      if (await _webViewPlatformController.canGoBack()) {
        await _webViewPlatformController.goBack();
      } else {
        Navigator.pop(context);
      }
    }

    return true;
  }

  gotoHome() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => backActionHandle(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Provider.of<PerspectiveProvider>(context)
                      .getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
          leading: Provider.of<LayoutProvider>(context).lauoutMode == 0
              ? BackButton(
                  onPressed: () => backActionHandle(),
                )
              : SizedBox(),
          title: Provider.of<LayoutProvider>(context).lauoutMode == 0
              ? Text(
                  widget.title,
                  style: TextStyle(fontSize: 16),
                  textScaleFactor: 1,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BackButton(
                      onPressed: () => backActionHandle(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.home_outlined,
                      ),
                      onPressed: () => gotoHome(),
                    ),
                  ],
                ),
          actions: [
            if (Provider.of<LayoutProvider>(context).lauoutMode == 0)
              IconButton(
                icon: Icon(
                  Icons.home_outlined,
                ),
                onPressed: () => gotoHome(),
              ),
          ],
        ),
        body: Stack(
          children: [
            if (UniversalPlatform.isWeb && moduleUrl != null) ...[
              Center(child: Loading()),
              HtmlElementView(
                // key: UniqueKey(),
                viewType: 'iframeElement${widget.moduleId}',
              )
            ],
            if ((UniversalPlatform.isAndroid || UniversalPlatform.isIOS) &&
                moduleUrl != null) ...[
              Builder(builder: (BuildContext context) {
                return WebView(
                  initialUrl: moduleUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                    _webViewPlatformController = webViewController;
                  },
                  navigationDelegate: (NavigationRequest request) {
                    // if (!request.url.startsWith('https://flutter.tagcash.com/')) {
                    //   print('blocking navigation to $request}');
                    //   return NavigationDecision.prevent;
                    // }
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    loadingStarted();
                  },
                  onPageFinished: (String url) {
                    loadingComplete();
                  },
                  gestureNavigationEnabled: true,
                );
              }),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ],
        ),
      ),
    );
  }
}
