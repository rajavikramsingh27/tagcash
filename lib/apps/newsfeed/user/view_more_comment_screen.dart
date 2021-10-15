import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tagcash/apps/newsfeed/models/comment.dart';
import 'package:tagcash/apps/newsfeed/user/edit_comment_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

import 'comment_replies_screen.dart';

class ViewMoreCommentScreen extends StatefulWidget {
  String newsfeedId,
      newsfeedowner,
      news_feed_text,
      is_like,
      total_likes,
      total_comments,
      image_length;
  List<String> images;
  List<String> videos;

  @override
  _ViewMoreCommentScreenState createState() => _ViewMoreCommentScreenState();

  ViewMoreCommentScreen(
      {Key key,
      this.newsfeedId,
      this.news_feed_text,
      this.is_like,
      this.total_likes,
      this.total_comments,
      this.images,
      this.image_length,
      this.videos,
      this.newsfeedowner})
      : super(key: key);
}

class _ViewMoreCommentScreenState extends State<ViewMoreCommentScreen> {
  bool isLoading = false;
  String nowCommunityID = '0';
  List<Comment> getCommentData = new List<Comment>();
  List<Comment> getReversedCommentData = new List<Comment>();
  TextEditingController commentText = TextEditingController();
  bool isComment = true;
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;

  Future<List<Wallet>> walletDataList;
  List<Wallet> walletData = [];
  Wallet selectedwallet;
  TextEditingController tipAmountText = TextEditingController();
  TextEditingController tipMessageText = TextEditingController();

  @override
  void initState() {
    super.initState();
    walletDataList = loadWalletList();
    getCommentList();
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

  void getCommentList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_id'] = widget.newsfeedId;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/ListAllComment', apiBodyObj);

    print(response);

