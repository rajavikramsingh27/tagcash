import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/wallet/wallet_info.dart';
import 'package:tagcash/components/app_drawer.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/public_area.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/handlers/identifier_handler.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/module.dart';
import 'package:tagcash/providers/layout_provider.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';

import 'package:tagcash/apps/crypto_wallet/crypto_wallet_widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback showAppList;
  final Function(String) setMoreMode;
  final String listingMode;

  const HomeScreen({
    Key key,
    this.showAppList,
    this.setMoreMode,
    this.listingMode,
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  IdentifierHandler identifierHandler = IdentifierHandler();

  String showListingMode = 'miniprogram';
  List<String> listingModeData = [];
  bool isCrypto = false;

  @override
  void initState() {
    showListingMode = widget.listingMode;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      if (Provider.of<UserProvider>(context, listen: false).userData.userName !=
          '') {
        listingModeData = ['miniprogram', 'publicprogram'];
      } else {
        listingModeData = ['miniprogram'];
      }
    } else {
      listingModeData = ['miniprogram', 'publicprogram'];
    }

    if (!kIsWeb) {
      identifierHandler.nfcScanStart(context);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      identifierHandler.nfcScanStop();
    }

    super.dispose();
  }

  void onCryptoChange(crypto) {
    setState(() {
      isCrypto = crypto;
    });
  }

  activeModeChanged(String mode) {
    showListingMode = mode;

    setState(() {});

    widget.setMoreMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        home: false,
        crypto: true,
        onCrypto: (crypto) => onCryptoChange(crypto),
        chat:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                ? true
                : false,
        title: Provider.of<LayoutProvider>(context).lauoutMode == 0
            ? Provider.of<PerspectiveProvider>(context)
                        .getActivePerspective() ==
                    'user'
                ? Provider.of<UserProvider>(context).userData.firstName
                : Provider.of<MerchantProvider>(context).merchantData.name
            : '',
      ),
      backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
          ? Colors.black
          : Color(0xFFE8E7E7),
      drawer: MediaQuery.of(context).size.width < 430 ? AppDrawer() : null,
      body: ListView(
        children: [
          (!isCrypto) ? WalletInfo(businessSite: false) : CryptoWalletWidget(),
          Row(
            children: [
              buildModeDropdownButton(),
              Expanded(
                child: Container(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > 200.0) {
                      return buildMoreAppButton(context, true);
                    } else {
                      return buildMoreAppButton(context, false);
                    }
                  }),
                ),
              ),
            ],
          ),
          if (showListingMode == 'miniprogram') FavoritesArea(),
          if (showListingMode == 'publicprogram' &&
              Provider.of<PerspectiveProvider>(context, listen: false)
                      .getActivePerspective() ==
                  'user')
            PublicArea(
              userName: Provider.of<UserProvider>(context, listen: false)
                  .userData
                  .userName,
              perspective: 'user',
            ),
          if (showListingMode == 'publicprogram' &&
              Provider.of<PerspectiveProvider>(context, listen: false)
                      .getActivePerspective() ==
                  'community')
            PublicArea(
              userName: Provider.of<MerchantProvider>(context, listen: false)
                  .merchantData
                  .id
                  .toString(),
              perspective: 'community',
            ),
        ],
      ),
    );
  }

  Widget buildModeDropdownButton() {
    return Container(
      width: 180,
      margin: EdgeInsets.only(left: 10),
      padding: EdgeInsets.only(left: 10),
      height: 38,
      decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.grey.withOpacity(.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
          value: showListingMode,
          icon: Center(child: Icon(Icons.arrow_drop_down)),
          iconSize: 30,
          isExpanded: true,
          underline: SizedBox(),
          onChanged: (String newValue) {
            activeModeChanged(newValue);
          },
          items: listingModeData.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(Provider.of<PerspectiveProvider>(context)
                          .getActivePerspective() ==
                      'community'
                  ? getTranslated(context, '${value}_webapp')
                  : getTranslated(context, value)),
            );
          }).toList()),
    );
  }

  Widget buildMoreAppButton(BuildContext context, bool longText) {
    return GestureDetector(
      onTap: () => widget.showAppList(),
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              longText
                  ? Provider.of<PerspectiveProvider>(context)
                              .getActivePerspective() ==
                          'community'
                      ? getTranslated(context, '${showListingMode}_more_webapp')
                      : getTranslated(context, '${showListingMode}_more')
                  : 'More',
              textScaleFactor: 1,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: kPrimaryColor),
            ),
            Icon(
              Icons.east_rounded,
              size: 16,
              color: kPrimaryColor,
            )
          ],
        ),
      ),
    );
  }
}

class FavoritesArea extends StatefulWidget {
  @override
  _FavoritesAreaState createState() => _FavoritesAreaState();
}

class _FavoritesAreaState extends State<FavoritesArea> {
  Future<List<Module>> favoritesListData;
  @override
  void initState() {
    super.initState();
    favoritesListData = appFavoritesListLoad();
  }

  Future<List<Module>> appFavoritesListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModulesFavorites/favorites');

    List responseList = response['result'];
    List<Module> getData = responseList.map<Module>((json) {
      return Module.fromJson(json);
    }).toList();

    return getData;
  }

  onModuleClickHandler(Module moduleData) {
    ModuleHandler.load(context, moduleData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 10),
      physics: NeverScrollableScrollPhysics(),
      children: [
        FutureBuilder(
          future: favoritesListData,
          builder:
              (BuildContext context, AsyncSnapshot<List<Module>> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: .9,
                    ),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => onModuleClickHandler(snapshot.data[index]),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          snapshot.data[index].icon),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                snapshot.data[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.overline,
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
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 10.0,
                    children: List.generate(10, (index) {
                      return Column(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.3),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 6,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  );
          },
        ),
      ],
    );
  }
}
