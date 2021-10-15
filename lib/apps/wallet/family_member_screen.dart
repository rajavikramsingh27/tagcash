import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/constants.dart';

import 'components/add_family_account.dart';
import 'models/family_member.dart';

class FamilyMemberScreen extends StatefulWidget {
  final Wallet wallet;

  const FamilyMemberScreen({Key key, this.wallet}) : super(key: key);

  @override
  _FamilyMemberScreenState createState() => _FamilyMemberScreenState();
}

class _FamilyMemberScreenState extends State<FamilyMemberScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamController<List<FamilyMember>> _streamcontroller;
  List<FamilyMember> _familyMembers;

  @override
  void initState() {
    super.initState();

    _familyMembers = [];
    _streamcontroller = StreamController<List<FamilyMember>>.broadcast();

    familyMembersGetData();
  }

  familyMembersGetData() {
    familyMembersListLoad().then((res) {
      _familyMembers.addAll(res);
      _streamcontroller.add(_familyMembers);
    });
  }

  Future<List<FamilyMember>> familyMembersListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['wallet_id'] = widget.wallet.walletId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('FamilyAccount/ListMembers');

    List responseList = response['result'];

    List<FamilyMember> getData = responseList.map<FamilyMember>((json) {
      return FamilyMember.fromJson(json);
    }).toList();

    return getData;
  }

  void addEditAccountClicked([FamilyMember familyMember]) {
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
                child: AddFamilyAccount(
                  walletId: widget.wallet.walletId.toString(),
                  familyMember: familyMember,
                ),
              ),
            ),
          );
        }).then((value) {
      if (value != null) {
        _familyMembers = [];
        familyMembersGetData();
      }
    });
  }

  void familyMemberDeleteHandler(FamilyMember familyMember) async {
    setState(() {
      familyMember.removing = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['member_id'] = familyMember.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('FamilyAccount/DeleteMember', apiBodyObj);

    if (response['status'] == 'success') {
      _familyMembers.remove(familyMember);
      showSnackBar('Successfully deleted');
    } else {
      familyMember.removing = false;
      showSnackBar(getTranslated(context, 'error_occurred'));
    }
    setState(() {});
  }

  showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'family_account'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addEditAccountClicked(),
        child: Icon(Icons.add),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Text(getTranslated(context, 'family_account_info')),
          ),
          StreamBuilder(
            stream: _streamcontroller.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              if (!snapshot.hasData) {
                return Center(child: Loading());
              } else {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.only(bottom: 60),
                  separatorBuilder: (context, index) => Divider(indent: 70),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    FamilyMember familyMember = snapshot.data[index];

                    return Slidable(
                      key: ValueKey(index),
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => familyMemberDeleteHandler(familyMember),
                        ),
                      ],
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: snapshot.data[index].removing ? 0.3 : 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  AppConstants.getUserImagePath() +
                                      snapshot.data[index].userId.toString() +
                                      "?kycImage=0",
                                ),
                              ),
                              title: Text(familyMember.nickName),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${widget.wallet.currencyCode} ${NumberFormat.currency(name: '').format(double.parse(familyMember.balance.toString()))}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${getTranslated(context, 'limit')} : ${NumberFormat.currency(name: '').format(double.parse(familyMember.maxAmount.toString()))}',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                              onTap: () => addEditAccountClicked(familyMember),
                            ),
                          ),
                          snapshot.data[index].removing
                              ? Center(child: Loading())
                              : SizedBox(),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
