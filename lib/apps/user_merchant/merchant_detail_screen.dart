import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
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
import 'package:tagcash/models/module.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/utils/validator.dart';
import 'components/rating_panel.dart';
import 'components/subscription_option.dart';

class MerchantDetailScreen extends StatefulWidget {
  final Map merchantData;
  final String identifier;

  const MerchantDetailScreen({Key key, this.merchantData, this.identifier})
      : super(key: key);

  @override
  _MerchantDetailScreenState createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool enableAutoValidate = false;
  bool transferClickPossible = true;

  bool isLoading = false;
  String roleName = '';

  bool joinPossible = false;
  bool leavePossible = false;
  TextEditingController _amountController;
  TextEditingController _notesController;

  int activeWalletId;
  String activeCurrencyCode;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      if (widget.merchantData['role_type'].toString() == '0') {
        roleName = getTranslated(context, 'contacts_nontagcashmember');
        joinPossible = true;
      } else if (widget.merchantData['role_type'] == "owner") {
        roleName = getTranslated(context, 'owner');
      } else {
        leavePossible = true;
      }
    }

    defaultWalletLoad();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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
                          hintText: getTranslated(context, "transaction_notes"),
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
      name: widget.merchantData['community_name'],
    );

    Map<String, String> apiBodyObj = {};

    apiBodyObj['amount'] = amountValue;
    apiBodyObj['from_wallet_id'] = activeWalletId.toString();
    apiBodyObj['to_wallet_id'] = activeWalletId.toString();
    apiBodyObj['narration'] = _notesController.text;

    if (widget.identifier != null) {
      apiBodyObj['identifier'] = widget.identifier;
    } else {
      apiBodyObj['to_type'] = 'community';
      apiBodyObj['to_id'] = widget.merchantData['id'].toString();
    }

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

  void subscriptionOption() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SubscriptionOption(
            communityId: widget.merchantData['id'],
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

    apiBodyObj['id'] = widget.merchantData['id'].toString();

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
        showSnackBar(getTranslated(context, 'not_eligible'));
      } else if (response['error'] == 'already_member') {
        showSnackBar(getTranslated(context, 'already_member'));
      } else if (response['error'] == 'default_role_error') {
        showSnackBar(getTranslated(context, 'default_role_error'));
      } else if (response['error'] == 'invalid_role_id') {
        showSnackBar(getTranslated(context, 'invalid_role_id'));
      } else if (response['error'] == 'role_join_denied') {
        showSnackBar(getTranslated(context, 'role_join_denied'));
      } else if (response['error'] == 'subscription_not_saved') {
        showSnackBar(getTranslated(context, 'subscription_not_saved'));
      } else {
        TransferError.errorHandle(context, response['error']);
      }
    }
    setState(() {});
  }

  void leaveCommunity() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response = await NetworkHelper.request(
        'community/leave/' + widget.merchantData['id'].toString());

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
            id: widget.merchantData['id'].toString(),
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
                    subtitle: Text(
                      widget.merchantData['id'].toString(),
                    ),
                  ),
                  // ListTile(
                  //   title: Text('Details'),
                  //   subtitle: Text(merchantData.communityDescription),
                  // ),
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
      appBar: AppTopBar(
        appBar: AppBar(),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              MerchantCoverCard(
                id: widget.merchantData['id'].toString(),
                communityName: widget.merchantData['community_name'],
                coverPhoto: widget.merchantData['cover_photo'],
              ),

              SizedBox(height: 10),

              // Container(
              //   color: Colors.black,
              //   height: 250,
              //   width: double.infinity,
              //   child: Image.network(
              //     AppConstants.getCommunityImagePath() +
              //         widget.merchantData['id'].toString(),
              //   ),
              // ),

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
                      onPressed: transferClickPossible ? payClickHandler : null,
                      icon: FaIcon(FontAwesomeIcons.moneyBillWave),
                      color: Colors.grey,
                    ),
                    IconButton(
                      // onPressed: merchantInfoClickHandler,
                      onPressed: () {},
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
                                    widget.merchantData['rating'].toString()),
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

              if (joinPossible)
                GestureDetector(
                  onTap: (widget.merchantData['paid_role_exist'])
                      ? subscriptionOption
                      : joinCommunity,
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
                      '${getTranslated(context, 'join')} - ${widget.merchantData['members_count']} ${getTranslated(context, 'members')}',
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (leavePossible)
                GestureDetector(
                  onTap: leaveCommunity,
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
                      getTranslated(context, 'leave'),
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!joinPossible && !leavePossible)
                Container(
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
                    roleName.toUpperCase(),
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ),

              SizedBox(height: 10),
              // MerchentModulesList(
              //     merchantId: widget.merchantData['id'].toString()),

              PublicArea(
                userName: widget.merchantData['id'].toString(),
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
