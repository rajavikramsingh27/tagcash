import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/manage_module/models/shop_item.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/services/networking.dart';

class OptionShopTemplate extends StatefulWidget {
  final Function(ShopItem) onShopChanged;

  const OptionShopTemplate({
    Key key,
    this.onShopChanged,
  }) : super(key: key);

  @override
  _OptionShopTemplateState createState() => _OptionShopTemplateState();
}

class _OptionShopTemplateState extends State<OptionShopTemplate> {
  Future<List<ShopItem>> itemListData;
  ShopItem selectedShop;

  @override
  void initState() {
    super.initState();

    itemListData = itemListLoad();
  }

  Future<List<ShopItem>> itemListLoad() async {
    Map<String, String> apiBodyObj = {};
    String communityId = Provider.of<MerchantProvider>(context, listen: false)
        .merchantData
        .id
        .toString();

    apiBodyObj['merchant_id'] = communityId;

    Map<String, dynamic> response = await NetworkHelper.request('shop/my');

    List responseList = response['list'];

    List<ShopItem> getData = responseList.map<ShopItem>((json) {
      return ShopItem.fromJson(json);
    }).toList();

    return getData;
  }

  void popupOptions() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            child: Container(
              width: 320,
              height: 340,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Select Shop',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: itemListData,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ShopItem>> snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: snapshot.data[index].logoThumb !=
                                              ''
                                          ? Container(
                                              height: 50.0,
                                              width: 50.0,
                                              child: Image.network(
                                                snapshot.data[index].logoThumb,
                                                fit: BoxFit.fill,
                                              ),
                                            )
                                          : Container(
                                              height: 50.0,
                                              width: 50.0,
                                              color: Colors.grey,
                                            ),
                                      title: Text(snapshot.data[index].title),
                                      onTap: () {
                                        setState(() {
                                          selectedShop = snapshot.data[index];
                                        });
                                        widget.onShopChanged(selectedShop);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              )
                            : SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: selectedShop != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Shop'),
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  title: Text(selectedShop.title),
                  leading: selectedShop.logoThumb != ''
                      ? Container(
                          height: 50.0,
                          width: 50.0,
                          child: Image.network(
                            selectedShop.logoThumb,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              shape: BoxShape.rectangle,
                              color: Colors.grey),
                        ),
                  onTap: () => popupOptions(),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ],
            )
          : ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              title: Text('Select A Shop'),
              onTap: () => popupOptions(),
              trailing: Icon(Icons.arrow_forward),
            ),
    );
  }
}
