import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/create_project_screen.dart';
import 'package:tagcash/apps/hackathon/pages/project_votes_page.dart';
import 'package:tagcash/apps/user_merchant/user_detail_user_screen.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:url_launcher/url_launcher.dart';

import 'components/add_score.dart';
import 'components/award_prize.dart';
import 'components/project_repository.dart';
import 'models/admin_detail.dart';
import 'models/member_detail.dart';
import 'models/member_role.dart';
import 'models/project_list.dart';

class ProjectDataScreen extends StatefulWidget {
  final ProjectList project;
  final String hackathonId;
  final bool ownProject;

  const ProjectDataScreen(
      {Key key, this.project, this.hackathonId, this.ownProject})
      : super(key: key);

  @override
  _ProjectDataScreenState createState() => _ProjectDataScreenState();
}

class _ProjectDataScreenState extends State<ProjectDataScreen> {
  bool editableUser = false;
  bool adminUser = false;
  bool sponserUser = false;
  bool judgeUser = false;
  bool votableUser = false;

  ProjectList project;

  @override
  void initState() {
    super.initState();

    if (widget.ownProject) {
      editableUser = true;
    }

    project = widget.project;

    adminRoleCheck();
  }

  void adminRoleCheck() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['hackathon_id'] = widget.hackathonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/ListHackathonAdmins', apiBodyObj);

    List responseList = response['result'];
    List<AdminDetail> getData = responseList.map<AdminDetail>((json) {
      return AdminDetail.fromJson(json);
    }).toList();

    String activePerspective =
        Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective();

    if (activePerspective == 'user') {
      String activeId = Provider.of<UserProvider>(context, listen: false)
          .userData
          .id
          .toString();

      votableUser = true;

      if (widget.ownProject) {
        votableUser = false;
      }

      getData.forEach((AdminDetail adminDetail) {
        if (adminDetail.userDetail.id == activeId &&
            adminDetail.roleName == 'ADMIN') {
          votableUser = false;
          adminUser = true;
        }
        if (adminDetail.userDetail.id == activeId &&
            adminDetail.roleName == 'SPONSOR') {
          votableUser = false;
          sponserUser = true;
        }
        if (adminDetail.userDetail.id == activeId &&
            adminDetail.roleName == 'JUDGE') {
          votableUser = false;
          judgeUser = true;
        }
      });
      setState(() {});
    }
  }

  Future<void> _launchInBrowser(String projectPresentation) async {
    String url =
        'https://s3.amazonaws.com/tagbondbeta/uploads/hackathon/hackathon_projects/$projectPresentation';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  editProjectClicked() async {
    ProjectList projectEdited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          hackathonId: widget.hackathonId,
          project: project,
        ),
      ),
    );

    if (projectEdited != null) {
      setState(() {
        project = projectEdited;
      });
    }
  }

  void scoreClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: AddScore(
                    hackathonId: widget.hackathonId,
                    project: project,
                    judgeUser: judgeUser),
              ),
            ),
          );
        });
  }

  awardClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: AwardPrize(
                    hackathonId: widget.hackathonId,
                    project: project,
                    sponserUser: sponserUser,
                    adminUser: adminUser,
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Project'),
                Tab(text: 'Members'),
                Tab(text: 'App'),
                Tab(text: 'Votes'),
              ],
              isScrollable: true,
            ),
          ),
          title: 'Hackathon',
        ),
        body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
          Container(
            child: ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                Text(
                  project.projectName,
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 10),
                Text(
                  project.teamName,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(height: 10),
                Text(project.projectDescription),
                project.projectPresentation.isNotEmpty
                    ? ListTile(
                        leading: Icon(Icons.picture_as_pdf_rounded),
                        title: Text('Project Presentation'),
                        subtitle: Text('Click to open PDF document'),
                        onTap: () =>
                            _launchInBrowser(project.projectPresentation),
                      )
                    : SizedBox(),
                SizedBox(height: 20),
                Row(
                  children: [
                    editableUser
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                child: Text('EDIT'),
                                onPressed: () => editProjectClicked(),
                              ),
                            ),
                          )
                        : SizedBox(),
                    judgeUser
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                child: Text('SCORE'),
                                onPressed: () => scoreClicked(),
                              ),
                            ),
                          )
                        : SizedBox(),
                    votableUser
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                child: Text('VOTE'),
                                onPressed: () => scoreClicked(),
                              ),
                            ),
                          )
                        : SizedBox(),
                    adminUser || sponserUser
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                child: Text('AWARD'),
                                onPressed: () => awardClicked(),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          MembersList(
            ownProject: widget.ownProject,
            project: project,
          ),
          ProjectRepository(
            ownProject: widget.ownProject,
            project: project,
          ),
          ProjectVotesPage(
            hackathonId: widget.hackathonId,
            ownProject: widget.ownProject,
            project: project,
          ),
        ]),
      ),
    );
  }
}

