import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';

import './active_codec.dart';

///
// ignore: must_be_immutable
class RemotePlayer extends StatefulWidget {
  String endpointUrl;

  RemotePlayer(this.endpointUrl);

  @override
  _RemotePlayerState createState() => _RemotePlayerState();
}

class _RemotePlayerState extends State<RemotePlayer> {
  String chatServerUrl = "https://chat.tagcash.com/";

  @override
  Widget build(BuildContext context) {
    return SoundPlayerUI.fromLoader(
      _createRemoteTrack,
      showTitle: true,
      audioFocus: AudioFocus.requestFocusAndDuckOthers,
    );
  }

  Future<Track> _createRemoteTrack(BuildContext context) async {
    Track track;
    // validate codec for example file
    if (ActiveCodec().codec != Codec.mp3) {
      var error = SnackBar(
          backgroundColor: Colors.red,
          content: Text('You must set the Codec to MP3 to'
              'play the "Remote Example File"'));
      ScaffoldMessenger.of(context).showSnackBar(error);
    } else {
      // We have to play an example audio file loaded via a URL
      setState(() {
        track = Track(
            trackPath: this.chatServerUrl + widget.endpointUrl,
            codec: ActiveCodec().codec);
      });

      if (kIsWeb) {
        track.albumArtAsset = null;
      } else if (Platform.isIOS) {
        track.albumArtAsset = 'AppIcon';
      } else if (Platform.isAndroid) {
        track.albumArtAsset = 'AppIcon.png';
      }
    }

    return track;
  }
}
