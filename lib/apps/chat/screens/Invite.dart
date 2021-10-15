import 'package:flutter/material.dart';

import './InviteAdd.dart';

class Invite extends StatefulWidget {
  Invite();

  @override
  _InviteState createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  _InviteState();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        height: screenSize.height / 2.6,
        child: Center(
          child: Text(
            'Not found in Tagcash',
            style: new TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ));
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
          child: Column(
              // alignment: Alignment.center,
              children: <Widget>[
            _buildCoverImage(screenSize),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    // color: Colors.red,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    // mainAxisAlignment: MainAxisAlignment.center,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: Colors.red,
                      minWidth: double.infinity,
                      height: 45.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InviteAdd()),
                        ).then((value) {
                          if (value != null) {
                            final snackBar = SnackBar(
                              content: Text(value),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        });
                      },
                      child: Text(
                        'INVITE TO JOIN TAGCASH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: Container(
                    // color: Colors.red,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    // mainAxisAlignment: MainAxisAlignment.center,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      // elevation: 18.0,
                      color: Colors.red,
                      minWidth: double.infinity,
                      height: 45.0,
                      onPressed: () {},
                      child: Text(
                        'SEND REQUEST TO PAY ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                  child: Container(
                    // color: Colors.red,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    // mainAxisAlignment: MainAxisAlignment.center,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: Colors.red,
                      minWidth: double.infinity,
                      height: 45.0,
                      onPressed: () {},
                      child: Text(
                        'PAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ])),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('------disposed-------');
  }
}
