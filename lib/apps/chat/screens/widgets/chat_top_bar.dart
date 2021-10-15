import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/panel_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';

import '../../bloc/conversation_bloc.dart';

class ChatTopBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final Function onSearch;
  final Function(int) onTabChage;
  final ConversationBloc bloc;

  const ChatTopBar({
    Key key,
    this.appBar,
    this.onSearch,
    this.onTabChage,
    this.bloc,
  }) : super(key: key);

  @override
  _ChatTopBarState createState() => _ChatTopBarState();

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}

class _ChatTopBarState extends State<ChatTopBar> {
  TextEditingController searchInputController;
  bool isSearching = false;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();

    searchInputController = TextEditingController();
  }

  @override
  void dispose() {
    searchInputController.dispose();
    super.dispose();
  }

  void startSearch() {
    print("open search box");
    ModalRoute.of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: stopSearching));

    setState(() {
      isSearching = true;
    });
  }

  void stopSearching() {
    clearSearchInput();

    setState(() {
      isSearching = false;
    });
  }

  void clearSearchInput() {
    print("close search box");
    widget.onSearch("");
    setState(() {
      searchInputController.clear();
    });
  }

  Widget buildSearchField() {
    return new TextField(
      controller: searchInputController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSearch,
    );
  }

  Widget buildTabIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
              tabIndex == 0 ? Icons.chat_bubble : Icons.chat_bubble_outline),
          onPressed: () {
            tabIndex = 0;
            widget.onTabChage(0);
          },
        ),
        IconButton(
          icon: Icon(
            tabIndex == 1 ? Icons.video_call : Icons.video_call_outlined,
            size: 30,
          ),
          onPressed: () {
            tabIndex = 1;
            widget.onTabChage(1);
          },
        ),
        IconButton(
          icon: Icon(tabIndex == 2 ? Icons.settings : Icons.settings_outlined),
          onPressed: () {
            tabIndex = 2;
            widget.onTabChage(2);
          },
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            tabIndex = 0;
            widget.onTabChage(0);
            startSearch();
          },
        )
      ],
    );
  }

  List<Widget> buildActions() {
    return [
      if (isSearching)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (searchInputController == null ||
                searchInputController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            clearSearchInput();
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
      title: isSearching ? buildSearchField() : buildTabIcons(),
      actions: buildActions(),
      bottom: widget.appBar.bottom,
    );
  }
}
