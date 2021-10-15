import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:tagcash/constants.dart';

class AdVideoScreen extends StatefulWidget {
  final String video;
  ValueChanged<String> onFinishPlaying;

  AdVideoScreen({this.video, this.onFinishPlaying});

  @override
  _AdVideoScreenState createState() => _AdVideoScreenState();
}

class _AdVideoScreenState extends State<AdVideoScreen> {
  VideoPlayerController _controller;
  Timer _timer;
  int _start = 20;
  bool startedPlaying = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    playVideo(widget.video);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            widget.onFinishPlaying('success');
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    _timer.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();

    _controller.dispose();
  }

  playVideo(video) async {
    _controller = VideoPlayerController.network(
        //responseMap['moviePath'],
        video);

    _controller.addListener(() {
      if (_controller.value.position.inMilliseconds > 0 && !startedPlaying) {
        startTimer();
        startedPlaying = true;
      }
      if (_controller.value.position == _controller.value.duration) {
        //setState(() {
        _onFinishPlaying();
        //});
      } else {
        setState(() {});
      }
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  Future _onFinishPlaying() async {
    widget.onFinishPlaying('success');
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: Stack(alignment: Alignment.bottomCenter, children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Container(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(_controller),
                        _PlayPauseOverlay(controller: _controller),
                        VideoProgressIndicator(_controller,
                            allowScrubbing: true),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  //child: Center(
                  child: Text("$_start",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                padding: EdgeInsets.only(bottom: 20),
              )
            ]));
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
