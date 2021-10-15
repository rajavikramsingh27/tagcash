import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/components/image_source_select.dart';
import 'package:path/path.dart' as path;

import 'models/transaction.dart';
import 'models/transaction_category.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({Key key, this.transaction}) : super(key: key);
  @override
  _TransactionDetailScreenState createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  final picker = ImagePicker();
  File _imageFile;

  MapboxMapController controller;
  final formatCurrency = NumberFormat.currency(locale: "en_US", symbol: "");

  bool categoryCardShow = true;
  bool receiptPossible = false;
  bool splitPossible = false;
  bool positionAvailable = false;
  bool narrationInput = false;
  TextEditingController _notesController = TextEditingController();

  Future<List<TransactionCategory>> categoryList;
  TransactionCategory categoryDropdownValue;

  @override
  void initState() {
    if (widget.transaction.lat != '0.00000000' &&
        widget.transaction.log != '0.00000000') {
      positionAvailable = true;
    }

    if (widget.transaction.direction == 'out') {
      if (widget.transaction.receiptImage.isEmpty) {
        receiptPossible = true;
      }
      if (!widget.transaction.splitted) {
        splitPossible = true;
      }

      categoryList = categoryListLoad();

      categoryList.then((value) {
        for (var item in value) {
          if (widget.transaction.transactionCategoryId == item.id) {
            categoryDropdownValue = item;
          }
        }
      });
    }

    if (widget.transaction.direction == 'in' &&
        widget.transaction.transactionCategory.isEmpty) {
      categoryCardShow = false;
    }

    super.initState();
  }

  @override
  void dispose() {
    _notesController.dispose();

    super.dispose();
  }

  Future<List<TransactionCategory>> categoryListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('Wallet/transactionCategory');

    List responseList = response['result'];

    List<TransactionCategory> getData =
        responseList.map<TransactionCategory>((json) {
      return TransactionCategory.fromJson(json);
    }).toList();

    return getData;
  }

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/custom-icon.png");

    // controller.addSymbol(SymbolOptions(
    //   geometry: LatLng(activeAgent.latitude, activeAgent.longitude),
    //   iconImage: 'assetImage',
    //   iconSize: 1.5,
    // ));
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller.addImage(name, list);
  }

  void attachReceiptClick() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ImageSourceSelect(
            onSelected: (ImageSource imageSource) => getImage(imageSource),
          );
        });
  }

  void getImage(ImageSource imageSource) async {
    PickedFile pickedFile = await picker.getImage(source: imageSource);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        receiptPossible = false;
      });

      Map<String, String> apiBodyObj = {};

      Map<String, dynamic> fileData;
      String basename = path.basename(_imageFile.path);

      fileData = {};
      fileData['key'] = 'receipt';
      fileData['fileName'] = basename;
      fileData['path'] = _imageFile.path;
      fileData['bytes'] = await pickedFile.readAsBytes();

      updateTransactionMetaData(apiBodyObj, fileData);
    }
  }

  void removeReceiptHandle() async {
    setState(() {
      widget.transaction.receiptImage = '';
      receiptPossible = true;
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['transaction_id'] = widget.transaction.id.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('wallet/DeleteReceiptImage', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {}
  }

  void updateTransactionNote() {
    if (_notesController.text.isEmpty) {
      return;
    }

    setState(() {
      widget.transaction.narration = _notesController.text;
      narrationInput = false;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['narration'] = _notesController.text;

    updateTransactionMetaData(apiBodyObj);
  }

  void updateCategory() {
    setState(() {
      widget.transaction.transactionCategoryId = categoryDropdownValue.id;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['category_id'] = categoryDropdownValue.id;

    updateTransactionMetaData(apiBodyObj);
  }

  // split_transfer - 1 or 0
  //

  void updateTransactionMetaData(Map updateData, [Map file]) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['transaction_id'] = widget.transaction.id.toString();

    Map<String, String> data = {...?apiBodyObj, ...?updateData};

    Map<String, dynamic> response = await NetworkHelper.request(
        'wallet/UpdateTransactionMetaData', data, file);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Map responseMap = response['result'];

      if (file != null && responseMap.containsKey('image_url')) {
        widget.transaction.receiptImage = responseMap['image_url'];
        setState(() {
          _imageFile = null;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'error_occurred'));

      //   invalid_transaction_id
      // upload_to_s3_failed
      // receipt_invalid_file_type_allowded_are_...
      // incomplete_upload
      // not_own_transaction
      // invalid_category_id
      // narration_already_exist
    }
  }

  void notesCopy() {
    Clipboard.setData(new ClipboardData(text: widget.transaction.narration));
    showSnackBar(getTranslated(context, 'copied_clipboard'));
  }

  void showImage(String imagePath) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20.0),
              child: Image(
                image: NetworkImage(imagePath),
              ),
            ),
          );
        });
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
      appBar: AppBar(
        brightness: Brightness.dark,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(10),
            children: [
              Row(
                children: [
                  Text(
                    widget.transaction.direction == 'in' ? '+' : '-',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    '${formatCurrency.format(double.parse(widget.transaction.fromAmount))}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 40),
                  ),
                ],
              ),
              Text(
                widget.transaction.firstName != ''
                    ? widget.transaction.firstName +
                        ' ' +
                        widget.transaction.lastName
                    : widget.transaction.communityName,
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                DateFormat('h:mm aaa, EEEE dd MMM yyy')
                    .format(DateTime.parse(widget.transaction.date)),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontSize: 16),
              ),
              SizedBox(height: 10),
              // splitPossible
              //     ? Align(
              //         alignment: Alignment.centerLeft,
              //         child: ElevatedButton(
              //           onPressed: () {},
              //           child: Text('Split Bill'),
              //         ),
              //       )
              //     : SizedBox(),
              positionAvailable
                  ? Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 160.0,
                              child: MapboxMap(
                                accessToken: AppConstants.mapboxKey,
                                onMapCreated: _onMapCreated,
                                onStyleLoadedCallback: _onStyleLoaded,
                                zoomGesturesEnabled: false,
                                myLocationEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(6, 5),
                                  zoom: 14.0,
                                ),
                              ),
                            ),
                            Text(widget.transaction.address),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              categoryCardShow
                  ? Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    getTranslated(context, 'category'),
                                  ),
                                ),
                                widget.transaction.direction == 'out'
                                    ? SizedBox(
                                        width: 120,
                                        child: FutureBuilder(
                                            future: categoryList,
                                            builder: (context,
                                                AsyncSnapshot<
                                                        List<
                                                            TransactionCategory>>
                                                    snapshot) {
                                              if (snapshot.hasError)
                                                print(snapshot.error);

                                              if (snapshot.hasData) {
                                                return DropdownButton<
                                                    TransactionCategory>(
                                                  isExpanded: true,
                                                  hint: Center(
                                                      child: Text(getTranslated(
                                                          context,
                                                          'select_category'))),
                                                  value: categoryDropdownValue,
                                                  underline: SizedBox(),
                                                  icon: SizedBox(),
                                                  onChanged:
                                                      (TransactionCategory
                                                          newValue) {
                                                    setState(() {
                                                      categoryDropdownValue =
                                                          newValue;
                                                    });
                                                    updateCategory();
                                                  },
                                                  selectedItemBuilder:
                                                      (BuildContext context) {
                                                    return snapshot.data
                                                        .map<Widget>(
                                                            (TransactionCategory
                                                                item) {
                                                      return Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          item.name,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      );
                                                    }).toList();
                                                  },
                                                  items: snapshot.data.map<
                                                          DropdownMenuItem<
                                                              TransactionCategory>>(
                                                      (value) {
                                                    return DropdownMenuItem<
                                                            TransactionCategory>(
                                                        value: value,
                                                        child: Text(
                                                          value.name,
                                                        ));
                                                  }).toList(),
                                                );
                                              } else {
                                                return Center(
                                                    child: SizedBox(
                                                        height: 16,
                                                        width: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        )));
                                              }
                                            }),
                                      )
                                    : Text(
                                        widget.transaction.transactionCategory,
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ],
                            ),
                            SizedBox(height: 10),
                            _imageFile != null
                                ? Container(
                                    constraints: BoxConstraints(maxHeight: 150),
                                    child: kIsWeb
                                        ? Image.network(_imageFile.path)
                                        : Image.file(_imageFile),
                                  )
                                : SizedBox(),
                            widget.transaction.receiptImage.isNotEmpty
                                ? Container(
                                    constraints: BoxConstraints(maxHeight: 150),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: GestureDetector(
                                            onTap: () => showImage(widget
                                                .transaction.receiptImage),
                                            child: Image.network(widget
                                                .transaction.receiptImage),
                                          ),
                                        ),
                                        widget.transaction.direction == 'out'
                                            ? Positioned(
                                                bottom: 4,
                                                right: 0,
                                                child: IconButton(
                                                  icon: Icon(
                                                      Icons.delete_forever),
                                                  // color: Colors.red,
                                                  onPressed: () =>
                                                      removeReceiptHandle(),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ))
                                : SizedBox(),
                            receiptPossible
                                ? ElevatedButton(
                                    onPressed: () => attachReceiptClick(),
                                    child: Text(getTranslated(
                                        context, 'attach_receipt')),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              getTranslated(context, 'notes'),
                            ),
                          ),
                          widget.transaction.narration.isEmpty
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      narrationInput = true;
                                    });
                                  },
                                  child:
                                      Text(getTranslated(context, 'add_notes')),
                                )
                              : IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: notesCopy,
                                )
                        ],
                      ),
                      narrationInput
                          ? Column(
                              children: [
                                TextFormField(
                                  minLines: 3,
                                  maxLines: null,
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    labelText: getTranslated(context, 'notes'),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  child: Text(getTranslated(context, 'save')),
                                  onPressed: () {
                                    updateTransactionNote();
                                  },
                                )
                              ],
                            )
                          : Text(widget.transaction.narration),
                    ],
                  ),
                ),
              ),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
