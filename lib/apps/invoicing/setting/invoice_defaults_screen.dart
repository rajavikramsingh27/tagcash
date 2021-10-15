import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';

class InvoiceDefaultsScreen extends StatefulWidget {
  @override
  _InvoicedefaultsScreenState createState() => _InvoicedefaultsScreenState();
}

class _InvoicedefaultsScreenState extends State<InvoiceDefaultsScreen>
    with SingleTickerProviderStateMixin{

  bool isLoading = false;
  String id = '', payment_terms = '', default_title = '', default_subheading = '', default_footer = '',
      notes = '';
  List<String> selectedefault = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDefault();
  }


  void getDefault() async {

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/getDefault');

    if (response['status'] == 'success') {

      var jsonn = response['result'];

      setState(() {
        id = jsonn[0]['id'];
        payment_terms = jsonn[0]['payment_terms'];
        default_title = jsonn[0]['default_title'];
        default_subheading = jsonn[0]['default_subheading'];
        default_footer = jsonn[0]['default_footer'];
        notes = jsonn[0]['notes'];
      });

      setState(() {
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  void setDefault() async {

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['payment_terms'] = payment_terms;
    apiBodyObj['default_title'] = default_title;
    apiBodyObj['default_subheading'] = default_subheading;
    apiBodyObj['default_footer'] = default_footer;
    apiBodyObj['notes'] = notes;
    apiBodyObj['id'] = id;

    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/setDefault', apiBodyObj);

    if (response['status'] == 'success') {

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context,true);

    } else {
      setState(() {
        isLoading = false;
      });

      switch (response['error']) {
        case 'noNetwok':
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: 'network_error_message');
          break;
        default:
          showSimpleDialog(context,
              title: getTranslated(context, 'error'),
              message: response['error']);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice defaults'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
            ),
            onPressed: () {
              setDefault();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Payment terms',
                        style: TextStyle(
                          fontSize: 14,
                          color: kUserBackColor,
                        )),
                    SizedBox(height: 10,),
                    InkWell(
                      child: Container(
                          decoration: new BoxDecoration(
                              color: Color(0xfff2f3f5),
                              border:
                              Border.all(color: Color(0xFFACACAC), width: 0.5),
                              borderRadius: BorderRadius.circular(5.0)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        payment_terms,
                                        style: TextStyle(
                                            color: kUserBackColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                      FaIcon(
                                        FontAwesomeIcons.angleDown,
                                        size: 16,
                                        color: Color(0xFFACACAC),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          )),
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _TermsDialog(
                                selectedText:selectedefault,
                                onTextChanged: (cities) {
                                  selectedefault = cities;
                                  var str_Name = selectedefault.reduce((value, element) => value + element);
                                  setState(() {
                                    payment_terms = str_Name;
                                  });
                                },
                              );
                            });
                      },
                    ),

                    Divider(),

                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default title',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2),
                            Text(
                              default_title == ''?
                               'None' : default_title,
                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _DefaultDialog(
                                title_label: 'Default title',
                                title_name: default_title,
                                selectedText:selectedefault,
                                onTextChanged: (cities) {
                                  selectedefault = cities;
                                  var str_Name = selectedefault.reduce((value, element) => value + element);
                                  setState(() {
                                    default_title = str_Name;
                                  });
                                },
                              );
                            });
                      },
                    ),

                    Divider(),

                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default subheading',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2),
                            Text(
                              default_subheading == ''?
                              'None' : default_subheading,
                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _DefaultDialog(
                                title_label: 'Default subheading',
                                title_name: default_subheading,
                                selectedText:selectedefault,
                                onTextChanged: (cities) {
                                  selectedefault = cities;
                                  var str_Name = selectedefault.reduce((value, element) => value + element);
                                  setState(() {
                                    default_subheading = str_Name;
                                  });
                                },
                              );
                            });
                      },
                    ),

                    Divider(),
                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default footer',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2),
                            Text(
                              default_footer == ''?
                              'None' : default_footer,
                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _DefaultDialog(
                                title_label: 'Default footer',
                                title_name: default_footer,
                                selectedText:selectedefault,
                                onTextChanged: (cities) {
                                  selectedefault = cities;
                                  var str_Name = selectedefault.reduce((value, element) => value + element);
                                  setState(() {
                                    default_footer = str_Name;
                                  });
                                },
                              );
                            });
                      },
                    ),

                    Divider(),
                    InkWell(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: TextStyle(
                                  color: kUserBackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2),
                            Text(
                              notes == ''?
                              'None' : notes,
                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _DefaultDialog(
                                title_label: 'Notes',
                                title_name: notes,
                                selectedText:selectedefault,
                                onTextChanged: (cities) {
                                  selectedefault = cities;
                                  var str_Name = selectedefault.reduce((value, element) => value + element);
                                  setState(() {
                                    notes = str_Name;
                                  });
                                },
                              );
                            });
                      },
                    ),

                    Divider(),
                  ],
                ),
              )
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }

}




