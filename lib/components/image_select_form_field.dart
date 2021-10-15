import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'image_source_select.dart';

enum ImageFrom { camera, gallery, both }

class ImageSelectFormField extends StatefulWidget {
  ImageSelectFormField({
    Key key,
    this.icon,
    this.labelText,
    this.hintText,
    this.source,
    this.imageURL,
    this.crop = false,
    this.cropMaxWidth = 720,
    this.cropMaxHeight = 720,
    this.compressQuality = 80,
    this.compressFormat = ImageCompressFormat.jpg,
    this.onSaved,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  final Icon icon;
  final String labelText;
  final String hintText;
  final ImageFrom source;
  final String imageURL;
  final bool crop;
  final int cropMaxWidth;
  final int cropMaxHeight;
  final int compressQuality;
  final ImageCompressFormat compressFormat;

  final void Function(File) onSaved;
  final void Function(Uint8List) onChanged;
  final String Function(File) validator;

  @override
  _ImageSelectFormFieldState createState() => _ImageSelectFormFieldState();
}

class _ImageSelectFormFieldState extends State<ImageSelectFormField> {
  File _imageFile;
  final picker = ImagePicker();

  void selectImageClicked() {
    if (widget.source == ImageFrom.both) {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return ImageSourceSelect(
              onSelected: (ImageSource imageSource) => getImage(imageSource),
            );
          });
    } else if (widget.source == ImageFrom.gallery) {
      getImage(ImageSource.gallery);
    } else {
      getImage(ImageSource.camera);
    }
  }

  Future getImage(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      if (kIsWeb) {
        await pickedFile
            .readAsBytes()
            .then((value) => setImage(File(pickedFile.path), value));
      } else {
        if (widget.crop) {
          File croppedFile = await ImageCropper.cropImage(
            sourcePath: pickedFile.path,
            maxWidth: widget.cropMaxWidth,
            maxHeight: widget.cropMaxHeight,
            compressQuality: widget.compressQuality,
            compressFormat: widget.compressFormat,
            androidUiSettings: AndroidUiSettings(
                toolbarColor: Color(0xFFe44933),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
          );

          if (croppedFile != null) {
            await croppedFile
                .readAsBytes()
                .then((value) => setImage(croppedFile, value));
          }
        } else {
          await pickedFile
              .readAsBytes()
              .then((value) => setImage(File(pickedFile.path), value));
        }
      }
    }
  }

  void setImage(File imageFile, Uint8List imageBytes) {
    setState(() {
      _imageFile = imageFile;
    });
    if (widget.onChanged != null) {
      widget.onChanged(imageBytes);
    }
  }

  void clearImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(onSaved: (_) {
      if (widget.onSaved != null) return widget.onSaved(_imageFile);
      return null;
    }, validator: (_) {
      if (widget.validator != null) return widget.validator(_imageFile);
      return null;
    }, builder: (state) {
      return Column(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: Stack(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: double.infinity,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => selectImageClicked(),
                    child: _imageFile == null
                        ? widget.imageURL != null
                            ? CachedNetworkImage(
                                alignment: Alignment.center,
                                imageUrl: widget.imageURL,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                child: ListTile(
                                  leading: widget.icon,
                                  title: Text(widget.labelText),
                                  subtitle: Text(widget.hintText),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                        : kIsWeb
                            ? Image.network(_imageFile.path)
                            : Image.file(_imageFile),
                  ),
                ),
                if (_imageFile != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => clearImage(),
                    ),
                  )
                else
                  SizedBox(),
              ],
            ),
          ),
          state.hasError
              ? Container(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    state.errorText,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.red),
                  ))
              : SizedBox()
        ],
      );
    });
  }
}
