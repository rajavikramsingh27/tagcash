import 'package:flutter/material.dart';

class MerchantCoverCard extends StatefulWidget {
  final String coverPhoto;
  final String communityName;
  final String id;
  const MerchantCoverCard({
    Key key,
    this.coverPhoto,
    this.communityName,
    this.id,
  }) : super(key: key);

  @override
  _MerchantCoverCardState createState() => _MerchantCoverCardState();
}

class _MerchantCoverCardState extends State<MerchantCoverCard> {
  bool showNameArea = false;

  @override
  void initState() {
    if (widget.coverPhoto == '') {
      showNameArea = true;
    }

    super.initState();
  }

  void _incrementEnter(PointerEvent details) {
    setState(() {
      showNameArea = true;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      showNameArea = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _incrementEnter,
      onExit: _incrementExit,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey,
          image: widget.coverPhoto != ''
              ? DecorationImage(
                  image: NetworkImage(
                    widget.coverPhoto,
                  ),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: showNameArea
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.communityName,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        Text(
                          widget.id,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
  }
}
