import 'package:flutter/material.dart';
import 'package:tagcash/apps/manage_module/models/tutorial_item.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

class OptionTutorialTemplate extends StatefulWidget {
  final Function(List) onTutorialChanged;

  const OptionTutorialTemplate({
    Key key,
    this.onTutorialChanged,
  }) : super(key: key);

  @override
  _OptionTutorialTemplateState createState() => _OptionTutorialTemplateState();
}

class _OptionTutorialTemplateState extends State<OptionTutorialTemplate> {
  Future<List<TutorialItem>> tutorialListData;
  List<TutorialItem> _selectedValues = [];

  @override
  void initState() {
    super.initState();

    tutorialListData = tutorialListLoad();
  }

  Future<List<TutorialItem>> tutorialListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('HelpTutorial/HelpTutorialSearchMerchant');

    List responseList = response['result'];

    List<TutorialItem> getData = responseList.map<TutorialItem>((json) {
      return TutorialItem.fromJson(json);
    }).toList();

    return getData;
  }

  void _onItemCheckedChange(TutorialItem itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });

    saveSelection();
  }

  void saveSelection() {
    List selectedId = [];
    for (var i = 0; i < _selectedValues.length; i++) {
      selectedId.add(_selectedValues[i].id);
    }
    widget.onTutorialChanged(selectedId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Tutorials',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          FutureBuilder(
            future: tutorialListData,
            builder: (BuildContext context,
                AsyncSnapshot<List<TutorialItem>> snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(snapshot.data[index].name),
                          trailing: Checkbox(
                              value: snapshot.data[index].isSelected,
                              onChanged: (value) {
                                setState(() {
                                  snapshot.data[index].isSelected = value;
                                  _onItemCheckedChange(
                                      snapshot.data[index], value);
                                });
                              }),
                        );
                      },
                    )
                  : Center(child: Loading());
              ;
            },
          ),
        ],
      ),
    );
  }
}
