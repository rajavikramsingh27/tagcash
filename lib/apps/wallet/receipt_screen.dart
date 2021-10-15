import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

import 'models/receipt.dart';

class ReceiptScreen extends StatefulWidget {
  final Receipt receipt;

  const ReceiptScreen({Key key, this.receipt}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: getTranslated(context, 'expense_receipt'),
      ),
      body: Container(
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          padding: EdgeInsets.all(20),
          children: [
            Text(
              getTranslated(context, 'transaction_completed_successfully'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.check,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.receipt.currencyCode,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(fontWeight: FontWeight.w300),
                ),
                SizedBox(width: 6),
                Text(
                  NumberFormat.currency(name: '')
                      .format(double.parse(widget.receipt.amount)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              getTranslated(context, 'send_to'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10),
            widget.receipt.toId != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: widget.receipt.toType == 'user'
                            ? NetworkImage(
                                AppConstants.getUserImagePath() +
                                    widget.receipt.toId +
                                    "?kycImage=0",
                              )
                            : NetworkImage(
                                AppConstants.getCommunityImagePath() +
                                    widget.receipt.toId),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.receipt.name,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(widget.receipt.toId),
                        ],
                      ),
                    ],
                  )
                : Text(
                    widget.receipt.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
            SizedBox(height: 30),
            widget.receipt.transactionId.isNotEmpty
                ? Text(
                    'TX : ${widget.receipt.transactionId}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                : SizedBox(),
            SizedBox(height: 20),
            Text(
              DateFormat('h:mm aaa dd MMM yyy')
                  .format(DateTime.parse(widget.receipt.date)),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              widget.receipt.narration,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 20),
            widget.receipt.type == 'send_tagcash'
                ? Text(
                    getTranslated(
                        context, 'you_will_receive_email_with_details'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                : SizedBox(),
            widget.receipt.type == 'send_remittance' ||
                    widget.receipt.type == 'send_gofer'
                ? Text(
                    getTranslated(context, 'successfully_submitted_message'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

// if (toTransferType = "community") {
//     urlUserImageScaned.value = _model.communityImageUrl + toTransferId;
// } else {
//     if (_model.activePerspectiveType == "user") {
//         urlUserImageScaned.value = _model.userImageUrl + toTransferId + "?kycImage=0";
//     } else {
//         urlUserImageScaned.value = _model.userImageUrl + toTransferId;
//     }
// }

//  transfer_to_id: 1205,
//   transfer_to_type: community,
//   scratchcard_game_id: 0,
//   win_combination_id: 0}

// if (resultObj.scratchcard_game_id) {
//     if (_model.activePerspectiveType == "user" && resultObj.scratchcard_game_id != 0) {
//         if (resultObj.win_combination_id == 0) {
//             tagEvents.emit("scratchPlayEvent", { game_id: resultObj.scratchcard_game_id });
//         } else {
//             tagEvents.emit("scratchPlayEvent", { game_id: resultObj.scratchcard_game_id, win_comb: resultObj.win_combination_id });
//         }
//     }
// }

// if (resultObj.to_unreg_email) {
//       tagEvents.emit("alertEvent", { type: "info", title: "", message: loc.value.not_registred_send_message });
//   }
