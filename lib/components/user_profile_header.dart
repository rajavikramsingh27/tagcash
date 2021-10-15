import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/user_profile_edit_screen.dart';
import 'package:tagcash/apps/user_merchant/user_profile_screen.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class UserProfileHeader extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const UserProfileHeader({
    Key key,
    this.mainNavigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Provider.of<LayoutProvider>(context).lauoutMode == 1
          ? Container(
              color: Colors.black,
              height: 56,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      AppConstants.getUserImagePath() +
                          userProvider.userData.id.toString() +
                          "?kycImage=0",
                    ),
                    backgroundColor: Theme.of(context).primaryColorDark,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    mainNavigatorKey != null
                        ? mainNavigatorKey.currentContext
                        : context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(),
                    ),
                  );
                },
              ),
            )
          : Container(
              child: Stack(
                children: [
                  Container(
                    height: 56,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 24, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              AppConstants.getUserImagePath() +
                                  userProvider.userData.id.toString() +
                                  "?kycImage=0",
                            ),
                            backgroundColor: Theme.of(context).primaryColorDark,
                          ),
                          onTap: () {
                            Navigator.push(
                              mainNavigatorKey != null
                                  ? mainNavigatorKey.currentContext
                                  : context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          userProvider.userData.firstName +
                              " " +
                              userProvider.userData.lastName,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          userProvider.userData.id.toString(),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
    });
  }
}
