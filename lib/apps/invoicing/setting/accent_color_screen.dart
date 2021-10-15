import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../constants.dart';


class AccentColorScreen extends StatefulWidget {
  String color;

  AccentColorScreen({Key key, this.color}): super(key: key);

  @override
  _AccentColorScreenState createState() => _AccentColorScreenState(color);
}

class _AccentColorScreenState extends State<AccentColorScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String color, color_name = '', colorName = '';
  Color pickerColor = Color(0xff443a49);

  _AccentColorScreenState(String color,){
    this.color = color;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      color_name = color;
    });
  }

  addStringToSF() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_colour', color_name);

  }

  Color currentColor = Color(0xff2ecd71);


  void changeColor(Color color) =>
      setState(() =>
          currentColor = color
      );

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Accent Color'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
              ),
              onPressed: () {
                addStringToSF();
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(4),
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          crossAxisCount: 3,
          children: [
            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Custom',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: parseColor(color),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#2ecd71';
                    });
                  },
                ),

                Container(
                  padding: EdgeInsets.all(5),
                  child: color_name == '#2ecd71' ?
                  FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                ),

                GestureDetector(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FaIcon(FontAwesomeIcons.pen, size: 16, color: Colors.white,)
                        ],
                      )
                  ),
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          titlePadding: const EdgeInsets.all(0.0),
                          contentPadding: const EdgeInsets.all(0.0),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: parseColor(color),
                              onColorChanged: changeColor,
                              colorPickerWidth: 300.0,
                              pickerAreaHeightPercent: 0.7,
                              enableAlpha: false,
                              displayThumbColor: true,
                              showLabel: true,
                              paletteType: PaletteType.hsv,

                            ),
                          ),
                          actions: <Widget>[
                            ButtonTheme(
                              height: 40,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              child: RaisedButton(
                                color: kUserBackColor,
                                onPressed: () {
                                  String colorString = currentColor.toString(); // Color(0x12345678)
                                  String valueString = colorString.split('(0xff')[1].split(')')[0]; // kind of hacky..
                                  valueString = '#'+valueString;
                                  color_name = valueString;
                                  print(valueString);

                                  setState(() {
                                    color = color_name;
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Text(
                                  'Select',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        );
                      },
                    );
                  }
                ),


              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Red',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#E51C23'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#E51C23';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#E51C23' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                ),
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Pink',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#FF4081'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#FF4081';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#FF4081' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Purple',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#9C27B0'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#9C27B0';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#9C27B0' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Deep purple',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#673AB7'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#673AB7';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#673AB7' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Indigo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#00416A'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#00416A';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#00416A' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Blue',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#03A9F4'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#03A9F4';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#03A9F4' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Light blue',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#40C4FF'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#40C4FF';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#40C4FF' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Cyan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#00BCD4'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#00BCD4';

                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#00BCD4' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Teal',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#009688'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#009688';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#009688' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Green',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#259B24'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#259B24';

                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#259B24' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Light green',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#8BC34A'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#8BC34A';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#8BC34A' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Lime',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#CDDC39'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#CDDC39';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#CDDC39' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Yellow',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#FFEB3B'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#FFEB3B';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#FFEB3B' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Amber',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#FFC107'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#FFC107';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#FFC107' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Orange',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#FF9800'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#FF9800';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#FF9800' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Deep Orange',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#FF5722'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#FF5722';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#FF5722' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Brown',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#b79186'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#b79186';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#b79186' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Grey',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#d4d5db'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#d4d5db';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#d4d5db' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Blue Grey',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#a2a8d6'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#a2a8d6';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#a2a8d6' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

            Stack(
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Black',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.end,),
                      ],
                    ),
                    color: HexColor('#000000'),
                  ),
                  onTap: (){
                    setState(() {
                      color_name = '#000000';
                    });
                  },
                ),

                Container(
                    padding: EdgeInsets.all(5),
                    child: color_name == '#000000' ?
                    FaIcon(FontAwesomeIcons.solidCheckCircle, size: 20, color: Colors.white,):Container()
                )
              ],
            ),

          ],
        ),
    );
  }



}



