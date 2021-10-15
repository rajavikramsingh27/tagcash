import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/wallets_dropdown.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:tagcash/constants.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/components/image_select_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'models/scratch_card.dart';

class ScratchcardCreatePage extends StatefulWidget {
  //final scratchObj;

  //ScratchcardCreatePage({this.scratchObj});
  final ScratchCard scratchObj;
  const ScratchcardCreatePage({Key key, this.scratchObj}) : super(key: key);

  @override
  CreateScratchCardState createState() => CreateScratchCardState();
}

bool isLoading = false;
List<int> _scratchFile;
var walletId;

class CreateScratchCardState extends State<ScratchcardCreatePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  List<CARDTYPEITEMS> _cardTypes = CARDTYPEITEMS.getCardTypes();
  List<DropdownMenuItem<CARDTYPEITEMS>> _dropdownMenuItems;
  CARDTYPEITEMS _selectedCardTypes;

  List<GRIDTYPEITEMS> _gridTypes = GRIDTYPEITEMS.getCardTypes();
  List<DropdownMenuItem<GRIDTYPEITEMS>> _gridMenuItems;
  GRIDTYPEITEMS _selectedGridTypes;

  Future<List<Role>> rolesListData;
  Role roleSelected;

  bool isLoading = false;
  bool enableAutoValidate = false;
  bool transferClickPossible = true;
  int cardTypeValue;
  int cardNowId;
  String imgUrl = null;
  String currencyCode;
  String defaultCurrencyCode;

  final titleInput = TextEditingController();
  final winAmtInput = TextEditingController();
  final quantityInput = TextEditingController();
  final hiddenTagsInput = TextEditingController();
  final triesPerInput = TextEditingController();
  var cardTypeDetailTxt;
  var cardAttemptDetailTxt;
  var obj;
  int adTypeIndex = 0;
  int gridTypeIndex = 0;
  int gridNumber = 0;
  bool oneAttemptStat = false;
  bool enableTriesInputAreaBo = false;
  bool enableBoxBo = false;
  bool isEnableRoleList = false;

  void initState() {
    oneAttemptStat = true;
    enableBoxBo = true;
    isEnableRoleList = false;
    hiddenTagsInput.text = 3.toString();
    _dropdownMenuItems = buildDropdownMenuItems(_cardTypes);
    _selectedCardTypes = _dropdownMenuItems[0].value;
    cardTypeValue = _selectedCardTypes.value;
    _gridMenuItems = buildGridDropdownMenuItems(_gridTypes);
    _selectedGridTypes = _gridMenuItems[0].value;
    gridTypeIndex = _selectedGridTypes.value;
    walletId = null;
    if (widget.scratchObj != null) {
      titleInput.text = widget.scratchObj.name.toString();
      cardNowId = widget.scratchObj.id;
      walletId = widget.scratchObj.winningAmountWalletId;
      defaultCurrencyCode = walletId.toString();
      currencyCode = widget.scratchObj.currencyCode;
      winAmtInput.text = widget.scratchObj.winningAmount.toString();
      quantityInput.text = widget.scratchObj.quantity.toString();
      hiddenTagsInput.text = widget.scratchObj.noClicksPerAttempt.toString();
      if (widget.scratchObj.scratchcardType == "public") {
        if (widget.scratchObj.kycCheck == "yes") {
          cardTypeDetailTxt = "Free for anyone level 3 verified";
        } else {
          if (widget.scratchObj.roleName != "") {
            cardTypeDetailTxt = "Roles- " + widget.scratchObj.roleName;
          } else {
            cardTypeDetailTxt = "Free for anyone";
          }
        }

        if (widget.scratchObj.noAttempt != null) {
          cardAttemptDetailTxt = "One time attempt";
        } else {
          cardAttemptDetailTxt = widget.scratchObj.noAttemptPerDay.toString() +
              "Tries per 24 Hours";
        }
      } else {
        cardTypeDetailTxt = "Only after user has paid for something";
      }
      if (widget.scratchObj.payForAd == "yes") {
        adTypeIndex = 0;
      } else {
        adTypeIndex = 1;
      }

      if (widget.scratchObj.image == "") {
        imgUrl = null;
      } else {
        imgUrl = widget.scratchObj.image;
      }
      setState(() {
        if (widget.scratchObj.noRows == 3) {
          gridTypeIndex = 0;
          _selectedGridTypes = _gridMenuItems[gridTypeIndex].value;
        } else if (widget.scratchObj.noRows == 4) {
          gridTypeIndex = 1;
          _selectedGridTypes = _gridMenuItems[gridTypeIndex].value;
        } else {
          gridTypeIndex = 2;
          _selectedGridTypes = _gridMenuItems[gridTypeIndex].value;
        }
      });
    } else {}
    rolesListData = rolesListLoad();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleInput.dispose();
    winAmtInput.dispose();
    quantityInput.dispose();
    hiddenTagsInput.dispose();
    triesPerInput.dispose();
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();
    for (var i = 0; i < getData.length; i++) {
      if (getData[i].roleName == "Owner") {
        getData.remove(getData[i]);
      }
    }
    getData.insert(0, Role(id: 0, roleName: 'Any Role'));
    //getData

    return getData;
  }

  List<DropdownMenuItem<CARDTYPEITEMS>> buildDropdownMenuItems(List cardTypes) {
    List<DropdownMenuItem<CARDTYPEITEMS>> items = List();
    for (CARDTYPEITEMS card in cardTypes) {
      items.add(
        DropdownMenuItem(
          value: card,
          child: Text(card.name),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(CARDTYPEITEMS selectedCard) {
    setState(() {
      _selectedCardTypes = selectedCard;
      cardTypeValue = _selectedCardTypes.value;
      if (_selectedCardTypes.value == 2) {
        enableBoxBo = false;
      } else if (_selectedCardTypes.value == 3) {
        isEnableRoleList = true;
      } else {
        enableBoxBo = true;
        isEnableRoleList = false;
      }
    });
  }

  List<DropdownMenuItem<GRIDTYPEITEMS>> buildGridDropdownMenuItems(
      List gridTypes) {
    List<DropdownMenuItem<GRIDTYPEITEMS>> items = List();
    for (GRIDTYPEITEMS grid in gridTypes) {
      items.add(
        DropdownMenuItem(
          value: grid,
          child: Text(grid.name),
        ),
      );
    }
    return items;
  }

  onChangeGridDropdownItem(GRIDTYPEITEMS selectedGrid) {
    setState(() {
      _selectedGridTypes = selectedGrid;
      gridTypeIndex = selectedGrid.value;
    });
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  createScratchCardHandler() async {
    if (walletId == null) {
      var msg = getTranslated(context, "scratch_wallet_select");
      showMessage(msg);
      return;
    }

    if (gridTypeIndex == 0) {
      gridNumber = 3;
    } else if (gridTypeIndex == 1) {
      gridNumber = 4;
    } else {
      gridNumber = 5;
    }
    if (hiddenTagsInput.text == "" ||
        int.parse(hiddenTagsInput.text) < 3 ||
        int.parse(hiddenTagsInput.text) > (gridNumber * gridNumber) - 1) {
      var msg = getTranslated(context, "scratch_hidden_tag_select");
      showMessage(msg);

      return;
    }

    Map<String, String> apiBodyObj = {};

    apiBodyObj['name'] = titleInput.text.toString();
    apiBodyObj['winning_amount_wallet_id'] = walletId.toString();

    if (_scratchFile != null) {
      apiBodyObj['image'] = base64Encode(_scratchFile);
    }

    apiBodyObj['winning_amount'] = winAmtInput.text.toString();
    apiBodyObj['quantity'] = quantityInput.text.toString();
    apiBodyObj['no_rows'] = gridNumber.toString();
    apiBodyObj['no_columns'] = gridNumber.toString();
    apiBodyObj['no_clicks_per_attempt'] = hiddenTagsInput.text.toString();
    apiBodyObj['kyc_check'] = "no";
    if (cardTypeValue == 0 || cardTypeValue == 1 || cardTypeValue == 3) {
      apiBodyObj['scratchcard_type'] = "public";

      if (oneAttemptStat == true) {
        apiBodyObj['no_attempt'] = 1.toString();
      } else {
        apiBodyObj['no_attempt_per_day'] = triesPerInput.text.toString();
      }
      if (cardTypeValue == 1) {
        apiBodyObj['kyc_check'] = "yes";
      }
      if (isEnableRoleList == true) {
        if (roleSelected != null) {
          apiBodyObj['role_id'] = roleSelected.id.toString();
        } else {
          var msg = getTranslated(context, "scratch_select_role");
          showMessage(msg);
          return;
        }
      }
    } else if (cardTypeValue == 2) {
      apiBodyObj['scratchcard_type'] = "payment_linked";
    }
    if (adTypeIndex == 0) {
      apiBodyObj['pay_for_ad'] = "yes";
    } else {
      apiBodyObj['pay_for_ad'] = "no";
    }
    apiBodyObj['location_based_access'] = "no";
    if (roleSelected != null) {
      apiBodyObj['role_type '] = roleSelected.id.toString();
    }

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('scratchCard/create', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Navigator.of(context).pop({'status': 'createSuccess'});
    } else {
      var msg = getTranslated(context, "scratch_unable_create");
      showMessage(msg);
    }
  }

  updateScratchCardHandler() async {
    if (gridTypeIndex == 0) {
      gridNumber = 3;
    } else if (gridTypeIndex == 1) {
      gridNumber = 4;
    } else {
      gridNumber = 5;
    }
    if (hiddenTagsInput.text == "" ||
        int.parse(hiddenTagsInput.text) < 3 ||
        int.parse(hiddenTagsInput.text) > (gridNumber * gridNumber) - 1) {
      var msg = getTranslated(context, "scratch_hidden_tag_select");
      showMessage(msg);
      return;
    }
    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = cardNowId.toString();
    apiBodyObj['name'] = titleInput.text.toString();
    if (_scratchFile != null) {
      apiBodyObj['image'] = base64Encode(_scratchFile);
    }
    apiBodyObj['winning_amount'] = winAmtInput.text.toString();
    apiBodyObj['quantity'] = quantityInput.text.toString();
    apiBodyObj['no_rows'] = gridNumber.toString();
    apiBodyObj['no_columns'] = gridNumber.toString();
    apiBodyObj['no_clicks_per_attempt'] = hiddenTagsInput.text.toString();

    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('scratchCard/update', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Navigator.of(context).pop({'status': 'updateSuccess'});
    } else {
      var msg = getTranslated(context, "scratch_unable_create");
      showMessage(msg);
    }
  }

  deleteScratchCardHandle() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = cardNowId.toString();
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('scratchCard/delete', apiBodyObj);
    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      Navigator.of(context).pop({'status': 'deleteSuccess'});
    } else {
      var msg = getTranslated(context, "scratch_unable_create");
      showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "scratchcard_create"),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: enableAutoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.all(kDefaultPadding),
              children: [
                SizedBox(height: 10),
                TextFormField(
                  controller: titleInput,
                  decoration: InputDecoration(
                      labelText: getTranslated(context, "scratch_title")),
                  validator: (titleInput) {
                    if (titleInput.isEmpty) {
                      return getTranslated(context, "scratch_title_require");
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                ImageSelectFormField(
                  icon: Icon(Icons.note),
                  labelText: getTranslated(context, "scratch_img"),
                  hintText: getTranslated(context, "scratch_img_add"),
                  source: ImageFrom.both,
                  imageURL: imgUrl,
                  crop: true,
                  onChanged: (img) {
                    if (img != null) {
                      _scratchFile = img;
                    }
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 135,
                      child: WalletsDropdown(
                        currencyCode:
                            ValueNotifier<String>(defaultCurrencyCode),
                        onSelected: (wallet) {
                          walletId = wallet.walletId;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: winAmtInput,
                        validator: (winAmtInput) {
                          if (winAmtInput.isEmpty) {
                            var msg = getTranslated(
                                context, "scratch_win_amount_require");
                            return msg;
                          }
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "scratch_win_amount"),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: quantityInput,
                        validator: (quantityInput) {
                          if (quantityInput.isEmpty) {
                            var msg =
                                getTranslated(context, "scratch_qty_require");
                            return msg;
                          }
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: getTranslated(context, "scratch_qty"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                (widget.scratchObj != null)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text(getTranslated(context, "scratchcard_type"),
                                style: Theme.of(context).textTheme.subtitle1),
                            SizedBox(height: 10),
                            (cardTypeDetailTxt != null)
                                ? Text(cardTypeDetailTxt.toString(),
                                    style:
                                        Theme.of(context).textTheme.subtitle2)
                                : SizedBox(),
                            SizedBox(height: 10),
                            (cardAttemptDetailTxt != null)
                                ? Text(cardAttemptDetailTxt.toString(),
                                    style:
                                        Theme.of(context).textTheme.subtitle2)
                                : SizedBox(),
                            SizedBox(height: 10),
                            adTypeIndex == 0
                                ? Text(
                                    getTranslated(
                                        context, "scartch_advt_private"),
                                    style:
                                        Theme.of(context).textTheme.subtitle1)
                                : adTypeIndex == 1
                                    ? Text(
                                        getTranslated(
                                            context, "scartch_advt_public"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1)
                                    : SizedBox(),
                          ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            DropdownButtonFormField(
                              value: _selectedCardTypes,
                              items: _dropdownMenuItems,
                              onChanged: onChangeDropdownItem,
                            ),
                            //  SizedBox(height: 20),
                            Visibility(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  FutureBuilder(
                                      future: rolesListData,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Role>> snapshot) {
                                        if (snapshot.hasError)
                                          print(snapshot.error);

                                        return snapshot.hasData
                                            ? DropdownButtonFormField<Role>(
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Select Role',
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                value: roleSelected,
                                                icon:
                                                    Icon(Icons.arrow_downward),
                                                iconSize: 24,
                                                items: snapshot.data.map<
                                                        DropdownMenuItem<Role>>(
                                                    (Role value) {
                                                  return DropdownMenuItem<Role>(
                                                    value: value,
                                                    child: Text(value.roleName),
                                                  );
                                                }).toList(),
                                                onChanged: (Role newValue) {
                                                  setState(() {
                                                    print("object" +
                                                        newValue.id.toString());
                                                    roleSelected = newValue;
                                                  });
                                                },
                                              )
                                            : Center(child: Loading());
                                      }),
                                ],
                              ),
                              visible: isEnableRoleList,
                            ),
                            SizedBox(height: 20),
                            Visibility(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          child: Column(
                                            children: [
                                              CheckboxListTile(
                                                title: Text(getTranslated(
                                                    context,
                                                    "scratch_one_time")),
                                                value: oneAttemptStat,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    oneAttemptStat = newValue;
                                                    if (oneAttemptStat ==
                                                        true) {
                                                      enableTriesInputAreaBo =
                                                          false;
                                                    } else {
                                                      enableTriesInputAreaBo =
                                                          true;
                                                    }
                                                  });
                                                },
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .leading,
                                              ),
                                              Center(
                                                child: Text(
                                                  getTranslated(
                                                      context, "scratch_or"),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              TextFormField(
                                                controller: triesPerInput,
                                                enabled: enableTriesInputAreaBo,
                                                decoration: InputDecoration(
                                                    labelText: getTranslated(
                                                        context,
                                                        "scratch_tyre")),
                                                validator: (triesPerInput) {
                                                  if (triesPerInput.isEmpty &&
                                                      enableTriesInputAreaBo ==
                                                          true) {
                                                    var msg = getTranslated(
                                                        context,
                                                        "scratch_tyre_require");
                                                    return msg;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              visible: enableBoxBo,
                            ),
                            RadioListTile(
                              value: 0,
                              title: Text(getTranslated(
                                  context, "scartch_advt_private")),
                              groupValue: adTypeIndex,
                              onChanged: (value) {
                                setState(() {
                                  adTypeIndex = value;
                                });
                              },
                            ),
                            RadioListTile(
                              value: 1,
                              title: Text(getTranslated(
                                  context, "scartch_advt_public")),
                              groupValue: adTypeIndex,
                              onChanged: (value) {
                                setState(() {
                                  adTypeIndex = value;
                                });
                              },
                            ),
                          ]),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField(
                        value: _selectedGridTypes,
                        items: _gridMenuItems,
                        onChanged: onChangeGridDropdownItem,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: hiddenTagsInput,
                        validator: (hiddenTagsInput) {
                          if (hiddenTagsInput.isEmpty) {
                            var msg = getTranslated(
                                context, "scratch_hidden_tag_require");
                            return msg;
                          }
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText:
                              getTranslated(context, "scratch_hidden_tag"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(getTranslated(context, "scratch_create_msg"),
                    style: Theme.of(context).textTheme.subtitle2),
                SizedBox(height: 10),
                (widget.scratchObj != null)
                    ? Row(
                        children: [
                          Expanded(
                            child: RaisedButton(
                              child: Text(getTranslated(context, "delete")),
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.black,
                              textColor:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                              onPressed: () {
                                deleteScratchCardHandle();
                              },
                            ),
                            flex: 1,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: RaisedButton(
                              child: Text(getTranslated(context, "update")),
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              onPressed: () {
                                setState(() {
                                  enableAutoValidate = true;
                                });
                                if (_formKey.currentState.validate()) {
                                  updateScratchCardHandler();
                                }
                              },
                            ),
                            flex: 1,
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text(getTranslated(context, "save")),
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              enableAutoValidate = true;
                            });
                            if (_formKey.currentState.validate()) {
                              createScratchCardHandler();
                            }
                          },
                        ),
                      ),
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class CARDTYPEITEMS {
  int value;
  String name;

  CARDTYPEITEMS(this.value, this.name);

  static List<CARDTYPEITEMS> getCardTypes() {
    return <CARDTYPEITEMS>[
      CARDTYPEITEMS(0, 'Free for anyone'),
      CARDTYPEITEMS(3, 'Roles'),
      CARDTYPEITEMS(1, 'Free for anyone level 3 verified'),
      CARDTYPEITEMS(2, 'Only after user has paid for something'),
    ];
  }
}

class GRIDTYPEITEMS {
  int value;
  String name;

  GRIDTYPEITEMS(this.value, this.name);

  static List<GRIDTYPEITEMS> getCardTypes() {
    return <GRIDTYPEITEMS>[
      GRIDTYPEITEMS(0, 'Grid 3x3'),
      GRIDTYPEITEMS(1, 'Grid 4x4'),
      GRIDTYPEITEMS(2, 'Grid 5x5'),
    ];
  }
}
