import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagcash/apps/invoicing/setting/template_screen.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

import 'accent_color_screen.dart';
import 'company_logo_screen.dart';


class StyleTabScreen extends StatefulWidget {
  @override
  _StyleTabScreenState createState() => _StyleTabScreenState();
}

class _StyleTabScreenState extends State<StyleTabScreen> {
  bool isLoading = false;

  String color = '', template = '', logo_url = '', path = '', temp_index = '', temp_layout = '', temp_name = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConfig();

  }

  void getConfig() async {
    setState(() {
      isLoading = true;
    });


    Map<String, dynamic> response =
    await NetworkHelper.request('invoicing/getConfig');

    if (response['status'] == 'success') {

      var jsonn = response['result'];

      setState(() {
          color = jsonn[0]['colour'];
          logo_url = jsonn[0]['logo_url'];

          List responseList = jsonn[0]['tamplate'];


          if(responseList.length != 0){
            template = jsonn[0]['tamplate'][0]['label'];
            path = jsonn[0]['tamplate'][0]['path'];
            temp_index = jsonn[0]['tamplate'][0]['index'].toString();
            temp_layout = jsonn[0]['tamplate'][0]['layout'];
            temp_name = jsonn[0]['tamplate'][0]['name'];
          }

          addStringToSF(jsonn[0]['id'], jsonn[0]['colour'], jsonn[0]['logo_url'], temp_index, path,
              temp_layout, temp_name, template, jsonn[0]['company'],
              jsonn[0]['address'][0]['address1'], jsonn[0]['address'][0]['address2'], jsonn[0]['address'][0]['city'], jsonn[0]['address'][0]['zipCode'],
              jsonn[0]['address'][0]['country']['addressCountry'], jsonn[0]['address'][0]['country']['addressCountryId'].toString(),
              jsonn[0]['address'][0]['state']['addressState'], jsonn[0]['address'][0]['state']['addressStateId'], jsonn[0]['contact'][0]['main'],
              jsonn[0]['contact'][0]['mobile'], jsonn[0]['contact'][0]['website'], jsonn[0]['columns_titles'][0]['Items'],
              jsonn[0]['columns_titles'][0]['Units'],jsonn[0]['columns_titles'][0]['Price'],jsonn[0]['columns_titles'][0]['Amount'], jsonn[0]['name_desc'],
              jsonn[0]['unit_price']['hideAmount'],jsonn[0]['unit_price']['hidePrice'], jsonn[0]['unit_price']['hideUnits']);
        }

        );

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


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            image: path != ''?DecorationImage(
                              image: NetworkImage(path),
                              fit: BoxFit.fill,
                            ) : null
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Template',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )),
                              Text(
                                  template,
                                  style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (context) => TemplateScreen())
                    ).then((val)=>val?getColorData():null);
                  },
                ),

                Divider(),

                GestureDetector(
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.brown,
                            image: logo_url != ''?DecorationImage(
                              image: NetworkImage(logo_url),
                              fit: BoxFit.fill,
                            ) : null
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Company logo',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )),
                              Text(
                                  'Select an image less than 2MB in size',
                                  style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (context) => CompanyLogoScreen(company_logo: logo_url))
                    ).then((val)=>val?getConfig():null);
                  },
                ),


                Divider(),

                GestureDetector(
                  child:  Container(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: color != ''?
                              parseColor(color): parseColor('#000000')
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Accent Color',
                                  style: TextStyle(
                                    fontSize: 14,
                                  )),
                              Text(
                                  color,
                                  style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                        new MaterialPageRoute(builder: (context) => AccentColorScreen(color: color,))
                    ).then((val)=>val?getColorData():null);
                  },
                )
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }

  getColorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String

    setState(() {
      color = prefs.getString('config_colour');
      template = prefs.getString('config_tmp_label');
    });
  }

  addStringToSF(String config_id, String config_colour, String config_logo_url, String config_tmp_index, String config_tmp_path, String config_tmp_layout,
      String config_tmp_name, String config_tmp_label, String config_company, String config_add_address1, String config_add_address2,
      String config_add_city, String config_add_zipCode, String config_add_country_addressCountry, String config_add_country_addressCountryId,
      String config_add_state_addressState, String config_add_state_addressStateId, String config_contact_main, String config_contact_mobile,
      String config_contact_website, String config_col_Items, String config_col_Units, String config_col_Price, String config_col_Amount,
      String config_name_desc, bool config_unit_hideAmount, bool config_unit_hidePrice, bool config_unit_hideUnits) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config_id', config_id);
    prefs.setString('config_colour', config_colour);
    prefs.setString('config_logo_url', config_logo_url);

    prefs.setString('config_tmp_index', config_tmp_index);
    prefs.setString('config_tmp_path', config_tmp_path);
    prefs.setString('config_tmp_layout', config_tmp_layout);
    prefs.setString('config_tmp_name', config_tmp_name);
    prefs.setString('config_tmp_label', config_tmp_label);

    prefs.setString('config_company', config_company);

    prefs.setString('config_add_address1', config_add_address1);
    prefs.setString('config_add_address2', config_add_address2);
    prefs.setString('config_add_city', config_add_city);
    prefs.setString('config_add_zipCode', config_add_zipCode);
    prefs.setString('config_add_country_addressCountry', config_add_country_addressCountry);
    prefs.setString('config_add_country_addressCountryId', config_add_country_addressCountryId);
    prefs.setString('config_add_state_addressState', config_add_state_addressState);
    prefs.setString('config_add_state_addressStateId', config_add_state_addressStateId);

    prefs.setString('config_contact_main', config_contact_main);
    prefs.setString('config_contact_mobile', config_contact_mobile);
    prefs.setString('config_contact_website', config_contact_website);

    prefs.setString('config_col_Items', config_col_Items);
    prefs.setString('config_col_Units', config_col_Units);
    prefs.setString('config_col_Price', config_col_Price);
    prefs.setString('config_col_Amount', config_col_Amount);

    prefs.setString('config_name_desc', config_name_desc);

    prefs.setBool('config_unit_hideAmount', config_unit_hideAmount);
    prefs.setBool('config_unit_hidePrice', config_unit_hidePrice);
    prefs.setBool('config_unit_hideUnits', config_unit_hideUnits);
  }
}
