import 'package:flutter/material.dart';
import 'package:provider/provider.dart'
;
import '../../bloc/conversation_bloc.dart';
import '../../../../components/wallets_dropdown.dart';
import '../../../../constants.dart';
import '../../../../models/wallet.dart';
import '../../../../providers/perspective_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/networking.dart';

class ChargeToReceiveCallScreen extends StatefulWidget {
  ConversationBloc bloc;
  ChargeToReceiveCallScreen(this.bloc);
  @override
  _ChargeToReceiveCallScreenState createState() =>
      _ChargeToReceiveCallScreenState();
}

class _ChargeToReceiveCallScreenState extends State<ChargeToReceiveCallScreen> {
  var callPer = [
    "Minute",
    "Session",
  ];
  String fromWalletId;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  String _currentSelectedValue;
  final _videoChargeFormKey = GlobalKey<FormState>();
  int activeWalletId;
  String activeCurrencyCode;
  bool isMinute = true;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    var a = await getDetails();
    defaultWalletLoad();

    if (widget.bloc.chargePerMinAmount == '' &&
            widget.bloc.chargePerSession == '' ||
        widget.bloc.chargePerMinAmount == '0' &&
            widget.bloc.chargePerSession == '0' ||
        widget.bloc.chargePerMinAmount == null &&
            widget.bloc.chargePerSession == null) {
      _currentSelectedValue = 'Minute';
    } else {
      if (widget.bloc.chargePerMinAmount == '0') {
        _currentSelectedValue = 'Session';
        _amountController.text = widget.bloc.chargePerSession;
        _timeController.text = widget.bloc.sessionTime;
        isMinute = false;
      } else {
        _currentSelectedValue = 'Minute';
        _amountController.text = widget.bloc.chargePerMinAmount;
      }

      if (int.parse(widget.bloc.chargeCurrencyId) == 1) {
        fromWalletId = '1';
      }
      if (int.parse(widget.bloc.chargeCurrencyId) == 7) {
        fromWalletId = '7';
      }
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void getWallet(Wallet wallet) async {
    setState(() {
      this.fromWalletId = wallet.walletId.toString();
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
        setState(() {
          fromWalletId = responseMap['wallet_id'];
          activeCurrencyCode = responseMap['currency_code'];
        });
      }
    }
  }

  getDetails() async {
    this.isLoading = true;
    var userData =
        Provider.of<UserProvider>(context, listen: false).userData.toMap();
    userData['user_id'] = userData['id'];
    await widget.bloc.tagtalkLogin(userData);
    this.isLoading = false;
    return 'true';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Provider.of<PerspectiveProvider>(context)
                      .getActivePerspective() ==
                  'user'
              ? Colors.black
              : Colors.blue,
          title: Text('Video Charge Settings'),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    // Text("Connecting...")
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.only(top: 10),
                children: [
                  ListTile(
                    title: Text('Charge to receive calls per'),
                    trailing: SizedBox(
                      width: 150,
                      child:
                          // ignore: missing_required_param
                          // DropdownButtonFormField<String>(

                          //         isExpanded: true,
                          //         decoration: const InputDecoration(
                          //           labelText: 'Select Wallet',
                          //           contentPadding:
                          //               EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          //           border: const OutlineInputBorder(),
                          //         ),
                          //         value: _currentSelectedValue,
                          //         icon: Icon(Icons.arrow_downward),
                          //        items: callPer.map((String value) {
                          //             return DropdownMenuItem<String>(
                          //               value: value,
                          //               child: Text(
                          //                 value,
                          //                 overflow: TextOverflow.ellipsis,
                          //               ),
                          //             );
                          //           }).toList(),
                          //         // onChanged: (Wallet newValue) =>
                          //         //     widget.onSelected(newValue),
                          //       )

                          FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              border: const OutlineInputBorder(),

                              // border: OutlineInputBorder(
                              //     borderRadius: BorderRadius.circular(5.0)
                              //     )
                            ),
                            // isEmpty: _currentSelectedValue == '',

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currentSelectedValue,
                                isDense: true,
                                icon: Icon(Icons.arrow_downward),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _currentSelectedValue = newValue;
                                    state.didChange(newValue);
                                    if (_currentSelectedValue == 'Session') {
                                      isMinute = false;
                                    } else {
                                      isMinute = true;
                                    }
                                  });
                                },
                                items: callPer.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(10),
                     color: Colors.black12,
                    child: Text('Enter details for charge to receive call'),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _videoChargeFormKey,
                      child: Column(
                        children: [
                          SizedBox(height: 15),
                          WalletsDropdown(
                            currencyCode:
                                ValueNotifier<String>(fromWalletId.toString()),
                            onSelected: (wallet) => getWallet(wallet),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.account_balance_wallet,
                              ),
                              labelText: 'Amount PHP',
                              hintText: 'Enter amount',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter valid amount';
                              }
                              return null;
                            },
                          ),
                          isMinute || _currentSelectedValue == 'Minute'
                              ? Container()
                              : Column(
                                  children: [
                                    SizedBox(height: 15),
                                    TextFormField(
                                      controller: _timeController,
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.access_time),
                                        labelText: 'Minutes',
                                        hintText: 'Minutes for session',
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter Minutes';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              child: Text(
                                'Save',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: Colors.white),
                              ),
                              color: kPrimaryColor,
                              onPressed: () async {
                                if (_videoChargeFormKey.currentState
                                    .validate()) {
                                  // print(fromWalletId);
                                  setState(() {
                                    isLoading = true;
                                  });
                                  widget.bloc
                                      .setCharge(
                                          widget.bloc.myTagcashId,
                                          _amountController.text,
                                          fromWalletId,
                                          isMinute,
                                          _timeController.text)
                                      .then((val) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  )
                ],
              ));
  }
}
