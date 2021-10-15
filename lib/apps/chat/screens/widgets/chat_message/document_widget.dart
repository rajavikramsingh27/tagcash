import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentWidget extends StatelessWidget {
  final Icon matIcon;
  final String chatSerUrl;
  final String docId;
  final String fileName;
  final String ext;
  final String dateTime;
  final String date;

  const DocumentWidget(this.matIcon, this.chatSerUrl, this.docId, this.fileName,
      this.ext, this.dateTime, this.date);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.60,
      child: 
      Stack(
        children: [
          
          Card(
        child: Container(
          padding: EdgeInsets.all(5.0),
          // color: Colors.red[50],
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  // color: Colors.bl[100],
                ),
                child: Row(
                  children: [
                    this.matIcon,
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        launch(this.chatSerUrl + this.docId);
                      },
                      child: Container(
                        width: 155,
                        child: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold
                              // color: Colors.blue,
                              // fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ext.replaceAll(".", "").toUpperCase(),
                    ),
                    // Text(this.dateTime),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
          Positioned(
            child: Text(
              this.date,
              style: TextStyle(
                
                fontSize: 10,
                color: Colors.grey
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
