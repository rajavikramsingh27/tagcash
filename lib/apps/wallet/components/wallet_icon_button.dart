import 'package:flutter/material.dart';
import 'package:tagcash/constants.dart';

class WalletIconButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onMenuClick;

  const WalletIconButton({
    Key key,
    @required this.icon,
    @required this.title,
    this.onMenuClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Icon(
            icon,
            color: kPrimaryColor,
            size: 36,
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        onMenuClick();
      },
      behavior: HitTestBehavior.opaque,
    );
  }
}
