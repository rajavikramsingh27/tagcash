import 'package:flutter/material.dart';

class PinVerify extends StatefulWidget {
  final Function(String) onPinEntered;

  const PinVerify({
    Key key,
    this.onPinEntered,
  }) : super(key: key);

  @override
  _PinVerifyState createState() => _PinVerifyState();
}

class _PinVerifyState extends State<PinVerify> {
  int passLength = 4;
  int _currentCodeLength = 0;
  List _inputCodes = <String>[];

  _onCodeClick(String code) {
    if (code == 'clear') {
      setState(() {
        _currentCodeLength = 0;
        _inputCodes = <String>[];
      });
    } else if (code == 'back') {
      if (_currentCodeLength > 0) {
        setState(() {
          _currentCodeLength--;
          _inputCodes.removeAt(_currentCodeLength);
        });
      }
    } else {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });
      if (_currentCodeLength == passLength) {
        widget.onPinEntered(_inputCodes.join(''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 30, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ENTER PIN',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildIndication(1),
                  buildIndication(2),
                  buildIndication(3),
                  buildIndication(4),
                ],
              ),
            ),
            Center(
              child: Container(
                width: 300,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 10,
                  padding: EdgeInsets.all(8),
                  children: [
                    buildNumberKey('1'),
                    buildNumberKey('2'),
                    buildNumberKey('3'),
                    buildNumberKey('4'),
                    buildNumberKey('5'),
                    buildNumberKey('6'),
                    buildNumberKey('7'),
                    buildNumberKey('8'),
                    buildNumberKey('9'),
                    buildNumberKey('clear'),
                    buildNumberKey('0'),
                    buildNumberKey('back'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildIndication(int value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          color: _currentCodeLength >= value ? Colors.red : null,
          shape: BoxShape.circle,
          border: _currentCodeLength >= value
              ? null
              : Border.all(
                  color: Colors.grey,
                )),
    );
  }

  InkResponse buildNumberKey(String number) {
    return InkResponse(
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        height: 50,
        width: 50,
        child: Center(
          child: buttonItem(number),
        ),
      ),
    );
  }

  Widget buttonItem(String number) {
    if (number == 'back') {
      return Icon(Icons.backspace_outlined);
    } else if (number == 'clear') {
      return Icon(Icons.close_outlined);
    } else {
      return Text(
        number.toString(),
        style: TextStyle(fontSize: 24),
      );
    }
  }
}
