import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/hackathon/models/project_list.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/file_pick_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:path/path.dart' as path;

class CreateProjectScreen extends StatefulWidget {
  final String hackathonId;
  final ProjectList project;

  const CreateProjectScreen({Key key, this.project, this.hackathonId})
      : super(key: key);
  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  bool editingMode = false;
  bool publicStatus = true;
  File _presentationFile;

  TextEditingController _teamNameController = TextEditingController();
  TextEditingController _projectNameController = TextEditingController();
  TextEditingController _projectDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.project != null) {
      _teamNameController.text = widget.project.teamName;
      _projectNameController.text = widget.project.projectName;
      _projectDescriptionController.text = widget.project.projectDescription;
      if (widget.project.projectType != '1') {
        publicStatus = false;
      }
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    super.dispose();
  }

  void saveProjectData() async {
    setState(() {
      isLoading = true;
    });

    ProjectList projectEdited;

    Map<String, String> apiBodyObj = {};

    apiBodyObj['hackathon_id'] = widget.hackathonId;
    apiBodyObj['team_name'] = _teamNameController.text;
    apiBodyObj['project_name'] = _projectNameController.text;
    apiBodyObj['project_description'] = _projectDescriptionController.text;
    apiBodyObj['project_type'] = publicStatus ? '1' : '0';

    Map<String, dynamic> fileData;
    if (_presentationFile != null) {
      var file = _presentationFile;
      String basename = path.basename(file.path);

      fileData = {};
      fileData['key'] = 'project_presentation';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
    }

    String url;
    if (widget.project == null) {
      url = 'HackathonMini/CreateProject';
    } else {
      projectEdited = widget.project;
      projectEdited.teamName = _teamNameController.text;
      projectEdited.projectName = _projectNameController.text;
      projectEdited.projectDescription = _projectDescriptionController.text;
      projectEdited.projectType = publicStatus ? '1' : '0';

      apiBodyObj['_id'] = widget.project.id;
      url = 'HackathonMini/EditProject';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(url, apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      if (widget.project == null) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context, projectEdited);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: widget.project != null ? 'Edit Project' : 'Create Project',
      ),
      body: Stack(children: [
        Form(
          key: _formKey,
          autovalidateMode: enableAutoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            children: [
              TextFormField(
                controller: _teamNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  icon: Icon(Icons.group),
                  labelText: 'Team Name',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                    return 'Team Name required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _projectNameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.list_alt),
                  labelText: 'Project Name',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                    return 'Project Name required';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text("Public"),
                value: publicStatus,
                contentPadding: EdgeInsets.all(0),
                onChanged: (newValue) {
                  setState(() {
                    publicStatus = newValue;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              FilePickFormField(
                icon: Icon(Icons.file_upload),
                onChanged: (newFile) {
                  if (newFile != null) {
                    _presentationFile = newFile;
                  }
                },
                labelText: "Project Presentation",
                hintText: 'Please select a PDF',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _projectDescriptionController,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  icon: Icon(Icons.description),
                  labelText: 'Project Description',
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                    return 'Project Description required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    saveProjectData();
                  }
                },
                child: Text(getTranslated(context, 'save')),
              )
            ],
          ),
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ]),
    );
  }
}
