import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:tagcash/apps/chat/bloc/conversation_bloc.dart';
import 'package:tagcash/apps/chat/screens/chat-settings/chat_Settings_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import './Calls_screen.dart';
import './Chat_conversations_screen.dart';
import './Searchlist.dart';
import './add_video_call_scree.dart';
import './widgets/chat_top_bar.dart';
import './widgets/search_and_add_floating_button.dart';
import '../utils/core/parsing.dart';
import '../../../constants.dart';
import '../../../models/app_constants.dart' as AppConstants;
import '../../../models/user_data.dart';
import '../../../providers/user_provider.dart';

final _bloc = ConversationBloc();

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final String chatServerUrl = AppConstants.getChatServerUrl();
  bool visibilityTag = false;
  bool isHasCalls = true;
  IO.Socket socket;
  // int me = 1;
  // int me = 32073;
  int me;
  UserData userdata;
  // String searchTerm;
  Future<List<UserData>> searchListData;
  GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  final _textController = TextEditingController();
  // ConversationBloc bloc;
  String searchTerm;
  List<String> filtered;
  Widget cancelIcon;
  TextEditingController searchbarController = TextEditingController();

  var isSearchAddFloatingButton;
  TabController _tabController;
  TextEditingController searchInputController;
  bool isSearching = true;

  void initState() {
    isSearchAddFloatingButton = true;
    searchInputController = TextEditingController();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    searchInputController.dispose();

    var userData =
        Provider.of<UserProvider>(context, listen: false).userData.toMap();
    userData['user_id'] = userData['id'];
    if (this.me == null) {
      setState(() {
        this.me = Parsing.intFrom(userData['id']);
      });
    }
    _bloc.tagtalkLogin(userData);
    // for tabs

    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        setState(() {
          isSearchAddFloatingButton = false;
        });
      } else {
        setState(() {
          isSearchAddFloatingButton = true;
        });
      }
      setState(() {});
    });
    super.didChangeDependencies();
  }

  submitSearch(term, context) {
    term.isEmpty
        ? print("term is empty")
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchList(
                  searchText: term,
                  isSearchAdd: false,
                  bloc: _bloc,
                  me: this.me),
            ),
          ).then(
            (value) {
              _bloc.reloadMainConversations(me);
              print('loaded');
              setState(() {
                this._textController.text = "";
                this.searchTerm = "";
              });
              Navigator.pop(context);
            },
          );
  }

  searchClicked(String searchKey) {
    _tabController.animateTo(0);

    setState(() {
      this.searchTerm = searchKey;
    });
    if (_tabController.index == 1) {
      //calls
      _bloc.filterCallHistory(searchTerm);
    }
    if (_tabController.index == 0) {
      //chat conversations
      _bloc.filterConversations(searchTerm);
    }
    // controller.add({'tab': _tabController.index, 'search': searchKey});
  }

  tabChageClicked(int index) {
    _tabController.animateTo(index);
  }

  void onAddCallClickHandler() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => AddVideoCallScreen(_bloc, me),
      ),
    )
        .then(
      (value) {
        _bloc.historyOfVideoCalls(_bloc.myTagcashId);
      },
    );
  }

  void addContactsClickHandler() {
    showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _searchFormKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            textInputAction: TextInputAction.search,
                            controller: _textController,
                            onSubmitted: (value) {
                              // submitSearchAdd(value, context);
                            },
                            decoration: InputDecoration(
                              hintText: 'ID, Email or Mobile',
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              child: Text('SEARCH AND ADD'),
                              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                              ),
                              onPressed: () {
                                submitSearch(_textController.text, context);
                                {
                                  setState(() {
                                    print("reached here");
                                    enableAutoValidate = true;
                                  });
                                  if (_searchFormKey.currentState.validate()) {
                                    print("reached here--save");
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    // addContactProcess();
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) => Observer(builder: (_) {
        switch (_bloc.chatStatus) {
          case FutureStatus.pending:
            return Scaffold(
                appBar: AppTopBar(
                  appBar: AppBar(),
                  title: 'Chat',
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      Text("Connecting...")
                    ],
                  ),
                ));
          case FutureStatus.rejected:
            return Scaffold(
                appBar: AppTopBar(
                  appBar: AppBar(),
                  title: 'Chat',
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Something went wrong!',
                        style: TextStyle(color: Colors.red),
                      ),
                      RaisedButton(
                        child: const Text('Tap to try again'),
                        onPressed: () {
                          var userData =
                              Provider.of<UserProvider>(context, listen: false)
                                  .userData
                                  .toMap();
                          userData['user_id'] = userData['id'];
                          _bloc.tagtalkLogin(userData);
                        },
                      )
                    ],
                  ),
                ));
          case FutureStatus.fulfilled:
            return Scaffold(
              appBar: ChatTopBar(
                bloc: _bloc,
                appBar: AppBar(),
                onSearch: searchClicked,
                onTabChage: tabChageClicked,
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  Scaffold(
                    body: ChatConversationsScreen(_bloc, me, searchTerm,
                        submitSearch, enableAutoValidate),
                    floatingActionButton:
                        Provider.of<LayoutProvider>(context).lauoutMode != 3
                            ? SearchAndAddFloatingButton(
                                addContactsClickHandler, Icons.add)
                            : null,
                  ),
                  Scaffold(
                    body: CallsScreen(
                        _bloc, me, isHasCalls, isSearchAddFloatingButton),
                    floatingActionButton:
                        Provider.of<LayoutProvider>(context).lauoutMode != 3
                            ? SearchAndAddFloatingButton(
                                onAddCallClickHandler, Icons.video_call)
                            : null,
                  ),
                  Scaffold(
                    body: ChatSettingsScreen(_bloc),
                  ),
                ],
              ),
            );
        }
      });

  @override
  void dispose() {
    super.dispose();
  }
}
