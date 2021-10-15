import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:tagcash/apps/wallet/models/cred_allowed_wallets.dart';
import 'package:tagcash/apps/wallet/models/cred_plans.dart';
import 'package:tagcash/apps/wallet/models/cred_purchase_methods.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/localization/language_constants.dart';

const _returnUrl = 'tagcash://www.tagcash.com';
const _returnUrlWeb = 'https://www.tagcash.com';

String getScaReturnUrl() {
  return kIsWeb ? _returnUrlWeb : _returnUrl;
}

class BuyCredScreen extends StatefulWidget {
  final Wallet wallet;

  const BuyCredScreen({Key key, this.wallet}) : super(key: key);

  @override
  _BuyCredScreenState createState() => _BuyCredScreenState();
}

class _BuyCredScreenState extends State<BuyCredScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  Future<List<CredPlans>> credPlans;
  Future<List<CredAllowedWallets>> allowedWallets;
  Future<List<CredPurchaseMethods>> purchaseMethods;

  CredPlans planSelected;
  CredAllowedWallets walletSelected;
  CredPurchaseMethods methodSelected;
  String selectedMethod = '';
  final formKey = GlobalKey<FormState>();
  final card = StripeCard();
  Stripe stripe;
  CardForm form;

  @override
  void initState() {
    super.initState();
    if (AppConstants.getServer() == 'beta') {
      stripe = Stripe(AppConstants.stripePublishableKeyTest,
          returnUrlForSca: getScaReturnUrl());
    } else {
      stripe = Stripe(AppConstants.stripePublishableKeyLive,
          returnUrlForSca: getScaReturnUrl());
    }
    form = CardForm(card: card, formKey: formKey);
    credPlans = loadCredPlansList();
    allowedWallets = loadAllowedWallets();
    purchaseMethods = loadPurchaseMethods();
  }

  Future<List<CredPlans>> loadCredPlansList() async {
    Map<String, dynamic> response = await NetworkHelper.request('cred/plans');

    List responseList = response['result'];

    List<CredPlans> getData = responseList.map<CredPlans>((json) {
      return CredPlans.fromJson(json);
    }).toList();

    return getData;
  }

  Future<List<CredAllowedWallets>> loadAllowedWallets() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('cred/PurchaseAllowedWallets');

    List responseList = response['result'];

    List<CredAllowedWallets> getData =
        responseList.map<CredAllowedWallets>((json) {
      return CredAllowedWallets.fromJson(json);
    }).toList();

    return getData;
  }

  Future<List<CredPurchaseMethods>> loadPurchaseMethods() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('cred/PurchaseMethods');

    List responseList = response['result'];

    List<CredPurchaseMethods> getData =
        responseList.map<CredPurchaseMethods>((json) {
      return CredPurchaseMethods.fromJson(json);
    }).toList();

    return getData;
  }

  purchaseClickHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['plan_id'] = planSelected.id;
    if (methodSelected.id == '1')
      apiBodyObj['wallet_type_id'] = walletSelected.id;
    else if (methodSelected.id == '2') {
      //apiBodyObj['wallet_type_id'] = '4';
      if (formKey.currentState.validate()) {
        formKey.currentState.save();
      } else {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }
    apiBodyObj['purchase_method_id'] = methodSelected.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('cred/Purchase', apiBodyObj);

    if (response['status'] == 'success') {
      if (methodSelected.id == '1') {
        setState(() {
          isLoading = false;
        });
        confirmAlertShow();
      } else if (methodSelected.id == '2') {
        String res = response['result']['ref'];
        try {
          var paymentMethod =
              await stripe.api.createPaymentMethodFromCard(card);

          final result = await Stripe.instance.confirmPayment(
            res,
            paymentMethodId: paymentMethod['id'],
          );
          if (result['status'] == 'succeeded') {
            // TODO: success
            setState(() {
              isLoading = false;
            });
            confirmAlertShow();
            //return;
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (error) {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
              getTranslated(context, 'failed_to_process_card') + ' - $error');
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      TransferError.errorHandle(context, response['error']);
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  confirmAlertShow() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${widget.wallet.currencyCode} ' +
                getTranslated(context, 'purchase')),
            content: Text(
                '${planSelected.credAmount} ${widget.wallet.currencyCode}' +
                    getTranslated(context, 'purchase_success')),
            actions: [
              FlatButton(
                child: Text(
                  getTranslated(context, 'ok'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, 'buy_lower') +
              ' ${widget.wallet.currencyCode}',
        ),
        body: Builder(builder: (BuildContext context) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  padding: EdgeInsets.all(kDefaultPadding),
                  children: [
                    SizedBox(height: 5),
                    Text(getTranslated(context, 'tag_cred_purchase_info1')),
                    SizedBox(height: 10),
                    Text(getTranslated(context, 'tag_cred_purchase_info2')),
                    SizedBox(height: 10),
                    Text(getTranslated(context, 'tag_cred_purchase_info3')),
                    SizedBox(height: 20),
                    FutureBuilder(
                      future: credPlans,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<CredPlans>> snapshot) {
                        if (snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? DropdownButtonFormField<CredPlans>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: getTranslated(
                                      context, 'choose_credit_purchase'),
                                  border: const OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                value: planSelected,
                                icon: Icon(Icons.arrow_downward),
                                items: snapshot.data
                                    .map<DropdownMenuItem<CredPlans>>(
                                        (CredPlans value) {
                                  return DropdownMenuItem<CredPlans>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${value.name} ( ${widget.wallet.currencyCode} ${value.credAmount})',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${value.currencyCode} ${value.walletTypeIdAmount}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return getTranslated(
                                        context, 'select_credit_bundle');
                                  }
                                  return null;
                                },
                                onChanged: (CredPlans newValue) {
                                  setState(() {
                                    planSelected = newValue;
                                  });
                                },
                              )
                            : Center(child: Loading());
                      },
                    ),
                    SizedBox(height: 20),
                    FutureBuilder(
                      future: purchaseMethods,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<CredPurchaseMethods>> snapshot) {
                        if (snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? DropdownButtonFormField<CredPurchaseMethods>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText:
                                      getTranslated(context, 'payment_method'),
                                  border: const OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                value: methodSelected,
                                icon: Icon(Icons.arrow_downward),
                                items: snapshot.data
                                    .map<DropdownMenuItem<CredPurchaseMethods>>(
                                        (CredPurchaseMethods value) {
                                  return DropdownMenuItem<CredPurchaseMethods>(
                                    value: value,
                                    child: Text(
                                      value.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return getTranslated(
                                        context, 'select_payment_method');
                                  }
                                  return null;
                                },
                                onChanged: (CredPurchaseMethods newValue) {
                                  setState(() {
                                    selectedMethod = newValue.method;
                                    methodSelected = newValue;
                                  });
                                },
                              )
                            : Center(child: Loading());
                      },
                    ),
                    if (selectedMethod == 'tagcash') ...[
                      SizedBox(height: 20),
                      FutureBuilder(
                        future: allowedWallets,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<CredAllowedWallets>> snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? DropdownButtonFormField<CredAllowedWallets>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText:
                                        getTranslated(context, 'paying_wallet'),
                                    border: const OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  value: walletSelected,
                                  icon: Icon(Icons.arrow_downward),
                                  items: snapshot.data.map<
                                          DropdownMenuItem<CredAllowedWallets>>(
                                      (CredAllowedWallets value) {
                                    return DropdownMenuItem<CredAllowedWallets>(
                                      value: value,
                                      child: Text(
                                        value.currencyCode,
                                      ),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null) {
                                      return getTranslated(
                                          context, 'select_wallet');
                                    }
                                    return null;
                                  },
                                  onChanged: (CredAllowedWallets newValue) {
                                    setState(() {
                                      walletSelected = newValue;
                                    });
                                  },
                                )
                              : Center(child: Loading());
                        },
                      ),
                    ],
                    if (selectedMethod == 'stripe') form,
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            enableAutoValidate = true;
                          });
                          if (_formKey.currentState.validate()) {
                            purchaseClickHandler();
                          }
                        },
                        child: Text(getTranslated(context, 'buy_credits_now')))
                  ],
                ),
              ),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          );
        }));
  }
}
