import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'add_claim_user_screen.dart';
import 'models/claim_user_obj.dart';

class ExpenseSettingsPage extends StatefulWidget {
  const ExpenseSettingsPage({Key key}) : super(key: key);

  @override
  _ExpenseSettingsPageState createState() => _ExpenseSettingsPageState();
}

class _ExpenseSettingsPageState extends State<ExpenseSettingsPage> {
  Future<List<ClaimUserObj>> addCliamUserList;
  bool isLoading = false;
  void initState() {
    addCliamUserList = getCliamUserList();
    super.initState();
  }

  Future<List<ClaimUserObj>> getCliamUserList() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/ListClaimUsers', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    List<ClaimUserObj> getData = List<ClaimUserObj>();
    List responseList = response['list'];

    if (responseList != null) {
      getData = responseList.map<ClaimUserObj>((json) {
        return ClaimUserObj.fromJson(json);
      }).toList();
    }
    return getData;
  }

  deleteClaimUser(id) async {
    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {};
    apiBodyObj['claimuser_id'] = id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('Expense/DeleteClaimUser', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response["status"] == "success") {
      addCliamUserList = getCliamUserList();
    }
  }

  deleteUser(obj) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(getTranslated(context, "delete"),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .apply(color: Colors.red)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    getTranslated(context, "expense_delete_group"),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text(getTranslated(context, "no")),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          child: Text(getTranslated(context, "yes")),
                          onPressed: () {
                            Navigator.of(context).pop();
                            deleteClaimUser(obj.claimuserId);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: addCliamUserList,
            builder: (BuildContext context,
                AsyncSnapshot<List<ClaimUserObj>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              return snapshot.hasData
                  ? ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        indent: 70,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        int userType = snapshot.data[index].userType;
                        return Slidable(
                          key: ValueKey(index),
                          actionPane: SlidableDrawerActionPane(),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: getTranslated(context, "delete"),
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => deleteUser(snapshot.data[index]),
                            ),
                          ],
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                userType == 1
                                    ? AppConstants.getUserImagePath() +
                                        snapshot.data[index].userId.toString() +
                                        "?kycImage=0"
                                    : AppConstants.getCommunityImagePath() +
                                        snapshot.data[index].userId.toString(),
                              ),
                            ),
                            title: Text(
                              userType == 1
                                  ? snapshot.data[index].userFirstName +
                                      " " +
                                      snapshot.data[index].userLastName
                                  : snapshot.data[index].communityName,
                            ),
                            subtitle: Text(
                              userType == 1
                                  ? snapshot.data[index].roleType == null
                                      ? getTranslated(
                                          context, "expense_non_member")
                                      : snapshot.data[index].roleName
                                  : getTranslated(context, "expense_group"),
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox();
            },
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (_) => AddClaimUserScreen()),
              )
              .then(
                  (val) => val ? addCliamUserList = getCliamUserList() : null);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
