import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/shopping/merchant/update_inventory.dart';
import 'package:tagcash/apps/shopping/models/Inventory.dart';
import 'package:tagcash/apps/shopping/models/shop_merchant.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'add_inventory.dart';

class InventoryList extends StatefulWidget {
  final ShopMerchant shop;

  const InventoryList({Key key, this.shop}) : super(key: key);
  _InventoryListState createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {

  List<Inventory> getInventoryData = new List<Inventory>();
  bool isLoading = false;
  String emptyMessage = '';

  @override
  void initState() {
    super.initState();
    getInventoryList();
  }

  void getInventoryList() async {
    getInventoryData.clear();
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['shop_id'] = widget.shop.id.toString();

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/MyInventory', apiBodyObj);


    if (response['status'] == 'success') {
      if(response['list'] != null){
        List responseList = response['list'];

        getInventoryData = responseList.map<Inventory>((json) {
          return Inventory.fromJson(json);
        }).toList();
      } else{
        emptyMessage = 'No Inventory Found';
        setState(() {
          isLoading = false;
        });
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']);
    }
  }
  void deleteInventory(id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/DeleteInventory', apiBodyObj);

    if (response['status'] == 'success') {
      setState(() {
        isLoading = false;
      });
      getInventoryData.clear();
      getInventoryList();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  getLogo(){
    return NetworkImage(
        "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:
          Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
              'user'
              ? Colors.black
              : Color(0xFFe44933),
          title: Text(''),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home_outlined,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                     child: Container(
                       padding: EdgeInsets.only(left: 20),
                       margin: EdgeInsets.only(top: 20),
                       color: kUserBackColor,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Text(
                             'INVENTORY',
                             style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold),
                             textAlign: TextAlign.start,
                           ),
                           IconButton(
                             icon: Icon(Icons.cancel, color: Colors.white),
                             onPressed:(){
                               Navigator.pop(context);
                             },
                           )
                         ],
                       )
                     )
                    ),
                  ),

                  Flexible(
                    flex: 8,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: getInventoryData.length != 0?
                      ListView.builder(
                        itemCount: getInventoryData.length,
                        itemBuilder: (context, i){
                          return InkWell(
                            onTap: (){
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => UpdateInventory(shop: widget.shop, inventoryId: getInventoryData[i].id.toString())),
                              ).then((val)=>val?getInventoryList():null);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                            child: Row(
                                              children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: getInventoryData[i].images.length != 0?
                                                    NetworkImage(
                                                        getInventoryData[i].images[0].image_thumb)
                                                        : getLogo()
                                                ),
                                              ),
                                              width: 70.0,
                                              height: 70.0,
                                            ),
                                                SizedBox(width: 10),
                                                Container(
                                                  child: Expanded(
                                                    child:  Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          getInventoryData[i].name,
                                                          style: Theme.of(context).textTheme.subtitle1.apply(),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          getInventoryData[i].description,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.normal),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          getInventoryData[i].price.toString(),
                                                          style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )


                                          )
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Widget cancelButton = FlatButton(
                                          child: Text("No"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        );
                                        Widget continueButton = FlatButton(
                                          child: Text("Yes"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            deleteInventory(getInventoryData[i].id.toString());
                                          },
                                        );

                                        AlertDialog alert = AlertDialog(
                                          title: Text(""),
                                          content: Text('Are you sure you want to delete this inventory?'),
                                          actions: [
                                            continueButton,
                                            cancelButton,

                                          ],
                                        );

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        size: 30.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ) : Container(
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  emptyMessage,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline6.apply(),
                                ),
                              ],
                            )
                        ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        child: FlatButton(
                          onPressed: () async {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AddInventory(shop: widget.shop)),
                              ).then((val)=>val?getInventoryList():null);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          child: Container(
                            child: Text(
                              "ADD ITEM",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    )
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )

    );
  }
}
