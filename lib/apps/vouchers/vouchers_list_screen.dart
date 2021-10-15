import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/src/services/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/apps/vouchers/models/voucher.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/theme_provider.dart';
import 'package:tagcash/utils/common_methods.dart';
import 'package:tagcash/components/custom_button.dart';
import 'dart:convert';

class VouchersListScreen extends StatefulWidget {
  @override
  _VouchersListScreenState createState() => _VouchersListScreenState();
}

class _VouchersListScreenState extends State<VouchersListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Voucher> _vouchersList = [];

  bool isLoading = true;
  bool loadingProgress = false;
  bool loadMore = false;

  final int limit = 10;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadingProgress = false;
    loadMore = false;

    getVouchersList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  Future getVouchersList([bool refresh = false]) async {
    print('===============getting vouchers List =====================');

    var apiBodyObj = {
      "voucher_status": "progress",
      "count": limit.toString(),
      "offset": refresh ? "0" : _vouchersList.length.toString()
    };

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/list', apiBodyObj);

    if (response["status"] == "success") {
      List responseList = response['result'];
      var pagedVoucherList = responseList.map<Voucher>((json) {
        return Voucher.fromJson(json);
      }).toList();

      setState(() {
        isLoading = false;
        loadingProgress = false;
        loadMore = pagedVoucherList.length == limit;

        if (refresh)
          _vouchersList = pagedVoucherList;
        else
          _vouchersList.addAll(pagedVoucherList);
      });
    } else {
      setState(() {
        loadMore = false;
        loadingProgress = false;
        isLoading = false;
      });
    }
  }

  Future<void> refreshVouchers() {
    setState(() {
      loadMore = false;
    });

    getVouchersList(true);
    return Future.value();
  }

  handleResendEmail(Voucher voucher) async {
    print('===============Resend Email =====================');

    // Close Popup
    Navigator.of(context).pop(true);

    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {"id": voucher.id.toString(), "email": voucher.reciepient};

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/email', apiBodyObj);

    String message;
    if (response["status"] == "success") {
      message = getTranslated(context, "vouchers_email_sent_successfully");

      setState(() {
        isLoading = false;
      });
    } else {
      message = getTranslated(context, "vouchers_error_while_email_sent");

      setState(() {
        isLoading = false;
      });
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(message),
      duration: new Duration(seconds: 3),
    ));
  }

  handleDeleteVoucher(Voucher voucher) async {
    print('=============== Delete Voucher =====================');

    // Close Popup
    Navigator.of(context).pop(true);

    setState(() {
      isLoading = true;
    });

    var apiBodyObj = {"id": voucher.id.toString()};

    Map<String, dynamic> response =
        await NetworkHelper.request('voucher/cancel', apiBodyObj);

    String message;
    if (response["status"] == "success") {
      message = getTranslated(context, "vouchers_deleted_successfully");

      setState(() {
        isLoading = false;
        _vouchersList.removeWhere((v) => v.id == voucher.id);
      });
    } else {
      message = getTranslated(context, "vouchers_error_while_deleting");

      setState(() {
        isLoading = false;
      });
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: new Text(message),
      duration: new Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                var shouldLoadMore = !loadingProgress &&
                    loadMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent;

                if (shouldLoadMore) {
                  setState(() {
                    loadingProgress = true;
                  });

                  getVouchersList();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: refreshVouchers,
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _vouchersList.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _vouchersList.length) {
                      return buildVoucherRow(context, _vouchersList[index]);
                    } else if (loadMore) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Loading()),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox()
          ],
        ));
  }

  buildVoucherRow(BuildContext context, Voucher voucher) {
    String title = voucher.code;
    if (voucher.voucherType != 1) title += " (${voucher.voucherBalance})";

    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return VoucherDetailsDialog(
                    voucher: voucher,
                    onResendEmail: handleResendEmail,
                    onDelete: handleDeleteVoucher);
              });
        },
        child: Card(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  Row(children: [
                    Icon(Icons.article, color: Theme.of(context).primaryColor),
                    SizedBox(width: 10),
                    Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ]),
                  Row(children: [
                    Icon(Icons.account_balance_wallet,
                        color: Theme.of(context).primaryColor),
                    SizedBox(width: 10),
                    Text(
                        "${voucher.walletType} ${CommonMethods.removeTrailingZeros(voucher.amount)}")
                  ]),
                  voucher.voucherType == 1
                      ? Row(children: [
                          Icon(Icons.email,
                              color: Theme.of(context).primaryColor),
                          SizedBox(width: 10),
                          Text(voucher.reciepient)
                        ])
                      : SizedBox()
                ],
              )),
        ));
  }
}

class VoucherDetailsDialog extends StatefulWidget {
  const VoucherDetailsDialog({this.voucher, this.onResendEmail, this.onDelete});

  final Voucher voucher;

  final void Function(Voucher) onResendEmail;
  final void Function(Voucher) onDelete;

  @override
  State createState() => new VoucherDetailsDialogState();
}

class VoucherDetailsDialogState extends State<VoucherDetailsDialog> {
  bool copiedToClipboard = false;

  void initState() {
    super.initState();
    copiedToClipboard = false;
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 15.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: popupElements(),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  popupElements() {
    var voucherQRCode = {"action": "VOUCHER", "code": widget.voucher.code};
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(20),
            height: widget.voucher.voucherType == 1
                ? 450.0
                : 400, // Change as per your requirement
            //width: 300.0, // Change as per your requirement
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: EdgeInsets.only(bottom: 15),
                  width: double.infinity,
                  child: CustomButton(
                      label: getTranslated(
                              context,
                              copiedToClipboard
                                  ? 'copied_to_clipboard'
                                  : 'vouchers_copy_code_clipboard')
                          .toUpperCase(),
                      color: Colors.black,
                      onPressed: () {
                        Clipboard.setData(
                            new ClipboardData(text: widget.voucher.code));
                        setState(() {
                          copiedToClipboard = true;
                        });

                        Future.delayed(Duration(seconds: 5), () {
                          setState(() {
                            copiedToClipboard = false;
                          });
                        });
                      })),
              widget.voucher.voucherType == 1
                  ? Container(
                      padding: EdgeInsets.only(bottom: 15),
                      width: double.infinity,
                      child: CustomButton(
                          label: getTranslated(
                              context, 'vouchers_resend_code_email'),
                          color: Colors.black,
                          onPressed: () {
                            widget.onResendEmail(widget.voucher);
                          }))
                  : SizedBox(),
              Container(
                  padding: EdgeInsets.only(bottom: 15),
                  width: double.infinity,
                  child: CustomButton(
                      label: getTranslated(context, 'vouchers_delete_voucher'),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        widget.onDelete(widget.voucher);
                      })),
              Container(
                alignment: Alignment.center,
                child: QrImage(
                  data: jsonEncode(voucherQRCode),
                  version: QrVersions.auto,
                  size: 220.0,
                  backgroundColor: Colors.white,
                ),
              )
            ]))
      ],
    );
  }
}
