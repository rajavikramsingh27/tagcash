import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/apps/agents/agent_quiz_screen.dart';
import 'package:tagcash/apps/agents/models/quiz_question.dart';
import 'package:video_player/video_player.dart';

class AgentVideoScreen extends StatefulWidget {
  final String video;
  final List<QuizQuestion> questions;

  AgentVideoScreen({this.video, this.questions});

  @override
  _AgentVideoScreenState createState() => _AgentVideoScreenState();
}

class _AgentVideoScreenState extends State<AgentVideoScreen> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.video,
    );

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        print("video ended");
        print(_controller.value.position);
        print(_controller.value.duration);
        if(_controller.value.position.toString()!="0:00:00.000000")/*This checking is required here,otherwise video will not play*/
          _onFinishPlaying();

      } else {
        setState(() {});
      }
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFinishPlaying() async
  {
    print("<---------on Finish Palying------>");
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AgentQuizScreen(questions: widget.questions),
    ));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'success') {
          Navigator.of(context).pop({'status': 'success'});
        } else if (status == 'failed') {
          Navigator.of(context).pop({'status': 'failed'});
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _controller == null
                ? Center(child: CircularProgressIndicator())
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
            ),
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
