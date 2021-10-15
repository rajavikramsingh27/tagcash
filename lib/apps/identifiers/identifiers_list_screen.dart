import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/apps/identifiers/identifiers_create_screen.dart';
import 'package:tagcash/apps/identifiers/model/identifierdata.dart';
import 'package:tagcash/components/loading.dart';
import 'dart:async';

class IdentifiersListScreen extends StatefulWidget {
  @override
  _IdentifiersListScreenState createState() => _IdentifiersListScreenState();
}

class _IdentifiersListScreenState extends State<IdentifiersListScreen> {
  StreamController<List<IdentifierData>> _streamcontroller;
  List<IdentifierData> _data;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _data = <IdentifierData>[];
    _streamcontroller = StreamController<List<IdentifierData>>.broadcast();

    identifierListLoad();
  }

  searchClicked(String searchKey) {
    identifierListLoad(searchKey);
  }

  identifierListLoad([String searchKey]) {
    _data = <IdentifierData>[];
    _streamcontroller.add(null);

    loadIdentifiersList(searchKey).then((res) {
      _data.addAll(res);
      _streamcontroller.add(_data);
    });
  }

  Future<List<IdentifierData>> loadIdentifiersList([String searchKey]) async {
    Map<String, String> apiBodyObj = {};

    if (searchKey != null && searchKey.isNotEmpty) {
      apiBodyObj['search'] = searchKey;
    }

    Map<String, dynamic> response =
        await NetworkHelper.request('identifiers/myIdentifiers', apiBodyObj);

    List<IdentifierData> getData = <IdentifierData>[];
    List responseList = response['result'];

    if (responseList != null) {
      getData = responseList.map<IdentifierData>((json) {
        return IdentifierData.fromJson(json);
      }).toList();
    }

    return getData;
  }

  void identifiersManageClicked([IdentifierData identifierData]) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => IdentifiersCreateScreen(
                createValue: identifierData == null ? true : false,
                identifierData: identifierData,
              )),
    ).then((value) {
      if (value != null) {
        identifierListLoad();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => identifiersManageClicked(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: _streamcontroller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ListView.separated(
                    padding: EdgeInsets.only(top: 10, bottom: 100),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                          snapshot.data[index].identifierName,
                        ),
                        onTap: () =>
                            identifiersManageClicked(snapshot.data[index]),
                      );
                    })
                : Center(child: Loading());
          }),
    );
  }
}
