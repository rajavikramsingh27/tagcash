import 'package:flutter/material.dart';
import 'package:tagcash/apps/manage_module/models/module_category.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';

class AppCategoryMenu extends StatefulWidget {
  final Function(int) onCategoryChange;
  const AppCategoryMenu({
    Key key,
    this.onCategoryChange,
  }) : super(key: key);

  @override
  _AppCategoryMenuState createState() => _AppCategoryMenuState();
}

class _AppCategoryMenuState extends State<AppCategoryMenu> {
  Future<List<ModuleCategory>> categoryList;
  ModuleCategory categoryDropdownValue;

  int categorySelectedValue = 0;

  @override
  void initState() {
    super.initState();
    categoryList = categoryListLoad();
  }

  Future<List<ModuleCategory>> categoryListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/CategoryList');

    List responseList = response['list'];

    List<ModuleCategory> getData = responseList.map<ModuleCategory>((json) {
      return ModuleCategory.fromJson(json);
    }).toList();

    getData.insert(0, ModuleCategory(id: 0, name: 'All', icon: ''));
    setState(() {
      categoryDropdownValue = getData[0];
    });
    return getData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: categoryList,
        builder: (context, AsyncSnapshot<List<ModuleCategory>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          if (snapshot.hasData) {
            return DropdownButtonFormField<ModuleCategory>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                labelText: getTranslated(context, 'category'),
                border: const OutlineInputBorder(),
              ),
              value: categoryDropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              onChanged: (ModuleCategory newValue) {
                widget.onCategoryChange(newValue.id);

                setState(() {
                  categoryDropdownValue = newValue;
                });
              },
              items:
                  snapshot.data.map<DropdownMenuItem<ModuleCategory>>((value) {
                return DropdownMenuItem<ModuleCategory>(
                  value: value,
                  child: Row(
                    children: [
                      value.id != 0
                          ? Image.network(
                              value.icon,
                              width: 30,
                              height: 30,
                            )
                          : SizedBox(),
                      SizedBox(width: 10),
                      Text(value.name)
                    ],
                  ),
                );
              }).toList(),
            );
          } else {
            return Center(child: Loading());
          }
        });
  }
}
