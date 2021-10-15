import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/merchant_profile_edit_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog_animated.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/merchant_data.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/image_source_select.dart';
import 'package:path/path.dart' as path;

class MerchantProfileScreen extends StatefulWidget {
  @override
  _MerchantProfileScreenState createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  bool isLoading = false;

  final picker = ImagePicker();
  File _imageFile;

  void onImageChangeClick(bool cover) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ImageSourceSelect(
            onSelected: (ImageSource imageSource) =>
                getImage(imageSource, cover),
          );
        });
  }

  void getImage(ImageSource imageSource, bool cover) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      if (cover) {
        _imageFile = File(pickedFile.path);
        uploadCoverHandler(pickedFile);
      } else {
        uploadAvatarHandler(pickedFile);
      }
    }
  }

  void uploadAvatarHandler(PickedFile _imageFile) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    List<int> slipImageBytes = await _imageFile.readAsBytes();

    apiBodyObj['image'] = base64Encode(slipImageBytes);

    Map<String, dynamic> response =
        await NetworkHelper.request('community/uploadavatar', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      print('success');
    }
  }

  void uploadCoverHandler(PickedFile pickedFile) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['upload_type'] = 'cover_photo';

    Map<String, dynamic> fileData;
    File file = File(pickedFile.path);
    String basename = path.basename(file.path);

    fileData = {};
    fileData['key'] = 'file';
    fileData['fileName'] = basename;
    fileData['path'] = file.path;
    fileData['bytes'] = await pickedFile.readAsBytes();

    Map<String, dynamic> response =
        await NetworkHelper.request('upload', apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      MerchantData merchantData =
          Provider.of<MerchantProvider>(context, listen: false).merchantData;
      merchantData.coverPhoto = response['result'];
      Provider.of<MerchantProvider>(context, listen: false)
          .setMerchantData(merchantData);
    } else {
      showAnimatedDialog(context,
          title: getTranslated(context, 'error'),
          message:
              'Cover image upload Failed. Please upload a PNG or JPG image');
    }
  }

  void editProfileClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantProfileEditScreen(),
      ),
    );
  }

  void verificationClicked() {
    Navigator.pushNamed(context, '/merchantkyc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: Consumer<MerchantProvider>(
          builder: (context, merchantProvider, child) {
        MerchantData merchantData = merchantProvider.merchantData;

        return ListView(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        merchantData.name,
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        merchantData.roleName +
                            ' - ' +
                            merchantData.id.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onImageChangeClick(true),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.black,
                          height: 180,
                          child: _imageFile == null
                              ? Image.network(
                                  Provider.of<MerchantProvider>(context)
                                      .merchantData
                                      .coverPhoto,
                                  fit: BoxFit.cover,
                                )
                              : kIsWeb
                                  ? Image.network(
                                      _imageFile.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      _imageFile,
                                      fit: BoxFit.cover,
                                    ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onImageChangeClick(false),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5.0,
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                                AppConstants.getCommunityImagePath() +
                                    merchantData.id.toString()),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 12,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: verificationClicked,
                        icon: Icon(Icons.admin_panel_settings_sharp),
                        label: Text('VERIFICATION'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          elevation: 5,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: editProfileClicked,
                        icon: Icon(Icons.edit_outlined),
                        label: Text('EDIT PROFILE'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                buildProfileItem(context, 'Members', merchantData.memberCount),
                buildProfileItem(context, 'Staff', merchantData.staffCount),
                merchantData.countryId != '0'
                    ? buildProfileItem(
                        context, 'Category', merchantData.categoryName)
                    : null,
                buildProfileItem(context, 'Country', merchantData.countryName),
                buildProfileItem(
                    context,
                    'Mobile Number',
                    merchantData.countryPhonecode +
                        ' ' +
                        merchantData.communityMobile),
                buildProfileItem(context, 'City', merchantData.communityCity),
                buildProfileItem(
                    context, 'Details', merchantData.communityDescription),
              ],
            ),
          ],
        );
      }),
    );
  }

  Column buildProfileItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          value == '' ? 'Not Set' : value,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
