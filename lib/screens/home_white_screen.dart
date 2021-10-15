import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/apps/user_merchant/components/rating_panel.dart';
import 'package:tagcash/apps/user_merchant/components/subscription_option.dart';
import 'package:tagcash/apps/wallet/models/receipt.dart';
import 'package:tagcash/apps/wallet/receipt_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/components/merchant_cover_card.dart';
import 'package:tagcash/components/public_area.dart';
import 'package:tagcash/components/wallets_dropdown.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/business_site_data.dart';
import 'package:tagcash/models/module.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';

class HomeWhiteScreen extends StatefulWidget {
  const HomeWhiteScreen({Key key}) : super(key: key);

  @override
  _HomeWhiteScreenState createState() => _HomeWhiteScreenState();
}

class _HomeWhiteScreenState extends State<HomeWhiteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  bool isLoading = false;
  bool isLoadingInitial = false;
  String roleName = '';

  bool joinPossible = false;
  bool leavePossible = false;
  TextEditingController _amountController;
  TextEditingController _notesController;

  int activeWalletId;
  String activeCurrencyCode;

  BusinessSiteData merchantData;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    loadMerchantProfile();
    defaultWalletLoad();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void loadMerchantProfile() async {
    setState(() {
      isLoadingInitial = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['name'] = AppConstants.siteOwner;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/searchNew', apiBodyObj);

    if (response['status'] == 'success' && response['result'].length != 0) {
      setState(() {
        isLoadingInitial = false;
      });
      List responseList = response['result'];

      merchantData = BusinessSiteData.fromJson(responseList[0]);

      if (merchantData.roleType == '0') {
        roleName = getTranslated(context, 'contacts_nontagcashmember');
        joinPossible = true;
      } else if (merchantData.roleType == "owner") {
        roleName = getTranslated(context, 'owner');
      } else {
        roleName = merchantData.roleName;
        leavePossible = true;
      }
    } else {
      showInvalidUserError();
    }
  }

  void showInvalidUserError() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, 'invalid_business')),
            content: Text(getTranslated(context, 'invalid_business_message')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppConstants.siteOwner = '';
                  AppConstants.appHomeMode = 'normal';

                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (Route<dynamic> route) => false);
                },
                child: Text(getTranslated(context, 'ok')),
              )
            ],
          );
        });
  }

  void defaultWalletLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['new_call'] = '1';

    Map<String, dynamic> response =
        await NetworkHelper.request('user/DefaultWallet', apiBodyObj);

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (responseMap.containsKey('wallet_id')) {
        activeWalletId = int.parse(responseMap['wallet_id']);
        activeCurrencyCode = responseMap['currency_code'];
      }
    }
  }

  void payClickHandler() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: enableAutoValidate
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: WalletsDropdown(
                              currencyCode: ValueNotifier<String>(
                                  activeWalletId.toString()),
                              onSelected: (wallet) => setSelectedWallet(wallet),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                icon: Icon(Icons.account_balance_wallet),
                                labelText: getTranslated(context, 'amount'),
                                hintText:
                                    getTranslated(context, 'enter_amount'),
                              ),
                              validator: (value) {
                                if (!Validator.isAmount(value)) {
                                  return getTranslated(
                                      context, 'enter_valid_amount');
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        minLines: 3,
                        maxLines: 5,
                        controller: _notesController,
                        decoration: InputDecoration(
                          icon: Icon(Icons.note),
                          labelText: getTranslated(context, 'notes'),
                          hintText: getTranslated(context, 'transaction_notes'),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            transferClickHandler();
                          }
                        },
                        child: Text(getTranslated(context, 'pay')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void setSelectedWallet(Wallet wallet) {
    activeWalletId = wallet.walletId;
    activeCurrencyCode = wallet.currencyCode;
  }

  transferClickHandler() async {
    if (activeWalletId == null) {
      Fluttertoast.showToast(
        msg: getTranslated(context, 'please_select_wallets'),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      isLoading = true;
      transferClickPossible = false;
    });

    String amountValue = _amountController.text;
    amountValue = amountValue.replaceAll(',', '');

    Receipt receiptData = Receipt(
      type: 'send_tagcash',
      direction: 'out',
      walletId: activeWalletId,
      amount: amountValue,
      currencyCode: activeCurrencyCode,
      narration: _notesController.text,
      name: merchantData.communityName,
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = activeWalletId.toString();
    apiBodyObj['to_wallet_id'] = activeWalletId.toString();
    apiBodyObj['narration'] = _notesController.text;

    apiBodyObj['to_type'] = 'community';
    apiBodyObj['to_id'] = merchantData.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/transfer', apiBodyObj);

    setState(() {
      isLoading = false;
      transferClickPossible = true;
    });

    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      // if (Provider.of<PerspectiveProvider>(context, listen: false)
      //       .getActivePerspective() ==
      //   'user') {
      receiptData.transactionId = responseMap['transaction_id'];
      receiptData.date = responseMap['transfer_date'];
      receiptData.scratchcardGameId =
          responseMap['scratchcard_game_id'].toString();
      receiptData.winCombinationId =
          responseMap['win_combination_id'].toString();

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            receipt: receiptData,
          ),
        ),
      );

      // } else {
      //   showSimpleDialog(context, title: 'PAY', message: '${_amountController.text} $activeCurrencyCode Credited to user');
      // }

      _amountController.text = '';
      _notesController.text = '';
    } else {
      TransferError.errorHandle(context, response['error']);
    }
  }

  void joinCommunityHandle() {
    if (merchantData.paidRoleExist) {
      subscriptionOption();
    } else {
      joinCommunity();
    }
  }

  void subscriptionOption() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SubscriptionOption(
            communityId: merchantData.id,
            onSuccess: (value) {
              setState(() {
                joinPossible = false;
                leavePossible = true;
              });
            },
          );
        });
  }

  void joinCommunity() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = merchantData.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('community/join', apiBodyObj);

    isLoading = false;
    if (response['status'] == 'success') {
      joinPossible = false;
      leavePossible = true;

      showSnackBar(getTranslated(context, 'successfully_joined_businesses'));
    } else {
      if (response['error'] == 'private_community') {
        showSnackBar(getTranslated(context, 'private_community'));
      } else if (response['error'] == 'not_eligible') {
        showSnackBar('Not eligible');
      } else if (response['error'] == 'already_member') {
        showSnackBar('You are already a member of this Merchant');
      } else {
        showSnackBar(getTranslated(context, 'error_occurred'));
      }
    }
    setState(() {});
  }

  void leaveCommunity() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'community/leave/' + merchantData.id.toString());

    isLoading = false;
    if (response['status'] == 'success') {
      joinPossible = true;
      leavePossible = false;

      showSnackBar(getTranslated(context, 'successfully_removed'));
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {});
  }

  ratingChangeClickHandler() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return RatingPanel(
            id: merchantData.id.toString(),
            type: 'user',
            onRatingChanges: (String rating) {
              // setState(() {
              //   userRating = rating;
              // });
            },
          );
        });
  }

  chatClickHandler() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         ConversationScreen(source: 'tagcash', data: userDetail),
    //   ),
    // );
  }

  merchantInfoClickHandler() {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(getTranslated(context, 'business_id')),
                    subtitle: Text(merchantData.id),
                  ),
                  ListTile(
                    title: Text(getTranslated(context, 'details')),
                    subtitle: Text(merchantData.communityDescription),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String ratingValueText(String rating) {
    return double.parse(rating).round().toString();
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        home: false,
      ),
      body: isLoadingInitial
          ? Center(child: Loading())
          : Stack(
              children: [
                ListView(
                  padding: EdgeInsets.all(kDefaultPadding),
                  children: [
                    MerchantCoverCard(
                        id: merchantData.id,
                        communityName: merchantData.communityName,
                        coverPhoto: merchantData.coverPhoto),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: chatClickHandler,
                            icon: FaIcon(FontAwesomeIcons.comment),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed:
                                transferClickPossible ? payClickHandler : null,
                            icon: FaIcon(FontAwesomeIcons.moneyBillWave),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: merchantInfoClickHandler,
                            icon: FaIcon(FontAwesomeIcons.infoCircle),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: ratingChangeClickHandler,
                            icon: Stack(
                              children: [
                                FaIcon(FontAwesomeIcons.circle),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      ratingValueText(
                                          merchantData.rating.toString()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: joinPossible ? joinCommunityHandle : null,
                      child: Container(
                        margin: EdgeInsets.all(kDefaultPadding),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Colors.grey.withOpacity(.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          joinPossible
                              ? getTranslated(context, 'join')
                              : roleName.toUpperCase(),
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // MerchentModulesList(
                    //   merchantId: merchantData.id,
                    // ),
                    PublicArea(
                      userName: merchantData.id,
                      perspective: 'community',
                      centerLayout: true,
                    ),
                  ],
                ),
                isLoading ? Center(child: Loading()) : SizedBox(),
              ],
            ),
    );
  }
}

class MerchentModulesList extends StatefulWidget {
  final String merchantId;

  const MerchentModulesList({
    Key key,
    @required this.merchantId,
  }) : super(key: key);

  @override
  _MerchentModulesListState createState() => _MerchentModulesListState();
}

class _MerchentModulesListState extends State<MerchentModulesList> {
  Future<List<Module>> favoritesListData;
  @override
  void initState() {
    super.initState();
    favoritesListData = appFavoritesListLoad();
  }

  Future<List<Module>> appFavoritesListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['userId'] = widget.merchantId;
    apiBodyObj['userType'] = '2';

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModules/ModuleByUserId', apiBodyObj);

    List<Module> getData = [];

    List responseList = response['list'];
    if (responseList != null) {
      List<Module> getData = responseList.map<Module>((json) {
        return Module.fromJson(json);
      }).toList();
    }

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
                : Center(child: Loading());
          },
        ),
      ],
    );
  }
}
