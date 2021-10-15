import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/panel_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/constants.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String title;
  final Function onSearch;
  final bool home;
  final bool chat;
  final Function onCrypto;
  final bool qr;
  final bool crypto;

  const AppTopBar({
    Key key,
    this.appBar,
    this.title,
    this.onSearch,
    this.home = true,
    this.chat = false,
    this.onCrypto,
    this.qr = true,
    this.crypto = false,
  }) : super(key: key);

  @override
  _AppTopBarState createState() => _AppTopBarState();

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}

class _AppTopBarState extends State<AppTopBar> {
  TextEditingController searchInputController;
  bool isSearching = false;
  // String searchQuery = "Search query";
  bool isCrypto = false;

  @override
  void initState() {
    super.initState();

    searchInputController = TextEditingController();
    checkIsCrypto();
  }

  @override
  void dispose() {
    searchInputController.dispose();
    super.dispose();
  }

  void backClicked() {
    Navigator.pop(context);
  }

  void startSearch() {
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
    widget.onSearch("");
    setState(() {
      searchInputController.clear();
    });
  }

  void checkIsCrypto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey("isCrypto")) {
        isCrypto = prefs.getBool("isCrypto");
        if (widget.onCrypto != null) {
          widget.onCrypto(isCrypto);
        }
      }
    });
  }

  void onCryptoClick() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCrypto = !isCrypto;
      widget.onCrypto(isCrypto);
      prefs.setBool("isCrypto", isCrypto);
    });
  }

  Widget buildSearchField() {
    return new TextField(
      controller: searchInputController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: getTranslated(context, 'search'),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSearch,
    );
  }

  List<Widget> buildSearchClear() {
    return <Widget>[
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

  List<Widget> buildActions() {
    if (isSearching) {
      return <Widget>[
        new IconButton(
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

    return <Widget>[
      if (Provider.of<LayoutProvider>(context, listen: false).lauoutMode != 0 &&
          Navigator.canPop(context))
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: backClicked,
        ),
      widget.onSearch != null
          ? IconButton(
              icon: Icon(Icons.search),
              onPressed: startSearch,
            )
          : SizedBox(),
      widget.crypto
          ? IconButton(
              icon: Icon(
                Icons.account_balance_wallet_rounded,
                color: (isCrypto) ? kPrimaryColor : Colors.white,
              ),
              onPressed: () {
                onCryptoClick();
              },
            )
          : SizedBox(),
      if (widget.chat && Provider.of<LayoutProvider>(context).lauoutMode != 3)
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline_outlined,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/chat');
          },
        ),
      if (widget.qr && Provider.of<PanelProvider>(context).panelName == 'main')
        IconButton(
          icon: Icon(
            Icons.qr_code_outlined,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/scan');
          },
        ),
      if (widget.home &&
          Provider.of<PanelProvider>(context).panelName == 'main')
        IconButton(
          icon: Icon(
            Icons.home_outlined,
          ),
          onPressed: () {
            if (AppConstants.appHomeMode == 'whitelabel') {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/business', (Route<dynamic> route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (Route<dynamic> route) => false);
            }
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading:
          Provider.of<LayoutProvider>(context).lauoutMode == 0 ? true : false,
      elevation: 0,
      backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                  'user'
              ? Colors.black
              : Color(0xFFe44933),
      title: isSearching
          ? buildSearchField()
          : Provider.of<LayoutProvider>(context).lauoutMode == 0
              ? Text(
                  widget.title != null ? widget.title : '',
                  style: TextStyle(fontSize: 16),
                  textScaleFactor: 1,
                )
              : Row(
                  mainAxisAlignment:
                      Provider.of<PanelProvider>(context).panelName == 'right'
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                  children: buildActions(),
                ),
      actions: Provider.of<LayoutProvider>(context).lauoutMode == 0
          ? buildActions()
          : buildSearchClear(),
      bottom: widget.appBar.bottom,
    );
  }
}
