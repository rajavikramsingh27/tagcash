import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'dart:io' as Io;
import 'package:path/path.dart' as p;
import 'package:flutter_document_picker/flutter_document_picker.dart';

import '../bloc/conversation_bloc.dart';

class DocumentPicker extends StatefulWidget {
  final ConversationBloc bloc;
  final int withUser;
  final int me;
  final dynamic currentRoom;

  DocumentPicker(this.bloc, this.withUser, this.me, this.currentRoom);
  @override
  _DocumentPickerState createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  String _path = '-';
  bool _pickFileInProgress = false;
  bool _iosPublicDataUTI = true;
  bool _checkByCustomExtension = false;
  bool _checkByMimeType = false;
  final _utiController = TextEditingController(
    text: 'com.sidlatau.example.mwfbak',
  );

  final _extensionController = TextEditingController(
    text: 'mwfbak',
  );

  final _mimeTypeController = TextEditingController(
    //text: 'application/pdf image/png',
    text: 'application/*',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(
          Icons.file_copy,
          color: Colors.white,
        ),
        title: Text(
          'Document',
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          _pickDocument();
        });
  }

  _pickDocument() async {
    String result;
    try {
      setState(() {
        _path = '-';
        this.widget.bloc.convStatus = FutureStatus.pending;
      });

      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: _checkByCustomExtension
            ? _extensionController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList()
            : null,
        allowedUtiTypes: _iosPublicDataUTI
            ? null
            : _utiController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList(),
        allowedMimeTypes: _checkByMimeType
            ? _mimeTypeController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList()
            : null,
      );

      result = await FlutterDocumentPicker.openDocument(params: params);
    } catch (e) {
      print(e);
      result = 'Error: $e';
    } finally {
      setState(() {
        _pickFileInProgress = false;
      });
    }

    setState(() async {
      _path = result;
      Navigator.of(context).pop();
      await uploadFile();
      this.widget.bloc.convStatus = FutureStatus.fulfilled;
    });
  }

  Future uploadFile() async {
    // get extension
    final path = _path;
    final String extension = p.extension(path);
    //get name
    final String fileName = p.basename(path);
    //  date
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('MM-dd');
    final DateFormat formatNew = DateFormat('h:mm a');

    var dayDatetime = formatNew.format(now);

    List<int> imageBytes = await Io.File(_path).readAsBytesSync();
    String imageB64 = base64Encode(imageBytes);

    var docUrl = await widget.bloc.uploadDoc(imageB64, extension);

    var apiObj = {
      "to_tagcash_id": widget.withUser,
      "from_tagcash_id": widget.me,
      "toDocId": widget.withUser,
      'doc_id': docUrl,
      "convId": widget.bloc.currentRoom,
      "type": 8,
      "payload": jsonEncode(
        {
          "fileName": fileName.toString(),
          "extension": extension.toString(),
          "dateTime": dayDatetime.toString(),
        },
      ).toString()
    };
    widget.bloc.sendMessage(apiObj);
  }
}
