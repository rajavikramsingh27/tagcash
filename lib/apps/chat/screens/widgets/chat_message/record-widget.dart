import 'package:flutter/material.dart';

import '../record-ui/remote-player.dart';

class RecordWidget extends StatelessWidget {
  final String docId;
  final String date;
  final String alignMsg;
  RecordWidget(this.docId, this.date, this.alignMsg);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Stack(
        children: [
          
          RemotePlayer(docId),
          Positioned(
            child: Text(
              this.date,
              style: TextStyle(
                
                fontSize: 10,
              ),
            ),
            right: 10,
            bottom: 5,
          ),
        ],
      ),
    );
  }
}
