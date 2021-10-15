import 'package:flutter/material.dart';
import 'package:tagcash/apps/newsfeed/models/likeuser.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

class LikeListScreen extends StatefulWidget {
  final String newsfeedId;

  @override
  _LikeListScreenState createState() => _LikeListScreenState();

  LikeListScreen({Key key, this.newsfeedId}) : super(key: key);
}

class _LikeListScreenState extends State<LikeListScreen> {
  bool isLoading = false;
  String nowCommunityID = '0';
  List<LikeUser> getLikeUserData = new List<LikeUser>();

  @override
  void initState() {
    super.initState();
    getCommentList();
  }

  void getCommentList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = widget.newsfeedId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'NewsFeed/ListNewsFeedLikeDetail', apiBodyObj);

    print(response);

    if (response['status'] == 'success') {
      print(response);
      if (response['result'] != null) {
        List responseList = response['result'][0]['liked_by_user'];
        getLikeUserData = responseList.map<LikeUser>((json) {
          return LikeUser.fromJson(json);
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData
          .id
          .toString();
    } else {
      nowCommunityID = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();
    }

    print('got userId: $nowCommunityID');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                ? Colors.black
                : Color(0xFFe44933),
        title: Text('LIKE'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_outlined,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
                itemCount: getLikeUserData.length,
                itemBuilder: (context, i) {
                  return InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getLikeUserData[i].name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.justify,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
