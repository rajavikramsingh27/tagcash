import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import './zoom_image.dart';

class ImageWidget extends StatelessWidget {
  final String chatServerUrl;
  final String title;
  final String docId;
  final Color bgColor;
  final String date;
  final String alignMsg;
  ImageWidget(this.chatServerUrl, this.title, this.docId, this.bgColor,
      this.date, this.alignMsg);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ZoomImageScreen(
                    imageUrl: this.chatServerUrl + this.docId,
                    userName: this.title)),
          );
        },
        child: Container(
          // width: 300,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          padding: EdgeInsets.all(2),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
                width: 3, color: Colors.red, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.10),
                blurRadius: 2,
              )
            ],
          ),
          child: Stack(
            children: [
              
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  imageUrl: this.chatServerUrl + this.docId,
                  placeholder: (context, url) => Container(
                      height: 500,
                      width: 200,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Positioned(
                child: Text(
                  this.date,
                  style: TextStyle(color:Colors.white,fontSize: 10,),
                ),
                right: 5,
                bottom: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
