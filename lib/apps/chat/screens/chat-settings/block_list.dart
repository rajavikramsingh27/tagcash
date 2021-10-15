import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';

import '../../../../constants.dart';
import '../../../../models/app_constants.dart' as AppConstants;

class BlockList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Block List',
      ),
      body: SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            indent: 70,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: CircleAvatar(
                radius: 24.0,
                backgroundImage: NetworkImage(
                  AppConstants.getUserImagePath(),
                ),
              ),
              title: Text('Puneet Sethi'),
              subtitle: Text('Available'),
              trailing: RaisedButton(
                child: Text(
                  'Unblock',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                ),
                color: kPrimaryColor,
                onPressed: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}
