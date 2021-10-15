import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/agents/agent_create_location.dart';
import 'package:tagcash/apps/agents/models/agent_location.dart';
//import 'package:tagcash/apps/expense/create_expense_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';

class AgentLocationsScreen extends StatefulWidget {
  @override
  _AgentLocationsScreenState createState() => _AgentLocationsScreenState();
}

class _AgentLocationsScreenState extends State<AgentLocationsScreen> {
  Future<List<AgentLocation>> agentLocations;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    agentLocations = agentLocationsLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<AgentLocation>> agentLocationsLoad() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/GetAddedLocations');

    List responseList = response['result'];
    setState(() {
      isLoading = false;
    });
    List<AgentLocation> getData = responseList.map<AgentLocation>((json) {
      return AgentLocation.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, "agents"),
      ),
      body: FutureBuilder(
        future: agentLocations,
        builder: (BuildContext context,
            AsyncSnapshot<List<AgentLocation>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        child: GestureDetector(
                            onTap: () {
                              _listItemTapped(snapshot.data[index].id);
                            },
                            child: LocationRowItem(snapshot.data[index].name,
                                snapshot.data[index].id,
                                onDelete: () => deleteLocationHandler(
                                    snapshot.data[index].id))));
                  })
              : Center(child: Loading());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
//            Navigator.push(
//                context,
//                MaterialPageRoute(
//                    builder: (context) => AgentCreateScreen(locationId: 0)));
            _listItemTapped(0);
          });
          //_createButtonTapped();
        },
        //tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  Future _listItemTapped(int locationId) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AgentCreateScreen(locationId: locationId),
    ));
    if (results != null && results.containsKey('status')) {
      agentLocations = agentLocationsLoad();

      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "agent_add_location_details")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'updateSuccess') {
          final snackBar = SnackBar(
              content: Text(getTranslated(context, "agent_update_location_details")),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  deleteLocationHandler(int id) async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['location_id'] = id;
    Map<String, dynamic> response =
        await NetworkHelper.request('Agent/DeleteAgentLocation', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      agentLocations = agentLocationsLoad();
    } else {
      setState(() {
        isLoading = false;
      });
      String err = response['error'];
      final snackBar =
          SnackBar(content: Text(err), duration: const Duration(seconds: 3));
      globalKey.currentState.showSnackBar(snackBar);
    }
  }
}

class LocationRowItem extends StatelessWidget {
  final String name;
  final int id;
  final VoidCallback onDelete;

  LocationRowItem(this.name, this.id, {this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
                icon: Icon(Icons.delete),
                color: kPrimaryColor,
                iconSize: 24,
                tooltip: 'Delete',
                onPressed: () {
                  //this.onDelete,
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _DeleteLocationDialog(
                          onDSuccess: (value) {
                            //deleteLoanHandler();
                            this.onDelete();
                          },
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}

class _DeleteLocationDialog extends StatefulWidget {
  _DeleteLocationDialog({this.onDSuccess});

  ValueChanged<String> onDSuccess;

  @override
  _DeleteLocationDialogState createState() => _DeleteLocationDialogState();
}

class _DeleteLocationDialogState extends State<_DeleteLocationDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text(getTranslated(context, "no")),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(getTranslated(context, "yes")),
      onPressed: () {
        //cancelPledgeHandler();
        widget.onDSuccess('success');
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text(getTranslated(context, "delete_agent_location")),
      content: Text(getTranslated(context, "like_delete_agent_location")),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
