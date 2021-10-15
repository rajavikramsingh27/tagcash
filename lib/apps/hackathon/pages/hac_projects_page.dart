import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/create_project_screen.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/apps/hackathon/models/team_role.dart';
import 'package:tagcash/apps/hackathon/project_data_screen.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/merchant_provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';

class HacProjectsPage extends StatefulWidget {
  final String hackathonId;
  final bool ownerStatus;

  const HacProjectsPage({Key key, this.hackathonId, this.ownerStatus})
      : super(key: key);

  @override
  _HacProjectsPageState createState() => _HacProjectsPageState();
}

class _HacProjectsPageState extends State<HacProjectsPage> {
  bool isLoading = false;
  String searchKey = '';

  StreamController<List<ProjectList>> _streamcontroller;
  List<ProjectList> _projects;
  StreamController<List<ProjectList>> _streamcontrollerOwn;
  List<ProjectList> _ownProjects;
  TeamRole _selectedteamRole;

  bool showDevider = false;
  @override
  void initState() {
    super.initState();

    _projects = [];
    _streamcontroller = StreamController<List<ProjectList>>.broadcast();
    _ownProjects = [];
    _streamcontrollerOwn = StreamController<List<ProjectList>>.broadcast();
    projectListLoad(true);
  }

  void projectListLoad(bool clearData) {
    if (clearData) {
      _projects = [];
      _ownProjects = [];
      _streamcontroller.add(_projects);
      _streamcontrollerOwn.add(_ownProjects);
    }

    setState(() {
      isLoading = true;
      showDevider = false;
    });

    projectListData().then((res) {
      // setState(() {
      isLoading = false;
      // });

      String activePerspective =
          Provider.of<PerspectiveProvider>(context, listen: false)
              .getActivePerspective();

      String activeId = '0';
      if (activePerspective == 'community') {
        activeId = Provider.of<MerchantProvider>(context, listen: false)
            .merchantData
            .id
            .toString();
      } else {
        activeId = Provider.of<UserProvider>(context, listen: false)
            .userData
            .id
            .toString();
      }

      if (res.length != 0) {
        res.forEach((ProjectList project) {
          if (project.owner.type == activePerspective &&
              project.owner.id == activeId) {
            _ownProjects.add(project);
          } else {
            _projects.add(project);
          }
        });
      }

      _streamcontroller.add(_projects);
      _streamcontrollerOwn.add(_ownProjects);

      if (_ownProjects.length != 0) {
        showDevider = true;
      }
      setState(() {});
    });
  }

  Future<List<ProjectList>> projectListData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['search'] = searchKey;

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/ListProject', apiBodyObj);

    List responseList = response['result'];

    List<ProjectList> getData = responseList.map<ProjectList>((json) {
      return ProjectList.fromJson(json);
    }).toList();

    return getData;
  }

  createProjectClicked() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          hackathonId: widget.hackathonId,
        ),
      ),
    ).whenComplete(() => projectListLoad(true));
  }

  onProjectClickHandler(bool ownProject, ProjectList project) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProjectDataScreen(
          hackathonId: widget.hackathonId,
          ownProject: ownProject,
          project: project),
    ));
  }

  removeProject(ProjectList data) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = data.id;

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/RemoveProject', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      _projects.remove(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => createProjectClicked(),
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: 10, bottom: 100),
            children: [
              StreamBuilder(
                stream: _streamcontrollerOwn.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ProjectList>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            ProjectList project = snapshot.data[index];

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              title: Text(project.projectName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    project.teamName,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                  SizedBox(height: 10),
                                  Text(project.projectDescription),
                                ],
                              ),
                              onTap: () => onProjectClickHandler(true, project),
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
              showDevider
                  ? Divider(
                      thickness: 3,
                    )
                  : SizedBox(),
              isLoading
                  ? SizedBox()
                  : Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Team needs a :',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: const OutlineInputBorder(),
                        ),
                        icon: Icon(Icons.arrow_downward),
                        value: _selectedteamRole,
                        onChanged: (TeamRole value) {
                          setState(() {
                            _selectedteamRole = value;
                            searchKey = value.value;
                            projectListLoad(true);
                          });
                        },
                        items: TeamRole.teamRoles.map((TeamRole teamRole) {
                          return DropdownMenuItem<TeamRole>(
                            value: teamRole,
                            child: Text(
                              teamRole.name,
                              // style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
              StreamBuilder(
                stream: _streamcontroller.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ProjectList>> snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            ProjectList project = snapshot.data[index];

                            return Slidable(
                              key: ValueKey(index),
                              actionPane: SlidableDrawerActionPane(),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () =>
                                      removeProject(snapshot.data[index]),
                                ),
                              ],
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding),
                                title: Text(project.projectName),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      project.teamName,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                    SizedBox(height: 10),
                                    Text(project.projectDescription),
                                  ],
                                ),
                                onTap: () =>
                                    onProjectClickHandler(false, project),
                              ),
                            );
                          },
                        )
                      : SizedBox();
                },
              ),
            ],
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