class _DefaultDialog extends StatefulWidget {

  _DefaultDialog({
    this.title_label,
    this.title_name,
    this.selectedText,
    this.onTextChanged,
  });

  final String title_label;
  final String title_name;
  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;


  @override
  _DefaultDialogState createState() => _DefaultDialogState();
}

class _DefaultDialogState extends State<_DefaultDialog> {
  TextEditingController _titleController = TextEditingController();
  List<String> _tempSelectedTxt = [];
  String title_label;

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;
    title_label = widget.title_label;
    _titleController.text = widget.title_name;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child:Icon(
                                Icons.close,
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },)
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child:  Text(
                      'Set default',
                      style: TextStyle(
                        fontSize: 18,
                        color: kMerchantBackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),



                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: _titleController,
                style: TextStyle(fontWeight: FontWeight.normal),
                decoration: new InputDecoration(labelText: title_label),
              ),
            ),

            Container(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kUserBackColor,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('CANCEL',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),

                  Flexible(child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      child: RaisedButton(
                        padding: EdgeInsets.all(8),
                        color: kPrimaryColor,
                        onPressed: () {
                          _tempSelectedTxt.clear();
                          var title = _titleController.text;
                          _tempSelectedTxt.add(title);
                          widget.onTextChanged(_tempSelectedTxt);
                          Navigator.of(context).pop();
                        },
                        child: Text('OK',
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),),
                      ),
                    ),
                  ),)

                ],
              ),
            )
          ],
        ),
      ),
    );

  }
}




class _TermsDialog extends StatefulWidget {
  _TermsDialog({
    this.selectedText,
    this.onTextChanged,
  });

  final List<String> selectedText;
  final ValueChanged<List<String>> onTextChanged;


  @override
  _TermsDialogState createState() => _TermsDialogState();
}

class _TermsDialogState extends State<_TermsDialog> {
  List<String> _tempSelectedTxt = [];
  List<String> getData = new List<String>();

  @override
  void initState() {
    super.initState();
    _tempSelectedTxt = widget.selectedText;

    getData.add('On receipt');
    getData.add('Within 15 days');
    getData.add('Within 30 days');
    getData.add('Within 45 days');
    getData.add('Within 60 days');
    getData.add('Within 90 days');
    getData.add('Custom');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              child:Icon(
                                Icons.close,
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },)
                          ],
                        ),
                      )),

                ],
              ),
            ),

            ListView.builder(
                shrinkWrap: true,
                itemCount: getData.length,
                itemBuilder: (BuildContext context, int index) {
                  final cityName = getData[index];
                  return InkWell(child:
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        getData[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: kUserBackColor,
                        )),
                  ),
                      onTap: () async {
                        _tempSelectedTxt.clear();
                        _tempSelectedTxt.add(getData[index]);
                        Navigator.of(context).pop();
                        widget.onTextChanged(_tempSelectedTxt);

                      });
                }),
          ],
        ),
      ),
    );

  }
}