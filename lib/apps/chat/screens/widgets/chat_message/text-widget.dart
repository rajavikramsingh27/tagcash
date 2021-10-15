import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final String text;
  final String date;
  final String alignMsg;
  TextWidget(this.bgColor, this.textColor, this.text, this.date, this.alignMsg);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 55, left: 10),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Text(
         text,
         textAlign: TextAlign.left,
         style: TextStyle(color: textColor),
          ),
          Positioned(
            
            child: Text(
              date,
              style: TextStyle(
                fontSize: 10,
                color: alignMsg == 'right' ? Colors.white54 : Colors.grey),
            ),
            right: -50,
            bottom: -3,
          ),
        ],
      ),
    );
  }
}
