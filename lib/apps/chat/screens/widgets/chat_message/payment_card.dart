import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final String msg;
  final String title;
  final String docId;
  final String date;
  PaymentCard(this.msg, this.title, this.docId, this.date);

  paycard() {
    return Stack(
      children: [
        Card(
          child: Container(
            padding: EdgeInsets.only(bottom: 20, right: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text("PAYMENT TRANSFERRED"),
                  subtitle: Text(
                    "TRANSFERRED $msg TO $title",
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        color: Colors.green),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[Text("TXN ID: $docId")],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          child: Text(
            this.date,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          right: 10,
          bottom: 7,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? 500 : 320,
      ),
      padding: EdgeInsets.all(1),
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border:
            Border.all(width: 3, color: Colors.red, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 2,
          )
        ],
      ),
      child: this.paycard(),
    );
  }
}