    if (response['status'] == 'success') {
      print(response);
      if (response['result'] != null) {
        List responseList = response['result'];

        getCommentData = responseList.map<Comment>((json) {
          return Comment.fromJson(json);
        }).toList();

        getReversedCommentData = getCommentData.reversed.toList();

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
      getCommentList();
    } else {
      setState(() {
        isLoading = false;
      });
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
      commentText.text = '';
      getCommentList();
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
      getCommentList();
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
      getCommentList();
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
      widget.is_like = '0';
      setState(() {
        isLoading = false;
      });
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
      widget.is_like = '1';
      setState(() {
        isLoading = false;
      });
//      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Provider.of<PerspectiveProvider>(context)
                      .getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text('COMMENTS'),
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
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    widget.news_feed_text,
                    style: Theme.of(context).textTheme.bodyText1.apply(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.justify,
                  ),
                ),
                widget.image_length != '0'
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ImageZoomScreen(url: widget.images[0])));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: widget.images.length != 0
                                    ? NetworkImage(widget.images[0])
                                    : NetworkImage(
                                        "https://dummyimage.com/100x100/cccccc/000000.jpg&text=Image")),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 200.0,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VideoScreen(url: widget.videos[0])));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200.0,
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 200.0,
                                  child: Image.network(
                                    'https://via.placeholder.com/150.png?text=Video',
                                  ),
                                ),
                                Container(
                                  color: Color(0xFF80000000),
                                  width: MediaQuery.of(context).size.width,
                                  height: 200.0,
                                  child: Icon(Icons.play_circle_outline,
                                      size: 100, color: Colors.grey),
                                )
                              ],
                            )),
                      ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            widget.is_like == '1'
                                ? GestureDetector(
                                    onTap: () {
                                      unlikeNewsFeed(widget.newsfeedId);
                                    },
                                    child: FaIcon(FontAwesomeIcons.solidHeart,
                                        size: 18, color: Colors.red),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      likeNewsFeed(widget.newsfeedId);
                                    },
                                    child: FaIcon(FontAwesomeIcons.heart,
                                        size: 18, color: Colors.grey),
                                  ),
                            SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isComment == true) {
                                    isComment = false;
                                  } else {
                                    isComment = true;
                                  }
                                });
                              },
                              child: FaIcon(FontAwesomeIcons.comment,
                                  size: 18, color: Colors.grey),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => showdiag(
                                        context,
                                        popupContent(
                                            false,
                                            widget.newsfeedowner,
                                            widget.newsfeedId)));
                              },
                              child: Icon(Icons.attach_money,
                                  size: 20, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                widget.total_likes + ' likes - ',
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
                              onTap: () {},
                              child: Text(
                                widget.total_comments + ' comments',
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
                ),
                isComment == true
                    ? Expanded(
                        child: Container(
                        padding: EdgeInsets.only(bottom: 70),
                        child: ListView.builder(
                            itemCount: getReversedCommentData.length,
                            itemBuilder: (context, i) {
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Card(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        flex: 5,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              getReversedCommentData[
                                                                          i]
                                                                      .owner[
                                                                  'name'],
                                                              style: TextStyle(
                                                                  fontSize: 13,
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
                                                              getReversedCommentData[
                                                                      i]
                                                                  .news_feed_comment,
                                                              style: TextStyle(
                                                                  fontSize: 14,
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
                                                            SizedBox(height: 5),
                                                            Text(
                                                              displayTimeAgoFromTimestamp(
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .comment_date) +
                                                                  ' - ' +
                                                                  getReversedCommentData[
                                                                          i]
                                                                      .total_likes +
                                                                  ' Likes',
                                                              style: TextStyle(
                                                                  fontSize: 12,
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
                                                            getReversedCommentData[
                                                                        i]
                                                                    .reply_by_user
                                                                    .isNotEmpty
                                                                ? SizedBox(
                                                                    height: 20)
                                                                : Container(),
                                                            getReversedCommentData[
                                                                        i]
                                                                    .reply_by_user
                                                                    .isNotEmpty
                                                                ? Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                50),
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            getReversedCommentData[i].reply_by_user.last.name,
                                                                            style:
                                                                                TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                                            maxLines:
                                                                                4,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textDirection:
                                                                                TextDirection.ltr,
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                          ),
                                                                          Text(
                                                                            getReversedCommentData[i].reply_by_user.last.reply,
                                                                            style:
                                                                                TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                            maxLines:
                                                                                4,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textDirection:
                                                                                TextDirection.ltr,
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                          ),
                                                                        ]),
                                                                  )
                                                                : Container()
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 1,
                                                        child: getReversedCommentData[
                                                                            i]
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
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .news_feed_comment_id,
                                                                      widget
                                                                          .newsfeedId,
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .news_feed_comment,
                                                                      getReversedCommentData[
                                                                              i]
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
                                                                            FaIcon(FontAwesomeIcons.ellipsisH,
                                                                                size: 16,
                                                                                color: Colors.grey),
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
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .news_feed_comment_id,
                                                                      widget
                                                                          .newsfeedId,
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .news_feed_comment,
                                                                      getReversedCommentData[i].owner[
                                                                          'name'],
                                                                      getReversedCommentData[
                                                                              i]
                                                                          .is_comment_like,
                                                                      getReversedCommentData[
                                                                              i]
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
                                                                            FaIcon(FontAwesomeIcons.ellipsisH,
                                                                                size: 16,
                                                                                color: Colors.grey),
                                                                          ],
                                                                        )),
                                                              ))
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
                      ))
                    : Container()
              ],
            )),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      decoration: new BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFACACAC), width: 0.5),
                          borderRadius: BorderRadius.circular(15.0)),
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              controller: commentText,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 15),
                                  hintText: "Comment",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0, color: Color(0xFFACACAC)),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      if (commentText.text == '') {
                                        showSimpleDialog(context,
                                            title: 'Attention',
                                            message: 'Please add comment');
                                      } else {
                                        addComment(widget.newsfeedId,
                                            commentText.text);
                                      }
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: Color(0xFFACACAC),
                                    ),
                                  )),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
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
            .then((val) => val ? getCommentList() : null);
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
            .then((val) => val ? getCommentList() : null);
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
                      padding: EdgeInsets.only(right: 10),
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
