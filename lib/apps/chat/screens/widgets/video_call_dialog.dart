import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class VideoCallDialog extends StatefulWidget {
  Widget videoCallDialogBody;
  VideoCallDialog(this.videoCallDialogBody);

  @override
  _VideoCallDialogState createState() => _VideoCallDialogState();
}

class _VideoCallDialogState extends State<VideoCallDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
                clipBehavior: Clip.none, children: <Widget>[
                  Positioned(
                    right: -40.0,
                    top: -40.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        child: Icon(Icons.close),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                      ),
                      child: kIsWeb
                          ? Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.30,
                                  child: this.widget.videoCallDialogBody,
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                          color: Colors.white54,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.60 *
                                                0.70,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.60 *
                                                0.70,
                                            child: JitsiMeetConferencing(
                                              extraJS: [
                                                // extraJs setup example
                                                '<script>function echo(){console.log("echo!!!")};</script>',
                                                '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                              ],
                                            ),
                                          )),
                                    ))
                              ],
                            )
                          : widget.videoCallDialogBody),
                ],
              );
           
  }
}