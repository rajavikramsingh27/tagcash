import 'package:flutter/material.dart';
import 'package:tagcash/models/module.dart';
import 'package:tagcash/screens/module_handler.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class PublicArea extends StatefulWidget {
  final String userName;
  final String perspective;
  final bool centerLayout;
  const PublicArea({
    Key key,
    this.userName,
    this.perspective,
    this.centerLayout = false,
  }) : super(key: key);

  @override
  _PublicAreaState createState() => _PublicAreaState();
}

class _PublicAreaState extends State<PublicArea> {
  Future<List<Module>> favoritesListData;
  @override
  void initState() {
    super.initState();
    favoritesListData = appFavoritesListLoad();
  }

  Future<List<Module>> appFavoritesListLoad() async {
    Map<String, String> apiBodyObj = {};
    if (widget.perspective == 'community') {
      apiBodyObj['user_id'] = widget.userName;
      apiBodyObj['user_type'] = '2';
    } else {
      if (Validator.isNumber(widget.userName, allowSymbols: false)) {
        apiBodyObj['user_id'] = widget.userName;
        apiBodyObj['user_type'] = '1';
      } else {
        apiBodyObj['user_name'] = widget.userName;
      }
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModulesPersonal/Personal', apiBodyObj);

    List responseList = response['result'];

    List<Module> getData = [];
    if (responseList != null) {
      getData = responseList.map<Module>((json) {
        return Module.fromJson(json);
      }).toList();
    }
    return getData;
  }

  onModuleClickHandler(Module moduleData) {
    ModuleHandler.load(context, moduleData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: favoritesListData,
      builder: (BuildContext context, AsyncSnapshot<List<Module>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? widget.centerLayout
                ? Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: List.generate(snapshot.data.length, (index) {
                      return GestureDetector(
                        onTap: () => onModuleClickHandler(snapshot.data[index]),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 100,
                          height: 120,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          snapshot.data[index].icon),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                snapshot.data[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.overline,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 130.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: .9,
                    ),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => onModuleClickHandler(snapshot.data[index]),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          snapshot.data[index].icon),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                snapshot.data[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.overline,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
            : GridView.count(
                shrinkWrap: true,
                primary: false,
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 10.0,
                children: List.generate(10, (index) {
                  return Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              );
      },
    );
  }
}
