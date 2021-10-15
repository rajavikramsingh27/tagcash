import 'package:flutter/material.dart';
import 'package:tagcash/components/app_logo.dart';

class PinLogin extends StatefulWidget {
  final Function(String) onPinEntered;
  final String userEmail;

  const PinLogin({
    Key key,
    this.onPinEntered,
    this.userEmail,
  }) : super(key: key);

  @override
  _PinLoginState createState() => _PinLoginState();
}

class _PinLoginState extends State<PinLogin> {
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
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  AppLogo(),
                  SizedBox(height: 6),
                  Text(
                    'ENTER PIN',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(
                    widget.userEmail,
                    // style: Theme.of(context).textTheme.subtitle2,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildIndication(1),
                      buildIndication(2),
                      buildIndication(3),
                      buildIndication(4),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            Container(
              width: 300,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
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
