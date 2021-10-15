import 'package:flutter/material.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'roles_edit_screen.dart';

class RolesScreen extends StatefulWidget {
  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  Future<List<Role>> rolesListData;

  @override
  void initState() {
    super.initState();

    rolesListData = rolesListLoad();
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();

    return getData;
  }

  void roleAddClickHandle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RolesEditScreen(),
      ),
    ).then((value) {
      if (value != null) {
        rolesListData = rolesListLoad();
        setState(() {});
      }
    });
  }

  void roleClickHandle(Role role) {
    if (role.roleType != 'owner') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RolesEditScreen(role: role),
        ),
      ).then((value) {
        if (value != null) {
          rolesListData = rolesListLoad();
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'roles'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => roleAddClickHandle(),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: rolesListData,
        builder: (BuildContext context, AsyncSnapshot<List<Role>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      child: ListTile(
                        title: Text(snapshot.data[index].roleName),
                        subtitle: Text(
                            '${snapshot.data[index].currencyCode} ${snapshot.data[index].fee}'),
                        trailing: buildTypeIndicator(
                            snapshot.data[index].roleType,
                            snapshot.data[index].roleDefault),
                        onTap: () => roleClickHandle(snapshot.data[index]),
                      ),
                    );
                  },
                )
              : Center(child: Loading());
        },
      ),
    );
  }

  Widget buildTypeIndicator(String roleType, bool roleDefault) {
    if (roleType == 'member' || roleType == 'staff') {
      return Container(
        width: 28,
        height: 28,
        child: Center(
            child: Text(
          roleType == 'staff' ? 'S' : 'M',
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: roleDefault ? Colors.white : Colors.grey),
        )),
        decoration: BoxDecoration(
            color: roleDefault ? Colors.red : null,
            shape: BoxShape.circle,
            border: roleDefault
                ? null
                : Border.all(
                    color: Colors.grey,
                  )),
      );
    } else {
      return SizedBox();
    }
  }
}