class MembersList extends StatefulWidget {
  final ProjectList project;
  final bool ownProject;

  const MembersList({
    Key key,
    this.project,
    this.ownProject,
  }) : super(key: key);

  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  bool isLoading = false;
  StreamController<List<MemberDetail>> _streamcontroller;
  List<MemberDetail> _admins;

  bool editableUser = false;
  bool joinUser = false;

  @override
  void initState() {
    super.initState();

    if (widget.ownProject) {
      editableUser = true;
    }

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      joinUser = true;
    }

    _admins = [];
    _streamcontroller = StreamController<List<MemberDetail>>.broadcast();
    memberListLoad(true);
  }

  void memberListLoad(bool clearData) {
    if (clearData) {
      _admins = [];
      _streamcontroller.add(_admins);
    }

    setState(() {
      isLoading = true;
    });

    memberListData().then((res) {
      setState(() {
        isLoading = false;
      });

      if (res.length != 0) {
        _admins.addAll(res);
      }

      if (!widget.ownProject &&
          Provider.of<PerspectiveProvider>(context, listen: false)
                  .getActivePerspective() ==
              'user') {
        String activeId = Provider.of<UserProvider>(context, listen: false)
            .userData
            .id
            .toString();

        res.forEach((MemberDetail member) {
          if (member.userDetail.id == activeId && member.teamAdmin == '1') {
            editableUser = true;
          }
        });
      }

      _streamcontroller.add(_admins);
    });
  }

  Future<List<MemberDetail>> memberListData() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['project_id'] = widget.project.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/ListProjectMembers', apiBodyObj);
    List responseList = response['result'];

    List<MemberDetail> getData = responseList.map<MemberDetail>((json) {
      return MemberDetail.fromJson(json);
    }).toList();

    return getData;
  }

  void addMemberClicked() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: kBottomSheetShape,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: MemberUserAdd(
                  projectId: widget.project.id,
                  onInviteSelect: (value) => sendInviteConfirm(value),
                  onUsedAdded: () => memberListLoad(true),
                ),
              ),
            ),
          );
        });
  }

  sendInviteConfirm(String email) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'EMAIL NOT FOUND',
              textAlign: TextAlign.center,
            ),
            content: Text(
                'The email you entered doesn\'t have a Tagcash account. You want to invite this user to join Tagcash?'),
            actions: [
              FlatButton(
                child: Text(
                  'NO',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(width: 10),
              FlatButton(
                child: Text(
                  'INVITE',
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void inviteSendProcess(String email) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['email_required_status'] = '0';
    apiBodyObj['email'] = email;

    Map<String, dynamic> response =
        await NetworkHelper.request('contact/Invite', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Fluttertoast.showToast(msg: 'Invite email send successfully');
    } else {
      Fluttertoast.showToast(msg: 'Invitation sent Failed');
    }
  }

  memBerDetailClicked(MemberDetail data) {
    Map<String, dynamic> userData = {};
    userData['id'] = data.userDetail.id;
    userData['user_email'] = data.userDetail.userEmail;
    userData['name'] =
        data.userDetail.userFirstname + ' ' + data.userDetail.userLastname;
    userData['user_firstname'] = data.userDetail.userFirstname;
    userData['user_lastname'] = data.userDetail.userLastname;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailUserScreen(userData: userData),
      ),
    );
  }

  removeMember(MemberDetail data) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = data.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/RemoveProjectMember', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      _admins.remove(data);
    }
  }

  joinProject(MemberDetail data) async {
    setState(() {
      isLoading = true;
    });

    String email = Provider.of<UserProvider>(context, listen: false)
        .userData
        .email
        .toString();

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = data.id;
    apiBodyObj['email'] = email;

    apiBodyObj['project_id'] = data.projectId;
    apiBodyObj['member_option'] = data.memberOption;
    apiBodyObj['member_type'] = data.memberType;
    apiBodyObj['team_admin'] = data.teamAdmin;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/EditProjectMember', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      memberListLoad(true);
      Fluttertoast.showToast(
          msg: 'Your request has been successfully submitted');
    } else {
      Fluttertoast.showToast(msg: 'An error occurred. Please try again later.');
    }
  }

  approveMember(MemberDetail data) async {
    setState(() {
      isLoading = true;
    });

    String email = Provider.of<UserProvider>(context, listen: false)
        .userData
        .email
        .toString();

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = data.id;
    apiBodyObj['email'] = email;

    apiBodyObj['project_id'] = data.projectId;
    apiBodyObj['member_option'] = 'named';
    apiBodyObj['member_type'] = data.memberType;
    apiBodyObj['team_admin'] = data.teamAdmin;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/EditProjectMember', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      memberListLoad(true);
      Fluttertoast.showToast(msg: 'Join request approved');
    } else {
      Fluttertoast.showToast(msg: 'An error occurred. Please try again later.');
    }
  }

  String showMemberRoleText(String memberType) {
    MemberRole memberRole = MemberRole.memberRoles
        .firstWhere((o) => o.value == memberType, orElse: () => null);
    return memberRole != null ? memberRole.name : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => addMemberClicked(),
        child: Icon(Icons.add),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _streamcontroller.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<MemberDetail>> snapshot) {
              if (snapshot.hasError) print(snapshot.error);

              if (!snapshot.hasData) {
                return Center(child: Loading());
              } else {
                return ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    indent: 70,
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Slidable(
                      key: ValueKey(index),
                      actionPane: SlidableDrawerActionPane(),
                      enabled: editableUser ? true : false,
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => removeMember(snapshot.data[index]),
                        ),
                      ],
                      child: ListTile(
                        visualDensity: VisualDensity(vertical: -2),
                        leading: snapshot.data[index].email.isNotEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  AppConstants.getUserImagePath() +
                                      snapshot.data[index].userDetail.id
                                          .toString() +
                                      "?kycImage=0",
                                ),
                              )
                            : null,
                        title: snapshot.data[index].email.isNotEmpty
                            ? RichText(
                                text: TextSpan(
                                    text:
                                        '${snapshot.data[index].userDetail.userFirstname} ${snapshot.data[index].userDetail.userLastname}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: snapshot.data[index].teamAdmin ==
                                                '1'
                                            ? ' *'
                                            : '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    ]),
                              )
                            : Text(
                                'Team needs a ',
                                style: TextStyle(color: Colors.red),
                              ),
                        subtitle: Text(
                          showMemberRoleText(snapshot.data[index].memberType),
                        ),
                        trailing: buildTrailingButton(snapshot.data[index]),
                        onTap: snapshot.data[index].email.isNotEmpty
                            ? () => memBerDetailClicked(snapshot.data[index])
                            : null,
                      ),
                    );
                  },
                );
              }
            },
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }

  Widget buildTrailingButton(MemberDetail member) {
    Widget returnWidget = SizedBox();
    if (member.memberOption == 'open_slot') {
      if (member.email.isEmpty && joinUser) {
        returnWidget = OutlinedButton(
          child: Text('JOIN'),
          onPressed: () => joinProject(member),
        );
      } else if (member.email.isNotEmpty && editableUser) {
        returnWidget = SizedBox(
          width: 110,
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.done,
                      ),
                      iconSize: 30,
                      onPressed: () => approveMember(member),
                    )),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 50,
                child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                      ),
                      iconSize: 30,
                      onPressed: () => removeMember(member),
                    )),
              ),
            ],
          ),
        );
      } else if (member.email.isNotEmpty && joinUser) {
        returnWidget = SizedBox(
            width: 100,
            child: Text(
              'Waiting for approval',
              textAlign: TextAlign.center,
            ));
      }
    }
    return returnWidget;
  }
}

