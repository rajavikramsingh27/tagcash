import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/booking/models/service.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';

import '../../../constants.dart';
import 'make_appointment_screen.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;


class UserServiceDetailScreen extends StatefulWidget {
 String owner_id, name, service, staff;
 UserServiceDetailScreen(
      {Key key, this.owner_id, this.name, this.service, this.staff,}) : super(key: key);

  @override
  _UserServiceDetailScreenState createState() => _UserServiceDetailScreenState();
}

class _UserServiceDetailScreenState extends State<UserServiceDetailScreen> with SingleTickerProviderStateMixin  {

  bool isLoading = false;

  List<Service> getData = new List<Service>();

  String availability_mo = '', availability_tu = '', availability_we = '', availability_th = '', availability_fr = '', availability_sa = '', availability_su = '';
  List responseListAvailability;

  @override
  void initState() {
    super.initState();
    getMerchantService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void getMerchantService() async  {
    print('loadStaffCommunities');

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['owner_id'] = widget.owner_id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'BookingService/GetMerchantService', apiBodyObj);


    var jsonn = response['result'];

    responseListAvailability  = jsonn['availability'];
    List responseList = jsonn['result'];

    getData = responseList.map<Service>((json) {
      return Service.fromJson(json);
    }).toList();


    if (response['status'] == 'success') {

      setState(() {

        if(responseListAvailability.length != 0){
          if(jsonn['availability'][0]['is_closed'] != false){
            availability_mo = 'Mon '+ jsonn['availability'][0]['start_time'] + '-'+ jsonn['availability'][0]['end_time'];
          }else{
            availability_mo = 'Mon Closed';
          }

          if(jsonn['availability'][1]['is_closed'] != false){
            availability_tu = 'Tue '+ jsonn['availability'][1]['start_time'] + '-'+ jsonn['availability'][1]['end_time'];
          }else{
            availability_tu = 'Tue Closed';
          }

          if(jsonn['availability'][2]['is_closed'] != false){
            availability_th = 'Thu '+ jsonn['availability'][2]['start_time'] + '-'+ jsonn['availability'][2]['end_time'];
          }else{
            availability_th = 'Thu Closed';
          }

          if(jsonn['availability'][3]['is_closed'] != false){
            availability_we = 'Wed '+ jsonn['availability'][3]['start_time'] + '-'+ jsonn['availability'][3]['end_time'];
          }else{
            availability_we = 'Wed Closed';
          }

          if(jsonn['availability'][4]['is_closed'] != false){
            availability_fr = 'Fri '+ jsonn['availability'][4]['start_time'] + '-'+ jsonn['availability'][4]['end_time'];
          }else{
            availability_fr = 'Fri Closed';
          }

          if(jsonn['availability'][5]['is_closed'] != false){
            availability_sa = 'Sat '+ jsonn['availability'][5]['start_time'] + '-'+ jsonn['availability'][5]['end_time'];
          }else{
            availability_sa = 'Sat Closed';
          }

          if(jsonn['availability'][6]['is_closed'] != false){
            availability_su = 'Sun '+ jsonn['availability'][6]['start_time'] + '-'+ jsonn['availability'][6]['end_time'];
          }else{
            availability_su = 'Sun Closed';
          }
        }

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
        appBar: AppTopBar(
          appBar: AppBar(),
          title: '',
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                          color: Color(0xFFACACAC),
                        ),
                        borderRadius: BorderRadius.circular(5.0)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                          ),
                          child: Image(
                            image: NetworkImage(
                              AppConstants.getUserImagePath() +
                                  widget.owner_id +
                                  "?kycImage=0",
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        Flexible(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: Theme.of(context).textTheme.subtitle2.apply(),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),

                            Text(
                              availability_mo != ''?
                              widget.service + ' Services, '+ widget.staff + ' Staff, '+ availability_mo + ', '+ availability_tu + ', '+  availability_we + ', '+ availability_th + ', '+ availability_fr + ', '+ availability_sa + ', '+ availability_su :
                              widget.service + ' Services, '+ widget.staff + ' Staff',
                              style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                            ),
                          ],
                        ),)

                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: getData.length,
                        itemBuilder: (BuildContext context, int index){
                         return  InkWell(
                           child: Container(
                               width: MediaQuery.of(context).size.width,
                               margin: EdgeInsets.only(bottom: 10),
                               padding: EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                   border: Border.all(
                                     width: 0.5,
                                     color: Color(0xFFACACAC),
                                   ),
                                   borderRadius: BorderRadius.circular(5.0)
                               ),
                               child: Row(
                                 children: [
                                   Flexible(
                                       flex: 1,
                                       child: Container(
                                         width: MediaQuery.of(context).size.width,
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             Text(
                                               getData[index].name,
                                               style: TextStyle(
                                                   fontSize: 18,
                                                   fontWeight: FontWeight.bold),
                                             ),
                                             SizedBox(height: 10),
                                             Container(
                                               child: Row(
                                                 children: [
                                                   Icon(Icons.access_time, size: 14, color: Color(0xFF535353).withOpacity(0.8),),
                                                   SizedBox(width:2),
                                                   Text(
                                                     getData[index].time + ' mins',
                                                       style: Theme.of(context).textTheme.bodyText2.apply(color: Color(0xFFACACAC)),
                                                   ),
                                                 ],
                                               ),
                                             ),

                                           ],
                                         ),
                                       )
                                   ),

                                   Flexible(
                                       flex: 1,
                                       child: Container(
                                         width: MediaQuery.of(context).size.width,
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.end,
                                           children: [
                                             Text(
                                               getData[index].amount,
                                               style: TextStyle(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.normal),
                                             ),
                                             SizedBox(height: 2),
                                           ],
                                         ),
                                       )
                                   )
                                 ],
                               )
                           ),
                           onTap: (){
                             Navigator.of(context).push(
                                 new MaterialPageRoute(builder: (context) => MakeAppointmentScreen(owner_id: widget.owner_id, owner_service_id: getData[index].id, service_name: getData[index].name, name: widget.name, service: widget.service, staff: widget.staff, getData: getData[index].staff,)));
                           },
                         );
                        }
                    ),
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}

