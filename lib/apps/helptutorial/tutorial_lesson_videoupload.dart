import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


class HelpTutorialNetworkHelper {
  static Future uploadHelpTutorialSelectedFile(PlatformFile pf) async {
//---Create http package multipart request object

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
          AppConstants.getServerPath() + "HelpTutorial/UploadLessonVideo"),
    );
//-----add other fields if needed
    request.fields["access_token"] = AppConstants.accessToken;
    request.fields["client_unique_id"] = AppConstants.deviceId;

//-----add selected file with request
    request.files.add(new http.MultipartFile(
        "file_data", pf.readStream, pf.size,
        filename: pf.name));

//-------Send request
    var resp = await request.send();

//------Read response
    String result = await resp.stream.bytesToString();

//-------Your response
    print(result);
    return jsonDecode(result);
  }
}