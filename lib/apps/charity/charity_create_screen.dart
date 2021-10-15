import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';

class CharityCreateScreen extends StatefulWidget {
  @override
  _CharityCreateScreenState createState() => _CharityCreateScreenState();
}

class _CharityCreateScreenState extends State<CharityCreateScreen> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<FileItem> files = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "advertising"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(kDefaultPadding),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, "enter_title"),
                        labelText: getTranslated(context, "title"),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return getTranslated(context, "please_enter_title");
                        }
                        return null;
                      },
                    ),
                    SizedBox(width: 10),
                    TextFormField(
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: getTranslated(context, "enter_description"),
                        labelText: getTranslated(context, "description"),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return getTranslated(
                              context, "please_enter_description");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    GestureDetector(
                      onTap: () => selectFileClicked(),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 100,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add_circle_sharp,
                                size: 18,
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: 10),
                              Text(getTranslated(context, "attach_file")),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // Expanded(
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        //padding: const EdgeInsets.all(8),
                        itemCount: files.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FileRowItem(files[index].fileName,
                              onDelete: () => removeItem(index));
                        }),
                    SizedBox(height: 30),

                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();

                            createCharityRequestHandler();
                          }
                        },
                        child: Text(getTranslated(context, "create")))
                  ],
                ),
              ),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: Loading()))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  createCharityRequestHandler() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['title'] = titleController.text.toString();
    apiBodyObj['description'] = descriptionController.text.toString();
    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/CreateCharity', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      if (files.length == 0)
        Navigator.of(context).pop({'status': 'success'});
      else {
        for (var i = 0; i < files.length; i++) {
          uploadDoc(response['charity_id'], files[i]);
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      String err = getTranslated(context, "failed_create_charity_request");
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }

  void selectFileClicked() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        String fileName = result.files.single.name;
        files.add(new FileItem(
            fileName: fileName, fileData: result.files.single.bytes));
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      files.removeAt(index);
    });
  }

  uploadDoc(String id, FileItem fileItem) async {
    setState(() {
      isLoading = true;
    });
    var apiBodyObj = {};
    apiBodyObj['charity_id'] = id;
    apiBodyObj['file_data'] = base64Encode(fileItem.fileData);
    apiBodyObj['file_name'] = fileItem.fileName;

    Map<String, dynamic> response =
        await NetworkHelper.request('Charity/UploadCharityFiles', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop({'status': 'success'});
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class FileItem {
  String fileName;
  Uint8List fileData;

  FileItem({this.fileName, this.fileData});
}

class FileRowItem extends StatelessWidget {
  final String fileName;

  final VoidCallback onDelete;

  FileRowItem(this.fileName, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Icon(Icons.file_present),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: kPrimaryColor,
              iconSize: 24,
              tooltip: getTranslated(context, "delete"),
              onPressed: this.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
