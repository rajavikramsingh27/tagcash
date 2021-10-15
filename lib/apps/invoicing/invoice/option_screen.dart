import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';

import '../../../constants.dart';


class OptionScreen extends StatefulWidget {


  @override
  _OptionScreenState createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {

  bool isLoading = false;
  bool isSendSwitched = false;
  bool isAttachSwitched = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: 'Options',
        ),
        body: Stack(
          children: [
            textModule(),

            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        )
    );
  }
  Widget textModule(){
    return ListView(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      'Send a copy to myself',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    child:Switch(
                      value: isSendSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSendSwitched = value;
                          print(isSendSwitched);
                        });
                      },
                      activeTrackColor:kMerchantBackColor,
                      activeColor: kPrimaryColor,
                    ),
                  )

                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      'Attach the invoice as a PDF',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    child:Switch(
                      value: isAttachSwitched,
                      onChanged: (value) {
                        setState(() {
                          isAttachSwitched = value;
                          print(isAttachSwitched);
                        });
                      },
                      activeTrackColor:kMerchantBackColor,
                      activeColor: kPrimaryColor,
                    ),
                  )

                ],
              ),
              SizedBox(height: 10),

              Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child:
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            width: MediaQuery.of(context).size.width,
                            child: ButtonTheme(
                              height: 40,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: RaisedButton(
                                padding: EdgeInsets.all(8),
                                color: kUserBackColor,
                                onPressed: () {
                                  addStringToSF(isSendSwitched, isAttachSwitched);
                                  Navigator.pop(context, true);
                                },
                                child: Text(
                                  'Save Options',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          )),

                        ],
                      ),
                    ],
                  )
              ),



            ],
          ),
        )
      ],
    );
  }

  addStringToSF(bool option_send, bool option_attach) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('option_send', option_send);
    prefs.setBool('option_attach', option_attach);
  }

}


