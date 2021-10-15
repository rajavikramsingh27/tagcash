import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/agents/agent_apply_screen.dart';
import 'package:tagcash/apps/user_merchant/user_profile_edit_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/image_source_select.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = false;

  final picker = ImagePicker();
  File _imageFile;

  void onUserImagegChangeClick() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ImageSourceSelect(
            onSelected: (ImageSource imageSource) => getImage(imageSource),
          );
        });
  }

  void getImage(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      uploadAvatarHandler(pickedFile);
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
        await NetworkHelper.request('user/uploadavatar', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      print('success');
    }
  }

  void editProfileClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileEditScreen(),
      ),
    );
  }

  void becomeAgentClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentApplyScreen(),
      ),
    );
  }

  void verificationClicked() {
    Navigator.pushNamed(context, '/userkyc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        UserData userData = userProvider.userData;

        return ListView(
          padding: EdgeInsets.all(10),
          children: [
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onUserImagegChangeClick,
                child: Stack(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
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
                          image: _imageFile == null
                              ? NetworkImage(
                                  AppConstants.getUserImagePath() +
                                      userData.id.toString() +
                                      "?kycImage=0",
                                )
                              : kIsWeb
                                  ? NetworkImage(_imageFile.path)
                                  : FileImage(_imageFile),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    isLoading ? Center(child: Loading()) : SizedBox(),
                  ],
                ),
              ),
            ),
            Text(
              userData.firstName + ' ' + userData.lastName,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Text(
              userData.id.toString(),
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
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
            if (Provider.of<UserProvider>(context).userData.countryCode == 'PH')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: becomeAgentClicked,
                    icon: Icon(Icons.person_outline),
                    label: Text('BECOME AN AGENT'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      elevation: 5,
                    ),
                  ),
                ),
              ),
            buildProfileItem(context, 'Username', '@${userData.userName}'),
            buildProfileItem(context, 'Display Name', userData.nickName),
            buildProfileItem(context, 'Email', userData.email),
            buildProfileItem(context, 'Country', userData.countryName),
            buildProfileItem(context, 'Mobile Number',
                userData.countryCallingCode + ' ' + userData.mobile),
            if (userData.countryCode == 'PH')
              buildProfileItem(context, 'Region', userData.userRegion),
            buildProfileItem(context, 'City', userData.userCity),
            buildProfileItem(context, 'Date of Birth', userData.userDob),
            buildProfileItem(context, 'Gender', userData.userGender),
            buildProfileItem(context, 'Details', userData.profileBio),
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
