import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../bloc/conversation_bloc.dart';
import './recorder_state.dart';
import './temp_file.dart';
import './active_codec.dart';

class RecordingWidget extends StatefulWidget {  
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;
  Function onSendMessage;

  RecordingWidget(
      this.bloc, this.withUser, this.me, this.currentRoom, this.onSendMessage);

  @override
  _RecordingWidgetState createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<RecordingWidget> {
  bool initialized = false;
  String recordingFile;
  Track track;
  bool isEnabled = false;
  bool isUploading = false;
  @override
  void initState() {
    ActiveCodec().setCodec(withUI: false, codec: Codec.mp3);
    if (!kIsWeb) {
      var status = Permission.microphone.request();
      status.then((stat) {
        if (stat != PermissionStatus.granted) {
          throw RecordingPermissionException(
              'Microphone permission not granted');
        }
      });
    }
    super.initState();
    tempFile(suffix: '.mp3').then((path) {
      setState(() {
        recordingFile = path;
      });

      track = Track(trackPath: recordingFile);
      print('this is file path');
      print(recordingFile);
      setState(() {});
    });
  }

  Future<bool> init() async {
    if (!initialized) {
      await initializeDateFormatting();
      await UtilRecorder().init();
      ActiveCodec().recorderModule = UtilRecorder().recorderModule;
      ActiveCodec().setCodec(withUI: false, codec: Codec.mp3);

      initialized = true;
    }
    return initialized;
  }

  void _clean() async {
    if (recordingFile != null) {
      try {
        await File(recordingFile).delete();
      } on Exception {
        // ignore
      }
    }
  }

  void enableSubmit() {
    ActiveCodec().setCodec(withUI: false, codec: Codec.mp3);
    setState(() {
      this.isEnabled = true;
    });
  }

  void onDeleteRecording() {
    setState(() {
      this.recordingFile = null;
      this.isEnabled = false;
    });
  }

  @override
  void dispose() {
    _clean();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: double.infinity,
      child: Scaffold(
        body: FutureBuilder(
            initialData: false,
            future: init(),
            builder: (context, snapshot) {
              if (snapshot.data == false) {
                return Container(
                  width: 0,
                  height: 0,
                  color: Colors.white,
                );
              } else {
                // final dropdowns = Dropdowns(
                //     onCodecChanged: (codec) =>
                //         ActiveCodec().setCodec(withUI: false, codec: codec));

                return ListView(
                  children: <Widget>[
                    _buildRecorder(track),
                    // dropdowns,
                    // buildPlayBars(),
                  ],
                );
              }
            }),
      ),
    );
  }

  // Widget buildPlayBars() {
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         children: [
  //           // Left('Asset Playback'),
  //           // AssetPlayer(),
  //           // Left('Remote Track Playback'),
  //           // RemotePlayer(),
  //         ],
  //       ));
  // }

  Widget _buildRecorder(Track track) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RecorderPlaybackController(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SoundRecorderUI(
                    track,
                    // onStart: () => enableSubmit(),
                    onStopped: (_) => enableSubmit(),
                    onDelete: () => onDeleteRecording(),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                FlatButton(
                    disabledColor: Colors.grey,
                    color: Colors.red,
                    child: isUploading
                        ? Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator()),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Sending...'),
                            ],
                          )
                        : Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: isEnabled
                        ? () {
                            Navigator.of(context).pop();
                            widget.onSendMessage(track);
                          }
                        : null),
                // SoundPlayerUI.fromTrack(
                //   track,
                //   enabled: false,
                //   showTitle: true,
                //   audioFocus: AudioFocus.requestFocusAndDuckOthers,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
