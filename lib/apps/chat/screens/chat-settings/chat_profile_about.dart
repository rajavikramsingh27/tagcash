import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/perspective_provider.dart';
import '../../../../constants.dart';

class ChatProfileAbout extends StatefulWidget {
  @override
  _ChatProfileAboutState createState() => _ChatProfileAboutState();
}

class _ChatProfileAboutState extends State<ChatProfileAbout> {
  List<dynamic> profileStatus = [
    {"label": 'Avalable'},
    {"label": 'Busy'},
    {"label": 'At the movies'},
    {"label": 'At work'},
    {"label": 'Battery about to die'},
    {"label": 'In a meeting'},
    {"label": 'At the gym'},
    {"label": 'Sleeping'},
    {"label": 'Urgent calls only'},
  ];

  List<String> selectedStatus = [
    'false',
    'false',
    'true',
    'false',
    'false',
    'false',
    'false',
    'false',
    'false',
  ];
  @override
  initState() {
    super.initState();
  }

  GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();

  bool enableAutoValidate = false;

  final _aboutTextController = TextEditingController(text: "Available");

  @override
  Widget build(BuildContext context) {
    void _editStatus() {
      showModalBottomSheet(
        context: context,
        shape: kBottomSheetShape,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _searchFormKey,
                autovalidateMode: enableAutoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 30, bottom: 10, left: 30, right: 30),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add about',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextField(
                            textInputAction: TextInputAction.search,
                            controller: _aboutTextController,
                            onSubmitted: (value) {
                              // submitSearchAdd(value, context);
                            },
                            decoration: InputDecoration(
                              hintText: 'About',
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text('CANCEL'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'SAVE',
                                  style: TextStyle(color: Colors.green),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          // SizedBox(

                          //   child: RaisedButton(
                          //     child: Text('Cancel'),
                          //     padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          //     color: kPrimaryColor,
                          //     textColor: Colors.white,
                          //     shape: new RoundedRectangleBorder(
                          //       borderRadius: new BorderRadius.circular(10.0),
                          //     ),
                          //     onPressed: () {
                          //       submitSearch(_textController.text, context);
                          //       {
                          //         setState(() {
                          //           print("reached here");
                          //           enableAutoValidate = true;
                          //         });
                          //         if (_searchFormKey.currentState.validate()) {
                          //           print("reached here--save");
                          //           FocusScope.of(context)
                          //               .requestFocus(FocusNode());
                          //           // addContactProcess();
                          //         }
                          //       }
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                    'user'
                ? Colors.black
                : Colors.blue,
        title: Text('About'),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Currently set to',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              onTap: () {
                _editStatus();
              },
              title: Text(
                'Available',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              // subtitle: Text('Available'),
              trailing: Icon(Icons.edit),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Text(
                'Select About',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: profileStatus.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      onTap: () {
                        // this.profileStatus[index]['label'] = 'sdf';
                        // =this.
                        // this
                        //     .selectedStatus
                        //     .insert(index, selectedStatus[index]);
                        var ind = selectedStatus
                            .indexWhere((status) => status.startsWith('t'));

                        setState(() {
                          selectedStatus[ind] = 'false';
                          this.selectedStatus[index] = 'true';
                        });
                      },
                      title: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text('${profileStatus[index]['label']}',
                            style: TextStyle(fontWeight: FontWeight.normal)),

                        //       Text(
                        //         '${}'
                        //         // style: TextStyle(fontWeight: FontWeight.normal),
                        // ),
                      ),
                      trailing: selectedStatus[index] == 'true'
                          ? Icon(Icons.check)
                          : SizedBox());
                },
              ),
            ),
          ],
        ),
      ),
      // Container(
      //   child: Column(
      //     children: [
      //       ListTile(
      //         title: Text('Current set to'),
      //         subtitle: Text('name'),
      //         trailing: Icon(Icons.edit),
      //       ),
      //       Divider(),
      //       Column(
      //         children: [
      //           Text('sdf'),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  void submitSearch(text, BuildContext context) {}
}
