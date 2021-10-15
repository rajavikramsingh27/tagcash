import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/transfer_error.dart';

class SubscriptionOption extends StatefulWidget {
  final String communityId;
  final ValueChanged<String> onSuccess;
  SubscriptionOption({Key key, this.communityId, this.onSuccess})
      : super(key: key);

  @override
  _SubscriptionOptionState createState() => _SubscriptionOptionState();
}

class _SubscriptionOptionState extends State<SubscriptionOption> {
  bool isLoading = false;

  Future<List<Role>> rolesListData;

  @override
  void initState() {
    super.initState();

    rolesListData = rolesListLoad();
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['community_id'] = widget.communityId;
    apiBodyObj['role_type'] = 'member';
    Map<String, dynamic> response =
        await NetworkHelper.request('role/list', apiBodyObj);

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();

    return getData;
  }

  void joinCommunity(String roleID) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = widget.communityId;
    apiBodyObj['role_id'] = roleID;

    Map<String, dynamic> response =
        await NetworkHelper.request('community/join', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.of(context).pop();
      showSnackBar(getTranslated(context, 'successfully_joined_businesses'));

      widget.onSuccess('success');
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
      Navigator.of(context).pop();
    }
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(
        msg: message,
        webPosition: 'center',
        webBgColor: 'linear-gradient(to right, #FF0000, #FF0000)');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            getTranslated(context, 'choose_subscription_option'),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 20),
          FutureBuilder(
            future: rolesListData,
            builder:
                (BuildContext context, AsyncSnapshot<List<Role>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                              title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data[index].roleName,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (snapshot.data[index].currencyCode != '')
                                      Text(
                                        snapshot.data[index].currencyCode +
                                            " " +
                                            snapshot.data[index].fee,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ]),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  joinCommunity(
                                      snapshot.data[index].id.toString());
                                },
                                child: Text(getTranslated(context, 'join')),
                              )),
                        );
                      },
                    )
                  : Center(child: Loading());
            },
          ),
          if (isLoading) Center(child: Loading())
        ],
      ),
    );
  }
}
