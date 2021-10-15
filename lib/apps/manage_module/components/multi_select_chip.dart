import 'package:flutter/material.dart';
import 'package:tagcash/apps/manage_module/models/module_category.dart';

class MultiSelectChip extends StatefulWidget {
  final List<ModuleCategory> reportList;
  final Function(List<int>) onSelectionChanged; // +added
  MultiSelectChip(this.reportList, {this.onSelectionChanged} // +added
      );
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  List<int> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          label: Text(item.name),
          selected: selectedChoices.contains(item.id),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item.id)
                  ? selectedChoices.remove(item.id)
                  : selectedChoices.add(item.id);
              widget.onSelectionChanged(selectedChoices); // +added
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
