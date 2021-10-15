import 'package:flutter/material.dart';
import 'package:tagcash/apps/biller_setup/biller_setup_create_screen.dart';
import 'package:tagcash/apps/biller_setup/models/merchant_biller.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/constants.dart';

class BillerSetupListScreen extends StatefulWidget {
  @override
  _BillerSetupListScreenState createState() => _BillerSetupListScreenState();
}

class _BillerSetupListScreenState extends State<BillerSetupListScreen> {
  Future<List<MerchantBiller>> merchantBillerListData;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    merchantBillerListData = merchantBillerListLoad();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<MerchantBiller>> merchantBillerListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('billerSetup/MerchantBiller');

    List responseList = response['result'];

    List<MerchantBiller> getData = responseList.map<MerchantBiller>((json) {
      return MerchantBiller.fromJson(json);
    }).toList();

    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Biller Setup',
      ),
      key: globalKey,
      body: FutureBuilder(
        future: merchantBillerListData,
        builder: (BuildContext context,
            AsyncSnapshot<List<MerchantBiller>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: GestureDetector(
                        onTap: () {
                          _listItemTapped(snapshot.data[index]);
                        },
                        child: ListTile(
                          title: Text(
                            snapshot.data[index].title,
                          ),
                        ),
                      ),
                    );
                  })
              : Center(child: Loading());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createButtonTapped();
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  Future _createButtonTapped() async {
    Map results = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BillerSetupCreateScreen()));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'createSuccess') {
          merchantBillerListData = merchantBillerListLoad();
          final snackBar = SnackBar(
              content: Text('Biller created successfully'),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }

  Future _listItemTapped(MerchantBiller merchantBiller) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          BillerSetupCreateScreen(merchantBiller: merchantBiller),
    ));

    if (results != null && results.containsKey('status')) {
      setState(() {
        String status = results['status'];
        if (status == 'updateSuccess') {
          merchantBillerListData = merchantBillerListLoad();
          final snackBar = SnackBar(
              content: Text('Biller updated successfully'),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        } else if (status == 'deleteSuccess') {
          merchantBillerListData = merchantBillerListLoad();
          final snackBar = SnackBar(
              content: Text('Biller deleted successfully'),
              duration: const Duration(seconds: 3));
          globalKey.currentState.showSnackBar(snackBar);
        }
      });
    }
  }
}
