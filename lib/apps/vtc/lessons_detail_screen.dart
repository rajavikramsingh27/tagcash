import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_ui/universal_ui.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import 'models/lesson.dart';

class LessonsDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonsDetailScreen({this.lesson});

  @override
  _LessonsDetailScreenState createState() => _LessonsDetailScreenState();
}

class _LessonsDetailScreenState extends State<LessonsDetailScreen> {
  VideoPlayerController _controller;
  bool isLoading = false;
  bool videoPathLoaded = false;
  String moveiPath;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();

    // if (param.freeVideo) {
    // getMoviePath();
    // } else {
    chargingPlayCalll();
    // }
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();

    _controller.dispose();
  }

  void chargingPlayCalll() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['sku'] = widget.lesson.sku;
    apiBodyObj['movieCode'] = widget.lesson.movieCode;

    Map<String, dynamic> response =
        await NetworkHelper.request('vtcLesson/PayLessonPlay', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      getMoviePath();
    } else {
      if (response['error'] == 'insuffcient_balance') {
        confirmAlertShow('Transaction declined due to insufficient balance.');
      } else {
        confirmAlertShow(
            'Unable to process your request at this time. Please try again later.');
      }
    }
  }

  confirmAlertShow(String message) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(getTranslated(context, 'ok')),
              ),
            ],
          );
        });
  }

  getMoviePath() async {
    String sku = widget.lesson.sku;
    String movieCode = widget.lesson.movieCode;

    final http.Response response = await http.get(
      Uri.parse(
          'https://www.vtc.com/services/demoTitle.php?mode=getMobileMoviePath&sku=$sku&movieCode=$movieCode'),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
    );

    Map responseMap = jsonDecode(response.body);
    if (kIsWeb) {
      moveiPath = responseMap['moviePath'];
    } else {
      _controller = VideoPlayerController.network(
        responseMap['moviePath'],
      );

      _controller.addListener(() {
        setState(() {});
      });

      _controller.setLooping(true);
      _controller.initialize().then((_) => setState(() {}));
      _controller.play();
    }
    setState(() {
      videoPathLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            videoPathLoaded
                ? kIsWeb
                    ? Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                          aspectRatio: 3,
                          child: WebVideoElement(
                            autoplay: true,
                            controls: true,
                            src: moveiPath,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Container(
                                  color: Colors.black,
                                  child: VideoPlayer(_controller),
                                ),
                                _PlayPauseOverlay(controller: _controller),
                                VideoProgressIndicator(_controller,
                                    allowScrubbing: true),
                              ],
                            ),
                          ),
                        ),
                      )
                : Center(child: CircularProgressIndicator()),
            Positioned(
              top: 4,
              child: IconButton(
                icon: Icon(
                  Icons.west,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebVideoElement extends StatefulWidget {
  const WebVideoElement(
      {Key key,
      this.src,
      this.width,
      this.height,
      this.startAt,
      this.autoplay,
      this.controls})
      : super(key: key);

  final int width;
  final int height;
  final String src;
  final double startAt;
  final bool autoplay;
  final bool controls;

  @override
  _WebVideoElementState createState() => _WebVideoElementState();
}

class _WebVideoElementState extends State<WebVideoElement> {
  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(widget.src, (int viewId) {
      final video = html.VideoElement()
        ..width = widget.width
        ..height = widget.height
        ..src = widget.src + '#t=${widget.startAt}'
        ..autoplay = widget.autoplay
        ..controls = widget.controls
        ..style.border = 'none';
      return video;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: HtmlElementView(viewType: widget.src),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
