import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagcash/localization/language_constants.dart';

class ImageSourceSelect extends StatelessWidget {
  final Function(ImageSource) onSelected;

  const ImageSourceSelect({
    Key key,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: BoxConstraints(minHeight: 60),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      Text(
                        getTranslated(context, 'camera'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.camera);
                }),
            SizedBox(width: 30),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints: BoxConstraints(minHeight: 60),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo),
                      Text(
                        getTranslated(context, 'gallery'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.gallery);
                }),
          ],
        ),
      ),
    );
  }
}
