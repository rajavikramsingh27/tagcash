import 'package:flutter/material.dart';
import 'package:tagcash/apps/shopping/models/favorite.dart';
import 'package:tagcash/apps/shopping/models/product.dart';
import 'package:tagcash/apps/shopping/user/shop_cart_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';


class ShopFavoriteListScreen extends StatefulWidget {

  @override
  _ShopFavoriteistScreenState createState() => _ShopFavoriteistScreenState();
}

class _ShopFavoriteistScreenState extends State<ShopFavoriteListScreen> {
  bool isLoading = false;

  List<Favorite> getfavoriteData = new List<Favorite>();
  List<Product> getProductData = new List<Product>();

  String emptyMessage = '';

  @override
  void initState() {
    super.initState();
    getFavoriteList();
  }

  void getFavoriteList() async {
    getfavoriteData.clear();
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response =
    await NetworkHelper.request('shop/FavoriteList');


    if (response['status'] == 'success') {
      if(response['list'] != null){
        List responseList = response['list'];
        getfavoriteData = responseList.map<Favorite>((json) {
          return Favorite.fromJson(json);
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else{
        emptyMessage = 'No favorites yet';
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: response['error']);
    }
  }

  void removeFavorite(String favourite_id) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = favourite_id;

    Map<String, dynamic> response =
    await NetworkHelper.request('shop/RemoveFavourite', apiBodyObj);
    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });

      getFavoriteList();

    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: Stack(
          children: [
            Container(
              child: getfavoriteData.length != 0?
              ListView.builder(
                  itemCount: getfavoriteData.length,
                  itemBuilder: (context, index){
                    return InkWell(
                      onTap: (){
                        Product product = new Product(0, '','', 0, 0, 0, '', '', false, 0, '', '', '');
                        product.id = getfavoriteData[index].product_id;
                        product.name = getfavoriteData[index].name;
                        product.description = getfavoriteData[index].description;
                        product.price = getfavoriteData[index].price;
                        product.shipment_days = getfavoriteData[index].shipment_days;
                        product.stock = getfavoriteData[index].stock;
                        product.currency_code = getfavoriteData[index].currency_code;
                        product.image_thumb = getfavoriteData[index].image_thumb;
                        product.favorite = getfavoriteData[index].favourite;
                        product.favorite_id = getfavoriteData[index].id;
                        product.images = getfavoriteData[index].images;
                        product.other_option_name = getfavoriteData[index].other_option_name;
                        product.other = getfavoriteData[index].other;
                        product.color_option_name = getfavoriteData[index].color_option_name;
                        product.color = getfavoriteData[index].color;
                        product.size_option_name = getfavoriteData[index].size_option_name;
                        product.size = getfavoriteData[index].size;
                        getProductData.add(product);

                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ShopCartScreen(getProductData: getProductData,index: 0,
                              shopId: getfavoriteData[index].shop_id.toString(), shopName: getfavoriteData[index].shop_name, shopImage: '', shopDesc: '', isType: '1')),
                        ).then((val)=>val? getFavoriteList():null);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: getfavoriteData[index].image_thumb != ''?
                                      NetworkImage(
                                          getfavoriteData[index].image_thumb)
                                          :NetworkImage(
                                          "https://dummyimage.com/50x50/cccccc/000000.jpg&text=Image")
                                  ),
                                ),
                                width: 70.0,
                                height: 60.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: GestureDetector(
                                    onTap: (){
                                    },
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getfavoriteData[index].name,
                                            style: Theme.of(context).textTheme.subtitle1.apply()
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            getfavoriteData[index].currency_code + ' ' + getfavoriteData[index].price.toString(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
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
                                      removeFavorite(getfavoriteData[index].id.toString());
                                    },
                                  );

                                  AlertDialog alert = AlertDialog(
                                    title: Text(""),
                                    content: Text('Are you sure to remove this product from favorite?'),
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
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
}
