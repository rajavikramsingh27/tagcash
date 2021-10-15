import 'package:emoji_chooser/emoji_chooser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddEmoji extends StatefulWidget {
  Function emojiSelected;
  AddEmoji(this.emojiSelected);

  @override
  _AddEmojiState createState() => _AddEmojiState();
}

class _AddEmojiState extends State<AddEmoji> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: EmojiChooser(
        columns: kIsWeb ? 30 : 11,
        rows: 7,
        onSelected: (emoji) {
          widget.emojiSelected(emoji);
        },
      ),
    );
  }
}
