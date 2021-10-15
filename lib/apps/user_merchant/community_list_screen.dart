import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/merchant_detail_screen.dart';
import 'package:tagcash/apps/user_merchant/models/all_merchant.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'package:tagcash/models/app_constants.dart' as AppConstants;

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({Key key}) : super(key: key);

  @override
  _CommunityListScreenState createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  StreamController<List<AllMerchant>> _streamcontroller;
  List<AllMerchant> _memberList;
  final scrollController = ScrollController();
  bool hasMore;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _memberList = [];
    _streamcontroller = StreamController<List<AllMerchant>>.broadcast();

    _isLoading = false;
    hasMore = true;

    loadMembersList();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        loadMembersList();
      }
    });
  }

  searchClicked(String searchKey) {
    loadMembersList(clearCachedData: true, searchValue: searchKey);
  }

  loadMembersList({bool clearCachedData = false, String searchValue = ''}) {
    if (clearCachedData) {
      _memberList = [];
      _streamcontroller.add(_memberList);

      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;

    memberListLoad(searchValue).then((res) {
      _isLoading = false;
      _memberList.addAll(res);
      hasMore = (res.length == 20);

      _streamcontroller.add(_memberList);
    });
  }

  Future<List<AllMerchant>> memberListLoad(String searchValue) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['count'] = '20';
    apiBodyObj['offset'] = _memberList.length.toString();

    if (searchValue != '') {
      apiBodyObj['name'] = searchValue;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    List responseList = response['result'];

    List<AllMerchant> getData = responseList.map<AllMerchant>((json) {
      return AllMerchant.fromJson(json);
    }).toList();

    return getData;
  }

  onMerchentClickHandler(AllMerchant data) {
    Map merchentData = {};
    merchentData['id'] = data.id;

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
        onSearch: searchClicked,
        title: getTranslated(context, 'businesses'),
      ),
      body: StreamBuilder(
        stream: _streamcontroller.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<AllMerchant>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          if (!snapshot.hasData) {
            return Center(child: Loading());
          } else {
            return GridView.builder(
              controller: scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 160,
                maxCrossAxisExtent: 360.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // childAspectRatio: .9,
              ),
              itemCount: snapshot.data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < snapshot.data.length) {
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
                                    snapshot.data[index].id.toString(),
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
                                      snapshot.data[index].roleName == ''
                                          ? 'Non Member'
                                          : snapshot.data[index].roleName,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data[index].membersCount} Members',
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
                } else if (hasMore) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          }
        },
      ),
    );
  }
}
