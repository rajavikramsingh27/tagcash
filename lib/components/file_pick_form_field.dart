import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class FilePickFormField extends StatefulWidget {
  FilePickFormField({
    Key key,
    this.icon,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  final Icon icon;
  final String labelText;
  final String hintText;
  final void Function(File) onSaved;
  final void Function(File) onChanged;
  final String Function(File) validator;

  @override
  _FilePickFormFieldState createState() => _FilePickFormFieldState();
}

class _FilePickFormFieldState extends State<FilePickFormField> {
  File _pickedFile;

  String fileName;
  String fileDetails;

  @override
  void initState() {
    super.initState();

    fileName = widget.labelText;
    fileDetails = widget.hintText;
  }

  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      fileName = result.files.single.name;
      fileDetails = '';
      setPickedFIle(file);
    }
  }

  void setPickedFIle(File imageFile) {
    setState(() {
      _pickedFile = imageFile;
    });
    if (widget.onChanged != null) {
      widget.onChanged(imageFile);
    }
  }

  void clearPicked() {
    setState(() {
      _pickedFile = null;
      fileName = widget.labelText;
      fileDetails = widget.hintText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(onSaved: (_) {
      if (widget.onSaved != null) return widget.onSaved(_pickedFile);
      return null;
    }, validator: (_) {
      if (widget.validator != null) return widget.validator(_pickedFile);
      return null;
    }, builder: (state) {
      return Column(
        children: [
          Card(
            child: ListTile(
              leading: widget.icon,
              title: Text(fileName),
              subtitle: Text(fileDetails),
              onTap: () => selectFileClicked(),
              trailing: _pickedFile != null
                  ? IconButton(
                      icon: Icon(Icons.close_outlined),
                      onPressed: () => clearPicked(),
                    )
                  : SizedBox(),
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
