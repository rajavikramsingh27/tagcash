import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/models/member_detail.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/apps/manage_module/models/module_details.dart';
import 'package:tagcash/apps/manage_module/models/my_module.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/screens/dynamic_module_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class ProjectRepository extends StatefulWidget {
  final ProjectList project;
  final bool ownProject;
  const ProjectRepository({
    Key key,
    this.project,
    this.ownProject,
  }) : super(key: key);

  @override
  _ProjectRepositoryState createState() => _ProjectRepositoryState();
}

class _ProjectRepositoryState extends State<ProjectRepository> {
  bool isLoading = false;
  bool linkedStatus = false;
  Future<ModuleDetails> moduleDetails;

  bool editableUser = false;

  @override
  void initState() {
    super.initState();

    if (widget.project.miniApps.length != 0) {
      linkedStatus = true;
      if (widget.ownProject) {
        editableUser = true;
        moduleDetails = getModuleDetails(widget.project.miniApps[0].toString());
      } else {
        memberListData();
      }
    }
  }

  void memberListData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['project_id'] = widget.project.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/ListProjectMembers', apiBodyObj);
    List responseList = response['result'];

    List<MemberDetail> getData = responseList.map<MemberDetail>((json) {
      return MemberDetail.fromJson(json);
    }).toList();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      String activeId = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();

      getData.forEach((MemberDetail member) {
        if (member.userDetail.id == activeId) {
          editableUser = true;
        }
      });
    }
    moduleDetails = getModuleDetails(widget.project.miniApps[0].toString());
    setState(() {});
  }

  Future<ModuleDetails> getModuleDetails(String moduleId) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = moduleId;

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/ModuleById', apiBodyObj);

    // if (response['status'] == 'success') {
    Map responseMap = response['list'];

    return ModuleDetails.fromJson(responseMap);
    // }
  }

  void gitUrlCopy(String url) {
    Clipboard.setData(new ClipboardData(text: url));
    Fluttertoast.showToast(msg: getTranslated(context, 'copied_clipboard'));
  }

  openMiniProgram(ModuleDetails moduleData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicModuleScreen(
          title: moduleData.moduleName,
          url: AppConstants.getServer() == 'live'
              ? moduleData.liveModuleUrl
              : moduleData.betaModuleUrl,
          type: moduleData.moduleType,
        ),
      ),
    );
  }

  linkMiniProgram() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SelectMiniProjram(
                  onModuleSelected: (value) => linkMiniApp(value),
                ),
              ),
            ),
          );
        });
  }

  linkMiniApp(MyModule myModule) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.project.id;
    apiBodyObj['mini_apps'] = '[${myModule.id}]';

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/LinkMiniApp', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      linkedStatus = true;
      moduleDetails = getModuleDetails(myModule.id.toString());
    } else {
      Fluttertoast.showToast(msg: 'An error occurred. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            linkedStatus
                ? Text(
                    'This URL is your code repository, and the emails of the team members have access to push to either master of demo branches')
                : Center(
                    child: Text('No Mini Program is linked to this project.')),
            linkedStatus
                ? FutureBuilder(
                    future: moduleDetails,
                    builder: (BuildContext context,
                        AsyncSnapshot<ModuleDetails> snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      ModuleDetails moduleData = snapshot.data;

                      return snapshot.hasData
                          ? ListView(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(10),
                              children: [
                                ListTile(
                                  title: Text(moduleData.moduleName),
                                  subtitle: Text(moduleData.moduleType),
                                  trailing: FaIcon(
                                    FontAwesomeIcons.externalLinkAlt,
                                    size: 24,
                                  ),
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      image: moduleData.icon != ''
                                          ? DecorationImage(
                                              image:
                                                  NetworkImage(moduleData.icon),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 0),
                                  onTap: () => openMiniProgram(moduleData),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  moduleData.shortDescription,
                                ),
                                if ((moduleData.moduleType == 'flutter' ||
                                        moduleData.moduleType == 'html') &&
                                    editableUser)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Git Repository',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          trailing: IconButton(
                                            icon: Icon(Icons.copy),
                                            onPressed: () =>
                                                gitUrlCopy(moduleData.gitUrl),
                                          ),
                                          title: Text(moduleData.gitUrl),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  SizedBox(),
                              ],
                            )
                          : Center(child: Loading());
                    },
                  )
                : widget.ownProject
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          child: Text('Select a Mini Program'),
                          onPressed: () => linkMiniProgram(),
                        ),
                      )
                    : SizedBox(),
          ],
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );

    // ,
  }
}

class SelectMiniProjram extends StatefulWidget {
  final Function(MyModule) onModuleSelected;

  const SelectMiniProjram({
    Key key,
    this.onModuleSelected,
  }) : super(key: key);

  @override
  _SelectMiniProjramState createState() => _SelectMiniProjramState();
}

class _SelectMiniProjramState extends State<SelectMiniProjram> {
  Future<List<MyModule>> myModuleList;

  @override
  void initState() {
    super.initState();

    myModuleList = myModulesListLoad();
  }

  Future<List<MyModule>> myModulesListLoad() async {
    Map<String, String> apiBodyObj = {};

    String apiUrl;
    if (AppConstants.getServer() == 'beta') {
      apiUrl = 'DynamicModules/ModuleByDeveloper';
    } else {
      apiUrl = 'DynamicModules/ModuleByOwner';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    List<MyModule> getData = List<MyModule>();
    List responseList = response['list'];

    if (responseList != null) {
      getData = responseList.map<MyModule>((json) {
        return MyModule.fromJson(json);
      }).toList();
    }

    return getData;
  }

  moduleClicked(MyModule moduleData) async {
    widget.onModuleSelected(moduleData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myModuleList,
      builder: (BuildContext context, AsyncSnapshot<List<MyModule>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  MyModule moduleData = snapshot.data[index];
                  return moduleData.moduleType == 'flutter'
                      ? ListTile(
                          title: Text(moduleData.moduleName),
                          subtitle: Text(moduleData.moduleType),
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: snapshot.data[index].icon != ''
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          snapshot.data[index].icon),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onTap: () => moduleClicked(moduleData),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        )
                      : SizedBox();
                },
              )
            : Center(child: Loading());
      },
    );
  }
}
