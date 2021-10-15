import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/app_constants.dart' as AppConstants;

// ignore: must_be_immutable
class ContactWidget extends StatelessWidget {
  final String alignMsg;
  final String docId;
  final String chatServerUrl;
  dynamic contactObj;
  final String date;
  ContactWidget(this.alignMsg, this.docId, this.chatServerUrl,this.contactObj,this.date);
  @override
  Widget build(BuildContext context) {
    return Container(
    
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        child: 
        Stack(
        children: [
          Card(
          child: Container(
            child: ListTile(
              leading: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(40)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    imageUrl: this.docId.isNotEmpty
                        ? this.chatServerUrl + this.docId
                        : AppConstants.getUserImagePath(),
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              title: GestureDetector(
                onTap: () {
                  launch('tel: ${contactObj['contactMobile']}');
                },
                child: Text(
                  '${contactObj['contactName']}',
                  style: TextStyle(fontSize: 16.0, color: Colors.blue),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              subtitle: Text(
                '${contactObj['contactMobile']}',
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
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
        
      ),
    );
  }
}
