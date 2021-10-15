import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/merchant_profile_edit_screen.dart';
import 'package:tagcash/apps/user_merchant/merchant_profile_screen.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class MerchantProfileHeader extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const MerchantProfileHeader({
    Key key,
    this.mainNavigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
        builder: (context, merchantProvider, child) {
      return Provider.of<LayoutProvider>(context).lauoutMode == 1
          ? Container(
              color: Color(0xFFe44933),
              height: 56,
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      AppConstants.getCommunityImagePath() +
                          merchantProvider.merchantData.id.toString(),
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
                      builder: (context) => MerchantProfileScreen(),
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
                    color: Color(0xFFe44933),
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
                              AppConstants.getCommunityImagePath() +
                                  merchantProvider.merchantData.id.toString(),
                            ),
                            backgroundColor: Theme.of(context).primaryColorDark,
                          ),
                          onTap: () {
                            Navigator.push(
                              mainNavigatorKey != null
                                  ? mainNavigatorKey.currentContext
                                  : context,
                              MaterialPageRoute(
                                builder: (context) => MerchantProfileScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Text(
                          merchantProvider.merchantData.name,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          merchantProvider.merchantData.id.toString() +
                              " - " +
                              merchantProvider.merchantData.roleName,
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
