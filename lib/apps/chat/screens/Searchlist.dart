import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../bloc/conversation_bloc.dart';
import './Invite.dart';
import '../../user_merchant/user_detail_user_screen.dart';
import '../../../components/app_top_bar.dart';
import '../../../models/user_data.dart';
import '../../../models/app_constants.dart' as AppConstants;

class SearchList extends StatefulWidget {
  final String searchText;
  final ConversationBloc bloc;
  final int me;
  final bool isSearchAdd;

  SearchList(
      {Key key,
      @required this.searchText,
      this.bloc,
      this.me,
      this.isSearchAdd});

  @override
  _SearchState createState() =>
      _SearchState(this.searchText, this.bloc, this.me, this.isSearchAdd);
}

class _SearchState extends State<SearchList> {
  List data = [];
  String inputText;
  String searchText;
  ConversationBloc bloc;
  UserData userdata;
  String searchdata;
  int me;
  bool isSearchAdd;

  _SearchState(this.searchText, this.bloc, this.me, this.isSearchAdd);

  @override
  void initState() {
    this.beginSearch();
    super.initState();
  }

  List msgs = [];

  beginSearch() {
    if (this.searchText.isEmpty) {
      print("Search Term is empty!!");
    } else {
      this.bloc.searchUser(this.searchText);
    }
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) => Observer(builder: (_) {
        switch (this.bloc.searchStatus) {
          case FutureStatus.pending:
            return Scaffold(
              appBar: AppTopBar(
                appBar: AppBar(),
                title: 'Search',
              ),
              body: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF173347).withOpacity(0.23),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: ListTile(
                            leading: Icon(Icons.search,
                                // color: kTextLightColor.withOpacity(.5)),
                                color: Colors.black),
                            title: TextField(
                              controller: TextEditingController()
                                ..text = this.searchText,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                setState(() {
                                  this.searchText = value;
                                  beginSearch();
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search ',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              ),
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Text("loading...")
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          case FutureStatus.rejected:
            return Scaffold(
              appBar: AppTopBar(
                appBar: AppBar(),
                title: 'Search',
              ),
              // appBar: AppBar(
              //   backgroundColor: Provider.of<PerspectiveProvider>(context)
              //               .getActivePerspective() ==
              //           'user'
              //       ? Colors.black
              //       : Colors.blue,
              //   // ? kUserBackColor
              //   // : kMerchantBackColor,
              //   title: Text("Search"),
              // ),
              body: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF173347).withOpacity(0.23),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: ListTile(
                            leading: Icon(Icons.search, color: Colors.black),
                            // color: kTextLightColor.withOpacity(.5)),
                            title: TextField(
                              controller: TextEditingController()
                                ..text = this.searchText,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                setState(() {
                                  this.searchText = value;
                                  beginSearch();
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search ',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              ),
                            )),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Something went wrong!',
                          style: TextStyle(color: Colors.red),
                        ),
                        RaisedButton(
                          child: const Text('Tap to try again'),
                          onPressed: () => {},
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          case FutureStatus.fulfilled:
            return Scaffold(
              appBar: AppTopBar(
                appBar: AppBar(),
                title: 'Search',
              ),
              body: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF173347).withOpacity(0.23),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        child: ListTile(
                            leading: Icon(Icons.search, color: Colors.black),
                            // color: kTextLightColor.withOpacity(.5)),
                            title: TextField(
                              controller: TextEditingController()
                                ..text = this.searchText,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                setState(() {
                                  this.searchText = value;
                                  beginSearch();
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search ',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              ),
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Observer(
                        builder: (_) => this.bloc.searchResults.length <= 0
                            ? Invite()
                            : ListView.builder(
                                itemCount: this.bloc.searchResults.length,
                                itemBuilder: (context, index) {
                                  return Column(children: <Widget>[
                                    Divider(
                                      height: 5.0,
                                    ),
                                    ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            // _chatModel.avatarUrl['avatar'] + "?kycImage=0"
                                            AppConstants.getUserImagePath() +
                                                this
                                                    .bloc
                                                    .searchResults[index]['id']
                                                    .toString() +
                                                "?kycImage=0",
                                          ),
                                          radius: 24.0,
                                        ),
                                        title: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  this.bloc.searchResults[index]
                                                      ['name']),
                                            ),
                                            SizedBox(
                                              width: 16.0,
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          bloc.loginToTagtalk(index);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserDetailUserScreen(userData: this.bloc.searchResults[index])
                                            ),
                                          ).then((value) {
                                            this.bloc.resetSearchValues();
                                            this.beginSearch();
                                          });
                                        },
                                        trailing: FlatButton(
                                          child: this.bloc.searchResults[index]
                                                          ['is_blocked'] ==
                                                      '1' ||
                                                  this.bloc.searchResults[index]
                                                          ['is_blocked'] ==
                                                      1
                                              ? Text(
                                                  'Blocked',
                                                  style: TextStyle(
                                                      color: Colors.red
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14.0,
                                                ),
                                          onPressed: () => {},
                                        )),
                                  ]);
                                })),
                  ),
                ],
              ),
            );
        }
      });
}