class MemberUserAdd extends StatefulWidget {
  final String projectId;
  final Function(String) onInviteSelect;
  final VoidCallback onUsedAdded;

  const MemberUserAdd({
    Key key,
    this.onInviteSelect,
    this.projectId,
    this.onUsedAdded,
  }) : super(key: key);

  @override
  _MemberUserAddState createState() => _MemberUserAddState();
}

class _MemberUserAddState extends State<MemberUserAdd> {
  TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  bool teamAdminStatus = false;
  MemberRole _memberRoleSelected;
  String userName = '';
  String memberOption = 'named';

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<bool> usercheckProcess() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['email'] = _idController.text;

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/GetUserByEmail', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response['status'] == 'success') {
      userName =
          '${response['result']['user_firstname']} ${response['result']['user_lastname']}';
      return true;
    } else {
      return false;
    }
  }

  userAddProcess() {
    if (memberOption == 'named') {
      usercheckProcess().then((value) {
        Navigator.pop(context);
        if (value) {
          addMemberProcess();
        } else {
          widget.onInviteSelect(_idController.text);
        }
      });
    } else {
      addMemberProcess();
    }
  }

  addMemberProcess() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['project_id'] = widget.projectId;
    apiBodyObj['member_option'] = memberOption;
    apiBodyObj['member_type'] = _memberRoleSelected.value;
    apiBodyObj['team_admin'] = teamAdminStatus ? '1' : '0';

    if (memberOption == 'named') {
      apiBodyObj['email'] = _idController.text;
    } else {
      apiBodyObj['user_name'] =
          ' '; //it is a bug this is not nneded correct in API
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/AddProjectMember', apiBodyObj);

    // setState(() {
    //   isLoading = false;
    // });

    if (response['status'] == 'success') {
      widget.onUsedAdded();
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg:
              'Unable to process your request at this time. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Radio(
                      value: 'named',
                      groupValue: memberOption,
                      onChanged: (value) {
                        setState(() {
                          memberOption = value;
                        });
                      },
                    ),
                    Text(
                      'Named',
                    ),
                    SizedBox(width: 20),
                    Radio(
                      value: 'open_slot',
                      groupValue: memberOption,
                      onChanged: (value) {
                        setState(() {
                          memberOption = value;
                        });
                      },
                    ),
                    Text(
                      'Open Slot',
                    )
                  ],
                ),
              ),
              DropdownButtonFormField<MemberRole>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select member role',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: const OutlineInputBorder(),
                ),
                value: _memberRoleSelected,
                icon: Icon(Icons.arrow_downward),
                items: MemberRole.memberRoles
                    .map<DropdownMenuItem<MemberRole>>((MemberRole value) {
                  return DropdownMenuItem<MemberRole>(
                    value: value,
                    child: Text(
                      value.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Member role required';
                  }
                  return null;
                },
                onChanged: (MemberRole newValue) {
                  setState(() {
                    _memberRoleSelected = newValue;
                    if (newValue.value == 'team_leader') {
                      teamAdminStatus = true;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Team Admin"),
                value: teamAdminStatus,
                contentPadding: EdgeInsets.all(0),
                onChanged: (newValue) {
                  setState(() {
                    teamAdminStatus = newValue;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              memberOption == 'named'
                  ? TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Email',
                          helperText: userName),
                      onChanged: (newInput) {
                        if (Validator.isEmail(newInput)) {
                          usercheckProcess();
                        }
                      },
                      validator: (value) {
                        if (!Validator.isEmail(value)) {
                          return 'Email required';
                        }
                        return null;
                      },
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              ElevatedButton(
                  child: Text('ADD'),
                  onPressed: () {
                    setState(() {
                      enableAutoValidate = true;
                    });
                    if (_formKey.currentState.validate()) {
                      userAddProcess();
                    }
                  })
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
