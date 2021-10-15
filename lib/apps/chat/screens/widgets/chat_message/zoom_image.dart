import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/perspective_provider.dart';

class ZoomImageScreen extends StatelessWidget {
  String imageUrl;
  String userName;
  ZoomImageScreen({this.imageUrl, this.userName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                ? Colors.black
                : Colors.blue,
        title: Text(userName),
      ),
      body: Container(
        child: PhotoView(
          initialScale: PhotoViewComputedScale.contained * 1,
          imageProvider: CachedNetworkImageProvider(
              imageUrl),
        ),
      ),
    );
  }
}