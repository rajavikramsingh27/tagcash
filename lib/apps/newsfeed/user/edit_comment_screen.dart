import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

class EditCommentScreen extends StatefulWidget {
  final String newsfeedId, newsfeedcommentId, newsfeedcommenttext, ownername;
  @override
  _EditCommentScreenState createState() => _EditCommentScreenState();

  EditCommentScreen(
      {Key key,
      this.newsfeedId,
      this.newsfeedcommentId,
      this.newsfeedcommenttext,
      this.ownername})
      : super(key: key);
}

class _EditCommentScreenState extends State<EditCommentScreen> {
  bool isLoading = false;
  String nowCommunityID = '0';
  TextEditingController commentText = TextEditingController();
  String ownerName = '';

  @override
  void initState() {
    super.initState();
    ownerName = widget.ownername;
    commentText.text = widget.newsfeedcommenttext;
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

  void editComment() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['news_feed_comment_id'] = widget.newsfeedcommentId;
    apiBodyObj['news_feed_id'] = widget.newsfeedId;
    apiBodyObj['news_feed_comment'] = commentText.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('NewsFeed/EditComment', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text('EDIT'),
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
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    ownerName,
                    style: Theme.of(context).textTheme.bodyText1.apply(),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(height: 10),
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
                                      editComment();
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
    );
  }
}
