import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/merchant_detail_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/user_merchant/models/business_favorite.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({Key key}) : super(key: key);

  @override
  _MembershipsScreenState createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  StreamController<List<BusinessFavorite>> _streamcontroller;
  List<BusinessFavorite> _memberSearch;

  @override
  void initState() {
    super.initState();
    _memberSearch = <BusinessFavorite>[];
    _streamcontroller = StreamController<List<BusinessFavorite>>.broadcast();

    loadAllMerchant();
  }

  loadAllMerchant() {
    loadCommunities().then((res) {
      if (res.length != 0) {
        _memberSearch.addAll(res);
      }

      _streamcontroller.add(_memberSearch);
    });
  }

  Future<List<BusinessFavorite>> loadCommunities() async {
    Map<String, String> apiBodyObj = {};

    // apiBodyObj['show_owner_verified_groups'] = 'true';
    // apiBodyObj['show_custom_groups'] = 'true';

    Map<String, dynamic> response =
        await NetworkHelper.request('user/CustomGroupList', apiBodyObj);

    List responseList = response['result'];

    List<BusinessFavorite> getData = responseList.map<BusinessFavorite>((json) {
      return BusinessFavorite.fromJson(json);
    }).toList();

    return getData;
  }

  onMerchentClickHandler(BusinessFavorite data) {
    Map merchentData = {};
    merchentData['id'] = data.communityId;
    merchentData['community_name'] = data.communityName;
    merchentData['cover_photo'] = data.coverPhoto;
    merchentData['rating'] = data.rating;
    merchentData['members_count'] = data.membersCount;
    merchentData['role_type'] =
        data.roleType == 'non_member' ? '0' : data.roleType;
    merchentData['paid_role_exist'] = data.paidRoleExist;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantDetailScreen(
          merchantData: merchentData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'my_memberships'),
      ),
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder: (BuildContext context,
            AsyncSnapshot<List<BusinessFavorite>> snapshot) {
          return snapshot.hasData
              ? GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisExtent: 160,
                    maxCrossAxisExtent: 360.0,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    // childAspectRatio: .9,
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => onMerchentClickHandler(snapshot.data[index]),
                      behavior: HitTestBehavior.opaque,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(.6),
                                image: snapshot.data[index].coverPhoto != ''
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            snapshot.data[index].coverPhoto),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              top: 86,
                              right: 10,
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data[index].communityName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    Text(
                                      snapshot.data[index].communityId
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      // style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.data[index].roleName ==
                                                'non_member'
                                            ? getTranslated(context,
                                                'contacts_nontagcashmember')
                                            : snapshot.data[index].roleName,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Text(
                                      '${snapshot.data[index].membersCount} ${getTranslated(context, 'members')}',
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.5,
                  children: List.generate(10, (index) {
                    return Container(
                      height: 80,
                      width: 320,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    );
                  }),
                );
        },
      ),
    );
  }
}
