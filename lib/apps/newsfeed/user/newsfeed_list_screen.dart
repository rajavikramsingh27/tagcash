import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tagcash/apps/newsfeed/models/comment.dart';
import 'package:tagcash/apps/newsfeed/models/newsfeeds.dart';
import 'package:tagcash/apps/newsfeed/user/comment_replies_screen.dart';
import 'package:tagcash/apps/newsfeed/user/update_newsfeed_screen.dart';
import 'package:tagcash/apps/newsfeed/user/view_more_comment_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:video_player/video_player.dart';

import 'create_newsfeed_screen.dart';
import 'edit_comment_screen.dart';
import 'like_list_screen.dart';

class NewsFeedListScreen extends StatefulWidget {
  @override
  _NewsFeedListScreenState createState() => _NewsFeedListScreenState();
}

class _NewsFeedListScreenState extends State<NewsFeedListScreen> {
  bool isLoading = false;
  List<NewsFeeds> getNewsFeedData = new List<NewsFeeds>();
  String nowCommunityID = '0';
  final _formKey = GlobalKey<FormState>();
  TextEditingController tipAmountText = TextEditingController();
  TextEditingController tipMessageText = TextEditingController();
  bool enableAutoValidate = false;

  List<Wallet> walletData = [];
  Future<List<Wallet>> walletDataList;
  String ownerType = '';
  Wallet selectedwallet;

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
//    getWalletData();
    walletDataList = loadWalletList();
    getNewsFeedList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      ownerType = 'community';
      nowCommunityID = Provider.of<MerchantProvider>(context, listen: false)
          .merchantData
          .id
          .toString();
    } else {
      ownerType = 'user';
      nowCommunityID = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();
    }

    print('got userId: $nowCommunityID');
  }

  void getNewsFeedList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/ListAllNewsFeed');

    print(response);

    if (response['status'] == 'success') {
      print(response);
      if (response['result'] != null) {
        List responseList = response['result'];

        getNewsFeedData = responseList.map<NewsFeeds>((json) {
          return NewsFeeds.fromJson(json);
        }).toList();

        for (int i = 0; i < getNewsFeedData.length; i++) {
          List<Comment> comments = getNewsFeedData[i].comment;
          List<Comment> reversedComments = comments.reversed.toList();
          getNewsFeedData[i].comment.clear();
          getNewsFeedData[i].comment = reversedComments;
        }

        for (int i = 0; i < getNewsFeedData.length; i++) {
          if (getNewsFeedData[i].is_pinned == '1') {
            final items = getNewsFeedData.removeAt(i);
            getNewsFeedData.insert(0, items);
          }
        }

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

  void addComment(newsfeedId, comment) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = newsfeedId;
    apiBodyObj['news_feed_comment'] = comment;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/AddComment', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteNewsFeed(newsfeedId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/DeleteNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteComment(commentId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = commentId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/DeleteComment', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void pinNewsFeed(newsfeedId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/PinNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
      if (response['error_code'] == 308) {
        showSimpleDialog(context,
            title: getTranslated(context, 'error'), message: response['error']);
      }
    }
  }

  void unpinNewsFeed(newsfeedId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/UnpinNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void likeNewsFeed(newsfeedId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/LikeNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void unlikeNewsFeed(newsfeedId) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/UnLikeNewsFeed', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void likeComment(comment_id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['comment_id'] = comment_id;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/LikeOnComments', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void unlikeComment(comment_id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['comment_id'] = comment_id;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/UnLikeComments', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getNewsFeedList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Wallet>> getWalletData() async {
    print(
        '============================getting wallets============================');
    if (walletData.length == 0) {
      Map<String, dynamic> response =
          await NetworkHelper.request('wallet/list');

      if (response["status"] == "success") {
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletData = getData;
        return getData;
      }
    }
    return walletData;
  }

  Future<List<Wallet>> loadWalletList() async {
    if (walletData.length == 0) {
      Map<String, dynamic> response =
          await NetworkHelper.request('wallet/list');

      if (response["status"] == "success") {
        List responseList = response['result'];
        List<Wallet> getData = responseList.map<Wallet>((json) {
          return Wallet.fromJson(json);
        }).toList();
        walletData = getData;

        if (getData.length != 0) {
          setState(() {
            selectedwallet = getData[0];
          });
        }

        return getData;
      }
    }
  }

  void sendTip(newsfeedId, wallet_type_id, tip_amount) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = newsfeedId;
    apiBodyObj['wallet_type_id'] = wallet_type_id;
    apiBodyObj['tip_amount'] = tip_amount;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/SendTip', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context, title: 'Success', message: response['msg']);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Provider.of<PerspectiveProvider>(context)
                      .getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text('NEWSFEED'),
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
            ListView.builder(
                itemCount: getNewsFeedData.length,
                itemBuilder: (context, i) {
                  TextEditingController commentText = TextEditingController();

                  return InkWell(
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    getNewsFeedData[i].news_feed_text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .apply(),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTapDown: (TapDownDetails details) {
                                        if (getNewsFeedData[i].owner['id'] ==
                                            nowCommunityID) {
                                          _showPopupMenu(
                                              details.globalPosition,
                                              '0',
                                              getNewsFeedData[i].id,
                                              getNewsFeedData[i].news_feed_text,
                                              '',
                                              getNewsFeedData[i].images,
                                              getNewsFeedData[i].videos);
                                        } else {
                                          _showPopupMenu(
                                              details.globalPosition,
                                              '1',
                                              getNewsFeedData[i].id,
                                              '',
                                              getNewsFeedData[i].is_pinned,
                                              getNewsFeedData[i].images,
                                              getNewsFeedData[i].videos);
                                        }
                                      },
                                      child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              FaIcon(FontAwesomeIcons.ellipsisH,
                                                  size: 16, color: Colors.grey),
                                            ],
                                          )),
                                    ))
                              ],
                            ),
                          ),
                          getNewsFeedData[i].images.length != 0
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ImageZoomScreen(
                                                    url: getNewsFeedData[i]
                                                        .images[0]))).then(
                                        (val) =>
                                            val ? getNewsFeedList() : null);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: getNewsFeedData[i]
                                                      .images
                                                      .length !=
                                                  0
                                              ? NetworkImage(
                                                  getNewsFeedData[i].images[0])
                                              : NetworkImage(
                                                  "https://dummyimage.com/100x100/cccccc/000000.jpg&text=Image")),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: 200.0,
                                  ),
                                )
                              : getNewsFeedData[i].videos.length != 0
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoScreen(
                                                        url: getNewsFeedData[i]
                                                            .videos[0]))).then(
                                            (val) =>
                                                val ? getNewsFeedList() : null);
                                      },
                                      child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 200.0,
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 200.0,
                                                child: Image.network(
                                                  'https://via.placeholder.com/150.png?text=Video',
                                                ),
                                              ),
                                              Container(
                                                color: Color(0xFF80000000),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 200.0,
                                                child: Icon(
                                                    Icons.play_circle_outline,
                                                    size: 100,
                                                    color: Colors.grey),
                                              )
                                            ],
                                          )),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 200.0,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 200.0,
                                            child: Image.network(
                                              'https://via.placeholder.com/250.png?text=Place Holder',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      )),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          getNewsFeedData[i].is_liked == '1'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    unlikeNewsFeed(
                                                        getNewsFeedData[i].id);
                                                  },
                                                  child: FaIcon(
                                                      FontAwesomeIcons
                                                          .solidHeart,
                                                      size: 18,
                                                      color: Colors.red),
                                                )
                                              : GestureDetector(
                                                  onTap: () {
                                                    likeNewsFeed(
                                                        getNewsFeedData[i].id);
                                                  },
                                                  child: FaIcon(
                                                      FontAwesomeIcons.heart,
                                                      size: 18,
                                                      color: Colors.grey),
                                                ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (getNewsFeedData[i]
                                                        .isComment ==
                                                    true) {
                                                  getNewsFeedData[i].isComment =
                                                      false;
                                                } else {
                                                  getNewsFeedData[i].isComment =
                                                      true;
                                                }
                                              });
                                            },
                                            child: FaIcon(
                                                FontAwesomeIcons.comment,
                                                size: 18,
                                                color: Colors.grey),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          ownerType == 'user'
                                              ? getNewsFeedData[i]
                                                          .owner['type'] ==
                                                      'community'
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                showdiag(
                                                                    context,
                                                                    popupContent(
                                                                        false,
                                                                        getNewsFeedData[i].owner[
                                                                            'name'],
                                                                        getNewsFeedData[i]
                                                                            .id)));
                                                      },
                                                      child: Icon(
                                                          Icons.attach_money,
                                                          size: 20,
                                                          color: Colors.grey),
                                                    )
                                                  : Container()
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LikeListScreen(
                                                              newsfeedId:
                                                                  getNewsFeedData[
                                                                          i]
                                                                      .id))).then(
                                                  (val) => val
                                                      ? getNewsFeedList()
                                                      : null);
                                            },
                                            child: Text(
                                              getNewsFeedData[i].total_likes +
                                                  ' likes - ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .apply(),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ViewMoreCommentScreen(
                                                          newsfeedId:
                                                              getNewsFeedData[i]
                                                                  .id,
                                                          news_feed_text:
                                                              getNewsFeedData[i]
                                                                  .news_feed_text,
                                                          is_like:
                                                              getNewsFeedData[i]
                                                                  .is_liked,
                                                          total_likes:
                                                              getNewsFeedData[i]
                                                                  .total_likes,
                                                          total_comments:
                                                              getNewsFeedData[i]
                                                                  .total_comments,
                                                          images: getNewsFeedData[i]
                                                              .images,
                                                          image_length:
                                                              getNewsFeedData[i]
                                                                  .images
                                                                  .length
                                                                  .toString(),
                                                          videos: getNewsFeedData[i]
                                                              .videos,
                                                          newsfeedowner: getNewsFeedData[i].owner['name']))).then(
                                                  (val) => val ? getNewsFeedList() : null);
                                            },
                                            child: Text(
                                              getNewsFeedData[i]
                                                      .total_comments +
                                                  ' comments',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .apply(),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.justify,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                getNewsFeedData[i].isComment == true
                                    ? getNewsFeedData[i].comment.length != 0
                                        ? Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                getNewsFeedData[
                                                                        i]
                                                                    .comment[0]
                                                                    .owner['name'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                                maxLines: 4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                              Text(
                                                                getNewsFeedData[
                                                                        i]
                                                                    .comment[0]
                                                                    .news_feed_comment,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                                maxLines: 4,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                              SizedBox(
                                                                  height: 5),
                                                              Text(
                                                                displayTimeAgoFromTimestamp(getNewsFeedData[
                                                                            i]
                                                                        .comment[
                                                                            0]
                                                                        .comment_date) +
                                                                    ' - ' +
                                                                    getNewsFeedData[
                                                                            i]
                                                                        .comment[
                                                                            0]
                                                                        .total_comment_likes +
                                                                    ' Likes',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .grey),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                              ),
                                                              getNewsFeedData[i]
                                                                      .comment[
                                                                          0]
                                                                      .reply_by_user
                                                                      .isNotEmpty
                                                                  ? SizedBox(
                                                                      height:
                                                                          10)
                                                                  : Container(),
                                                              getNewsFeedData[i]
                                                                      .comment[
                                                                          0]
                                                                      .reply_by_user
                                                                      .isNotEmpty
                                                                  ? Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              50),
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              getNewsFeedData[i].comment[0].reply_by_user.last.name,
                                                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                                              maxLines: 4,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textDirection: TextDirection.ltr,
                                                                              textAlign: TextAlign.justify,
                                                                            ),
                                                                            Text(
                                                                              getNewsFeedData[i].comment[0].reply_by_user.last.reply,
                                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                              maxLines: 4,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textDirection: TextDirection.ltr,
                                                                              textAlign: TextAlign.justify,
                                                                            ),
                                                                          ]),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          )),
                                                      Expanded(
                                                          flex: 1,
                                                          child: getNewsFeedData[
                                                                              i]
                                                                          .comment[
                                                                              0]
                                                                          .owner[
                                                                      'id'] ==
                                                                  nowCommunityID
                                                              ? GestureDetector(
                                                                  onTapDown:
                                                                      (TapDownDetails
                                                                          details) {
                                                                    _showPopupMenuComment(
                                                                        details
                                                                            .globalPosition,
                                                                        '0',
                                                                        getNewsFeedData[i]
                                                                            .comment[
                                                                                0]
                                                                            .news_feed_comment_id,
                                                                        getNewsFeedData[i]
                                                                            .id,
                                                                        getNewsFeedData[i]
                                                                            .comment
                                                                            .last
                                                                            .news_feed_comment,
                                                                        getNewsFeedData[i]
                                                                            .comment
                                                                            .last
                                                                            .owner['name']);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                            ],
                                                                          )),
                                                                )
                                                              : GestureDetector(
                                                                  onTapDown:
                                                                      (TapDownDetails
                                                                          details) {
                                                                    _showPopupMenuCommentReply(
                                                                        details
                                                                            .globalPosition,
                                                                        '0',
                                                                        getNewsFeedData[i]
                                                                            .comment[
                                                                                0]
                                                                            .news_feed_comment_id,
                                                                        getNewsFeedData[i]
                                                                            .id,
                                                                        getNewsFeedData[i]
                                                                            .comment[
                                                                                0]
                                                                            .news_feed_comment,
                                                                        getNewsFeedData[i].comment[0].owner[
                                                                            'name'],
                                                                        getNewsFeedData[i]
                                                                            .comment[
                                                                                0]
                                                                            .is_comment_like,
                                                                        getNewsFeedData[i]
                                                                            .comment[0]
                                                                            .news_feed_comment_id);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                            ],
                                                                          )),
                                                                ))
                                                    ],
                                                  ),
                                                ),
                                                getNewsFeedData[i]
                                                            .comment
                                                            .length >
                                                        1
                                                    ? SizedBox(
                                                        height: 10,
                                                      )
                                                    : Container(),
                                                getNewsFeedData[i]
                                                            .comment
                                                            .length >
                                                        1
                                                    ? Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                                flex: 5,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      getNewsFeedData[i]
                                                                          .comment[
                                                                              1]
                                                                          .owner['name'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                      maxLines:
                                                                          4,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    Text(
                                                                      getNewsFeedData[
                                                                              i]
                                                                          .comment[
                                                                              1]
                                                                          .news_feed_comment,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w300),
                                                                      maxLines:
                                                                          4,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            5),
                                                                    Text(
                                                                      displayTimeAgoFromTimestamp(getNewsFeedData[i]
                                                                              .comment[
                                                                                  1]
                                                                              .comment_date) +
                                                                          ' - ' +
                                                                          getNewsFeedData[i]
                                                                              .comment[1]
                                                                              .total_comment_likes +
                                                                          ' Likes',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    getNewsFeedData[i]
                                                                            .comment[
                                                                                1]
                                                                            .reply_by_user
                                                                            .isNotEmpty
                                                                        ? SizedBox(
                                                                            height:
                                                                                10)
                                                                        : Container(),
                                                                    getNewsFeedData[i]
                                                                            .comment[1]
                                                                            .reply_by_user
                                                                            .isNotEmpty
                                                                        ? Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 50),
                                                                            child:
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                              Text(
                                                                                getNewsFeedData[i].comment[1].reply_by_user.last.name,
                                                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                                                maxLines: 4,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textDirection: TextDirection.ltr,
                                                                                textAlign: TextAlign.justify,
                                                                              ),
                                                                              Text(
                                                                                getNewsFeedData[i].comment[1].reply_by_user.last.reply,
                                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                maxLines: 4,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textDirection: TextDirection.ltr,
                                                                                textAlign: TextAlign.justify,
                                                                              ),
                                                                            ]),
                                                                          )
                                                                        : Container()
                                                                  ],
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child: getNewsFeedData[i]
                                                                            .comment[1]
                                                                            .owner['id'] ==
                                                                        nowCommunityID
                                                                    ? GestureDetector(
                                                                        onTapDown:
                                                                            (TapDownDetails
                                                                                details) {
                                                                          _showPopupMenuComment(
                                                                              details.globalPosition,
                                                                              '0',
                                                                              getNewsFeedData[i].comment[1].news_feed_comment_id,
                                                                              getNewsFeedData[i].id,
                                                                              getNewsFeedData[i].comment.last.news_feed_comment,
                                                                              getNewsFeedData[i].comment.last.owner['name']);
                                                                        },
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                              ],
                                                                            )),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTapDown:
                                                                            (TapDownDetails
                                                                                details) {
                                                                          _showPopupMenuCommentReply(
                                                                              details.globalPosition,
                                                                              '0',
                                                                              getNewsFeedData[i].comment[1].news_feed_comment_id,
                                                                              getNewsFeedData[i].id,
                                                                              getNewsFeedData[i].comment[1].news_feed_comment,
                                                                              getNewsFeedData[i].comment[1].owner['name'],
                                                                              getNewsFeedData[i].comment[1].is_comment_like,
                                                                              getNewsFeedData[i].comment[1].news_feed_comment_id);
                                                                        },
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                              ],
                                                                            )),
                                                                      ))
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                getNewsFeedData[i]
                                                            .comment
                                                            .length >
                                                        2
                                                    ? SizedBox(
                                                        height: 10,
                                                      )
                                                    : Container(),
                                                getNewsFeedData[i]
                                                            .comment
                                                            .length >
                                                        2
                                                    ? Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                                flex: 5,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      getNewsFeedData[i]
                                                                          .comment[
                                                                              2]
                                                                          .owner['name'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                      maxLines:
                                                                          4,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    Text(
                                                                      getNewsFeedData[
                                                                              i]
                                                                          .comment[
                                                                              2]
                                                                          .news_feed_comment,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w300),
                                                                      maxLines:
                                                                          4,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            5),
                                                                    Text(
                                                                      displayTimeAgoFromTimestamp(getNewsFeedData[i]
                                                                              .comment[
                                                                                  2]
                                                                              .comment_date) +
                                                                          ' - ' +
                                                                          getNewsFeedData[i]
                                                                              .comment[2]
                                                                              .total_comment_likes +
                                                                          ' Likes',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textDirection:
                                                                          TextDirection
                                                                              .ltr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                    ),
                                                                    getNewsFeedData[i]
                                                                            .comment[
                                                                                2]
                                                                            .reply_by_user
                                                                            .isNotEmpty
                                                                        ? SizedBox(
                                                                            height:
                                                                                10)
                                                                        : Container(),
                                                                    getNewsFeedData[i]
                                                                            .comment[2]
                                                                            .reply_by_user
                                                                            .isNotEmpty
                                                                        ? Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 50),
                                                                            child:
                                                                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                              Text(
                                                                                getNewsFeedData[i].comment[2].reply_by_user.last.name,
                                                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                                                maxLines: 4,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textDirection: TextDirection.ltr,
                                                                                textAlign: TextAlign.justify,
                                                                              ),
                                                                              Text(
                                                                                getNewsFeedData[i].comment[2].reply_by_user.last.reply,
                                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                maxLines: 4,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textDirection: TextDirection.ltr,
                                                                                textAlign: TextAlign.justify,
                                                                              ),
                                                                            ]),
                                                                          )
                                                                        : Container()
                                                                  ],
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child: getNewsFeedData[i]
                                                                            .comment[2]
                                                                            .owner['id'] ==
                                                                        nowCommunityID
                                                                    ? GestureDetector(
                                                                        onTapDown:
                                                                            (TapDownDetails
                                                                                details) {
                                                                          _showPopupMenuComment(
                                                                              details.globalPosition,
                                                                              '0',
                                                                              getNewsFeedData[i].comment[2].news_feed_comment_id,
                                                                              getNewsFeedData[i].id,
                                                                              getNewsFeedData[i].comment.last.news_feed_comment,
                                                                              getNewsFeedData[i].comment.last.owner['name']);
                                                                        },
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                              ],
                                                                            )),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTapDown:
                                                                            (TapDownDetails
                                                                                details) {
                                                                          _showPopupMenuCommentReply(
                                                                              details.globalPosition,
                                                                              '0',
                                                                              getNewsFeedData[i].comment[2].news_feed_comment_id,
                                                                              getNewsFeedData[i].id,
                                                                              getNewsFeedData[i].comment[2].news_feed_comment,
                                                                              getNewsFeedData[i].comment[2].owner['name'],
                                                                              getNewsFeedData[i].comment[2].is_comment_like,
                                                                              getNewsFeedData[i].comment[2].news_feed_comment_id);
                                                                        },
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                FaIcon(FontAwesomeIcons.ellipsisH, size: 16, color: Colors.grey),
                                                                              ],
                                                                            )),
                                                                      ))
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                  child: TextField(
                                                    controller: commentText,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12.0)),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFACACAC),
                                                              width: 1),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10.0)),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFACACAC)),
                                                        ),
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 20,
                                                                left: 15),
                                                        hintText: "Comment",
                                                        hintStyle: TextStyle(
                                                            fontSize: 16.0,
                                                            color: Color(
                                                                0xFFACACAC)),
                                                        suffixIcon:
                                                            GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            if (commentText
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title:
                                                                      'Attention',
                                                                  message:
                                                                      'Please add comment');
                                                            } else {
                                                              addComment(
                                                                  getNewsFeedData[
                                                                          i]
                                                                      .id,
                                                                  commentText
                                                                      .text);
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.send,
                                                            color: Color(
                                                                0xFFACACAC),
                                                          ),
                                                        )),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                  child: TextField(
                                                    controller: commentText,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12.0)),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFACACAC),
                                                              width: 1),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10.0)),
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFACACAC)),
                                                        ),
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 20,
                                                                left: 15),
                                                        hintText: "Comment",
                                                        hintStyle: TextStyle(
                                                            fontSize: 16.0,
                                                            color: Color(
                                                                0xFFACACAC)),
                                                        suffixIcon:
                                                            GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            if (commentText
                                                                    .text ==
                                                                '') {
                                                              showSimpleDialog(
                                                                  context,
                                                                  title:
                                                                      'Attention',
                                                                  message:
                                                                      'Please add comment');
                                                            } else {
                                                              addComment(
                                                                  getNewsFeedData[
                                                                          i]
                                                                      .id,
                                                                  commentText
                                                                      .text);
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.send,
                                                            color: Color(
                                                                0xFFACACAC),
                                                          ),
                                                        )),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                    : Container()
                              ],
                            ),
                          ),
                          Divider(
                            height: 5,
                            color: Color(0xFFACACAC),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: () async {
                  /*Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => CreateNewsFeedScreen()));*/
                  Navigator.of(context)
                      .push(
                        new MaterialPageRoute(
                            builder: (context) => CreateNewsFeedScreen()),
                      )
                      .then((val) => val ? getNewsFeedList() : null);
                },
                child: Icon(Icons.add),
                tooltip: getTranslated(context, "create_reward"),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : null);
  }

  _showPopupMenu(
      Offset position,
      String flag,
      String newsfeedId,
      String newsfeedText,
      String isPinned,
      List<String> images,
      List<String> videos) {
    if (flag == '0') {
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(position.dx, position.dy, 100000,
            0), //position where you want to show the menu on screen
        items: [
          PopupMenuItem<String>(
              child: const Text('Edit Post',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              value: '1'),
          PopupMenuItem<String>(
              child: const Text('Delete Post',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              value: '2'),
          PopupMenuItem<String>(
              child: const Text('Pin Post to Top',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              value: '3'),
        ],
        elevation: 8.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateNewsFeedScreen(
                          newsfeedId: newsfeedId,
                          newsfeedName: newsfeedText,
                          images: images,
                          videos: videos)))
              .then((val) => val ? getNewsFeedList() : null);
          //code here
        } else if (itemSelected == "2") {
          deleteNewsFeed(newsfeedId);
        } else if (itemSelected == "3") {
          pinNewsFeed(newsfeedId);
        }
      });
    } else {
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(position.dx, position.dy, 100000,
            0), //position where you want to show the menu on screen
        items: [
          isPinned == '1'
              ? PopupMenuItem<String>(
                  child: const Text('Remove Pin Post',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  value: '1')
              : PopupMenuItem<String>(
                  child: const Text('Pin Post to Top',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  value: '1')
        ],
        elevation: 8.0,
      ).then<void>((String itemSelected) {
        if (itemSelected == null) return;

        if (itemSelected == "1") {
          //code here
          isPinned == '1' ? unpinNewsFeed(newsfeedId) : pinNewsFeed(newsfeedId);
        } else {
          //code here
        }
      });
    }
  }

  _showPopupMenuComment(Offset position, String flag, String commentId,
      String newsfeedId, String newsfeedcommenttext, String commentOwner) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 100000,
          0), //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(
            child: const Text('Edit Comment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            value: '1'),
        PopupMenuItem<String>(
            child: const Text('Delete Comment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String itemSelected) {
      if (itemSelected == null) return;

      if (itemSelected == "1") {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditCommentScreen(
                        newsfeedId: newsfeedId,
                        newsfeedcommentId: commentId,
                        newsfeedcommenttext: newsfeedcommenttext,
                        ownername: commentOwner)))
            .then((val) => val ? getNewsFeedList() : null);
        //code here
      } else if (itemSelected == "2") {
        deleteComment(commentId);
      } else {
        //code here
      }
    });
  }

  _showPopupMenuCommentReply(
      Offset position,
      String flag,
      String commentId,
      String newsfeedId,
      String newsfeedcommenttext,
      String commentOwner,
      String is_comment_like,
      String comment_id) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 100000,
          0), //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(
            child: const Text('Reply',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            value: '1'),
        is_comment_like == '0'
            ? PopupMenuItem<String>(
                child: const Text('Like',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                value: '2')
            : PopupMenuItem<String>(
                child: const Text('UnLike',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                value: '2'),
      ],
      elevation: 8.0,
    ).then<void>((String itemSelected) {
      if (itemSelected == null) return;

      if (itemSelected == "1") {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CommentRepliesScreen(
                        newsfeedId: newsfeedId,
                        newsfeedcommentId: commentId,
                        newsfeedcomment: newsfeedcommenttext,
                        newsfeedowner: commentOwner)))
            .then((val) => val ? getNewsFeedList() : null);
        //code here
      } else if (itemSelected == "2") {
        is_comment_like == '0'
            ? likeComment(comment_id)
            : unlikeComment(comment_id);
      } else {
        //code here
      }
    });
  }

  Widget showdiag(BuildContext context, data) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, data),
    );
  }

  Widget dialogContent(BuildContext context, data) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 10.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: data,
          ),
        ],
      ),
    );
  }

  popupContent(str, owner, newsfeedId) {
    String walletError = '';
    return StatefulBuilder(builder: (context, setState) {
      return Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'SEND TIP',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.subtitle1.fontWeight,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  owner,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.subtitle1.fontWeight,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _getBillerCategoryList(),
                SizedBox(
                  height: 20,
                ),
                Container(
                    decoration: new BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(5.0)),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: tipAmountText,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Tip amount",
                              hintStyle: TextStyle(
                                  fontSize: 18.0, color: Color(0xFFACACAC)),
                            ),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                            validator: (value) {
                              if (!Validator.isRequired(value,
                                  allowEmptySpaces: true)) {
                                return 'Tip amount required';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                Container(
                    decoration: new BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(5.0)),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextField(
                            controller: tipMessageText,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Message (optional)",
                              hintStyle: TextStyle(
                                  fontSize: 18.0, color: Color(0xFFACACAC)),
                            ),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    )),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.subtitle1.fontSize,
                            fontWeight: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .fontWeight,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (tipAmountText.text == '') {
                              showSimpleDialog(context,
                                  title: 'Attention',
                                  message: 'Tip amount required.');
                            } else {
                              if (selectedwallet.currencyCode == 'CRED') {
                                showSimpleDialog(context,
                                    title: 'Attention',
                                    message: 'Please select another account');
                              } else {
                                Navigator.of(context).pop();
                                sendTip(
                                    newsfeedId,
                                    selectedwallet.walletId.toString(),
                                    tipAmountText.text);
                              }
                            }
                          },
                          child: Text(
                            'SEND TIP',
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontSize,
                              fontWeight: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .fontWeight,
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ));
    });
  }

  static String displayTimeAgoFromTimestamp(String dateString,
      {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} months ago';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  Widget _getBillerCategoryList() {
    return FutureBuilder(
        future: walletDataList,
        builder: (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DropdownButtonFormField<Wallet>(
                  isExpanded: true,
                  hint: Text("Select Category"),
                  value: selectedwallet,
                  icon: Icon(Icons.arrow_downward),
                  onChanged: (Wallet value) {
                    setState(() {
                      selectedwallet = value;
                    });
                  },
                  items: snapshot.data.map((Wallet billerCategory) {
                    return DropdownMenuItem<Wallet>(
                      value: billerCategory,
                      child: Text(billerCategory.currencyCode),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: ' Please select account',
                    border: const OutlineInputBorder(),
                  ),
                )
              : Container();
        });
  }
}

class ImageZoomScreen extends StatelessWidget {
  String url;

  ImageZoomScreen({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
          0.80), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1,
                    height: MediaQuery.of(context).size.height / 1,
                    child: PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      imageProvider: NetworkImage(url),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 100, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear,
                                size: 25, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          )
                        ],
                      )),
                ],
              )
            ],
          )),
    );
  }
}

class VideoScreen extends StatefulWidget {
  String url;
  VideoScreen({Key key, this.url}) : super(key: key);

  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  CachedVideoPlayerController controller;
  @override
  void initState() {
    controller = CachedVideoPlayerController.network(widget.url);
    controller.initialize().then((_) {
      setState(() {});
      controller.play();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
          0.80), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 1,
                      height: MediaQuery.of(context).size.height / 1,
                      child: controller.value != null &&
                              controller.value.initialized
                          ? AspectRatio(
                              child: CachedVideoPlayer(controller),
                              aspectRatio: controller.value.aspectRatio,
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            )),
                  Container(
                      padding: EdgeInsets.only(top: 100, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear,
                                size: 25, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          )
                        ],
                      )),
                ],
              )
            ],
          )),
    );
  }
}
