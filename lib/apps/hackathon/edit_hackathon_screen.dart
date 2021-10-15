import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/models/wallet.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/countries.dart';
import 'package:tagcash/utils/validator.dart';

import 'models/hackathon_detail.dart';
import 'models/score_item.dart';

class EditHackathonScreen extends StatefulWidget {
  final HackathonDetail hackathonDetail;
  const EditHackathonScreen({Key key, this.hackathonDetail}) : super(key: key);

  @override
  _EditHackathonScreenState createState() => _EditHackathonScreenState();
}

class _EditHackathonScreenState extends State<EditHackathonScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  Future<List<Role>> rolesListData;
  Role roleSelected;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _durationController = TextEditingController();

  TextEditingController _teamMemberController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _urlController = TextEditingController();
  TextEditingController _registrationDateController = TextEditingController();

  String countryCode = 'PH';
  String countryName = 'Philippines';

  DateTime fromDate;
  DateTime registerDate;
  String endDateDisplay = '';

  List<String> prizeList = [];
  static List<ScoreItem> scoringList = [];

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.hackathonDetail.hackathonName;

    Map<String, String> _selectedCountry = countries.firstWhere(
        (item) => item['name'] == widget.hackathonDetail.hackathonCountry);
    countryCode = _selectedCountry['code'];
    countryName = widget.hackathonDetail.hackathonCountry;

    fromDate = DateTime.parse(
        '${widget.hackathonDetail.fromDate} ${widget.hackathonDetail.fromTime}');
    _fromDateController.text =
        DateFormat('h:mm aaa dd MMM yyy').format(fromDate);

    _durationController.text = widget.hackathonDetail.duration;
    _teamMemberController.text = widget.hackathonDetail.maxTeamMembers;
    for (var i = 0; i < widget.hackathonDetail.prize.length; i++) {
      prizeList.add(widget.hackathonDetail.prize[i].toString());
    }
    _descriptionController.text = widget.hackathonDetail.hackathonDescription;
    _urlController.text = widget.hackathonDetail.hackathonUrl;

    registerDate = DateTime.parse(widget.hackathonDetail.registrationOpenFrom);
    _registrationDateController.text =
        DateFormat('MMM dd, yyyy').format(registerDate);

    scoringList = [];
    for (ScoringCriteria item in widget.hackathonDetail.scoringCriteria) {
      scoringList.add(ScoreItem(
        percentage: int.parse(item.percentage),
        description: item.description,
      ));
    }

    rolesListData = rolesListLoad();
    endDateCalculate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromDateController.dispose();
    _durationController.dispose();
    _teamMemberController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _registrationDateController.dispose();

    super.dispose();
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();

    getData.insert(0, Role(id: 0, roleName: 'All'));

    roleSelected = getData.firstWhere(
        (item) => item.id.toString() == widget.hackathonDetail.roleId);

    return getData;
  }

  void onCountryChange(Map country) {
    countryCode = country['code'];
    countryName = country['name'];
  }

  froDateSelected(DateTime value) {}

  endDateCalculate() {
    if (fromDate != null && _durationController.text != '') {
      int duration = int.tryParse(_durationController.text) ?? 0;
      DateTime endDate = fromDate.add(Duration(hours: duration));

      endDateDisplay = DateFormat('h:mm aaa dd MMM yyy').format(endDate);
      setState(() {});
    }
  }

  void addPrizesShow() {
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
                child: PrizesDetailAdd(
                  onAddPrize: (value) {
                    Navigator.pop(context);

                    setState(() {
                      prizeList.add(value);
                    });
                  },
                ),
              ),
            ),
          );
        });
  }

  void createHackathonHandler() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.hackathonDetail.id;
    apiBodyObj['hackathon_name'] = _nameController.text;
    apiBodyObj['hackathon_country'] = countryName;

    apiBodyObj['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate);
    apiBodyObj['from_time'] = DateFormat('hh:mm').format(fromDate);
    apiBodyObj['duration'] = _durationController.text;
    apiBodyObj['restriction'] = roleSelected.roleName ?? 'All';
    apiBodyObj['role_id'] = roleSelected.id.toString();
    apiBodyObj['max_team_members'] = _teamMemberController.text;
    apiBodyObj['hackathon_description'] = _descriptionController.text;
    apiBodyObj['hackathon_url'] = _urlController.text;

    apiBodyObj['registration_open_from'] =
        DateFormat('yyyy-MM-dd').format(registerDate);

    apiBodyObj['prize'] = jsonEncode(prizeList);

    int scoreTotal = 0;
    List scoreItemSave = [];
    for (int i = 0; i < scoringList.length; i++) {
      ScoreItem scoreItem = scoringList[i];

      scoreTotal += scoreItem.percentage;
      scoreItemSave.add({
        'scoring_id': (i + 1).toString(),
        'percentage': scoreItem.percentage.toString(),
        'description': scoreItem.description
      });
    }

    if (scoreTotal != 100) {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: 'Your total scoring criteria is not 100%');

      return;
    }

    apiBodyObj['scoring_criteria'] = jsonEncode(scoreItemSave);

    //   apiBodyObj['sponsor_prize'] = sponsorprizelist.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('HackathonMini/EditHackathon', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      showSimpleDialog(context,
          title: getTranslated(context, 'error'), message: response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Create Hackathon',
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: enableAutoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Hackathon Name',
                    ),
                    validator: (value) {
                      if (!Validator.isRequired(value,
                          allowEmptySpaces: true)) {
                        return 'Hackathon Name required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CountriesFormField(
                    labelText: 'Select country',
                    initialCountryCode: countryCode,
                    onChanged: (country) {
                      if (country != null) {
                        onCountryChange(country);
                      }
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DateTimeField(
                          format: DateFormat('h:mm aaa dd MMM yyy'),
                          controller: _fromDateController,
                          resetIcon: null,
                          decoration: InputDecoration(
                            labelText: 'From date and time',
                          ),
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2021),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    currentValue ?? DateTime.now()),
                              );
                              return DateTimeField.combine(date, time);
                            } else {
                              return currentValue;
                            }
                          },
                          validator: (value) {
                            if (fromDate == null) {
                              return 'Please select a valid date';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            fromDate = value;
                            endDateCalculate();
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            labelText: 'Duration (hrs)',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                          validator: (value) {
                            if (!Validator.isRequired(value,
                                allowEmptySpaces: false)) {
                              return 'Please enter Duration';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            endDateCalculate();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ends On : $endDateDisplay',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: FutureBuilder(
                            future: rolesListData,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Role>> snapshot) {
                              if (snapshot.hasError) print(snapshot.error);

                              return snapshot.hasData
                                  ? DropdownButtonFormField<Role>(
                                      decoration: const InputDecoration(
                                        labelText: 'Select Role',
                                        border: const OutlineInputBorder(),
                                      ),
                                      value: roleSelected,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      items: snapshot.data
                                          .map<DropdownMenuItem<Role>>(
                                              (Role value) {
                                        return DropdownMenuItem<Role>(
                                          value: value,
                                          child: SizedBox(
                                            width: 100,
                                            child: Text(
                                              value.roleName,
                                              maxLines: 1,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Select Role';
                                        }
                                        return null;
                                      },
                                      onChanged: (Role newValue) {
                                        setState(() {
                                          roleSelected = newValue;
                                        });
                                      },
                                    )
                                  : Center(child: Loading());
                            }),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _teamMemberController,
                          decoration: InputDecoration(
                            labelText: 'Max Team Members',
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                          validator: (value) {
                            if (!Validator.isRequired(value,
                                allowEmptySpaces: false)) {
                              return 'Please enter Team Members';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_box,
                        color: Colors.red,
                        size: 34,
                      ),
                      onPressed: () => addPrizesShow(),
                    ),
                    title: Text('Prizes'),
                  ),
                  prizeList.length == 0
                      ? Text(
                          'Prizes not added',
                        )
                      : SizedBox(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: prizeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        key: ValueKey(index),
                        actionPane: SlidableDrawerActionPane(),
                        secondaryActions: [
                          IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                prizeList.remove(prizeList[index]);
                                setState(() {});
                              }),
                        ],
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          elevation: 3,
                          child: ListTile(
                            title: Text(prizeList[index]),
                          ),
                        ),
                      );
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Hackathon Description',
                    ),
                    validator: (value) {
                      if (!Validator.isRequired(value,
                          allowEmptySpaces: true)) {
                        return 'Please enter Description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Hackathon URL (Optional)',
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Scoring criteria',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  ...buildScoringInputs(),
                  SizedBox(height: 20),
                  DateTimeField(
                    format: DateFormat('MMM dd, yyyy'),
                    controller: _registrationDateController,
                    resetIcon: null,
                    decoration: InputDecoration(
                      labelText: 'Registration Open Date',
                    ),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(2021),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                    validator: (value) {
                      if (registerDate == null) {
                        return 'Please select a valid date';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      registerDate = value;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(getTranslated(context, 'save')),
                    onPressed: () {
                      setState(() {
                        enableAutoValidate = true;
                      });
                      if (_formKey.currentState.validate()) {
                        createHackathonHandler();
                      }
                    },
                  )
                ],
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildScoringInputs() {
    List<Widget> scoringTextFields = [];

    for (int i = 0; i < scoringList.length; i++) {
      scoringTextFields.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ScoringTextFields(i),
            ),
            SizedBox(
              width: 16,
            ),
            // _addRemoveButton(i == scoringList.length - 1, i),
            _addRemoveButton(i == 0, i),
          ],
        ),
      ));
    }
    return scoringTextFields;
  }

  Widget _addRemoveButton(bool add, int index) {
    return IconButton(
      icon: Icon((add) ? Icons.add_box : Icons.indeterminate_check_box),
      color: (add) ? Colors.green : Colors.red,
      onPressed: () {
        if (add) {
          // scoringList.insert(0, ScoreItem(percentage: null, description: null));
          scoringList.add(ScoreItem(percentage: null, description: null));
        } else
          scoringList.removeAt(index);
        setState(() {});
      },
    );
  }
}

class ScoringTextFields extends StatefulWidget {
  final int index;

  const ScoringTextFields(
    this.index,
  );

  @override
  _ScoringTextFieldsState createState() => _ScoringTextFieldsState();
}

class _ScoringTextFieldsState extends State<ScoringTextFields> {
  TextEditingController _percentageController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_EditHackathonScreenState.scoringList[widget.index].percentage !=
          null) {
        _percentageController.text = _EditHackathonScreenState
            .scoringList[widget.index].percentage
            .toString();
      }
      _descriptionController.text =
          _EditHackathonScreenState.scoringList[widget.index].description ?? '';
    });

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: _percentageController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => _EditHackathonScreenState
                .scoringList[widget.index].percentage = int.tryParse(v),
            decoration: InputDecoration(
              labelText: 'Score',
              suffixText: '%',
            ),
            validator: (v) {
              if (int.tryParse(v) == null) return 'Score';
              return null;
            },
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            controller: _descriptionController,
            onChanged: (v) => _EditHackathonScreenState
                .scoringList[widget.index].description = v,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (v) {
              if (v.trim().isEmpty) return 'Description';
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class PrizesDetailAdd extends StatefulWidget {
  final Function(String) onAddPrize;

  const PrizesDetailAdd({
    Key key,
    this.onAddPrize,
  }) : super(key: key);

  @override
  _PrizesDetailAddState createState() => _PrizesDetailAddState();
}

class _PrizesDetailAddState extends State<PrizesDetailAdd> {
  TextEditingController _prizeController = TextEditingController();

  Wallet selectedWallet;

  @override
  void dispose() {
    _prizeController.dispose();
    super.dispose();
  }

  prizeAddProcess() {
    if (_prizeController.text == '') {
      return;
    }

    widget.onAddPrize(_prizeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _prizeController,
          decoration: InputDecoration(
            labelText: 'Prize',
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text('ADD'),
          onPressed: () => prizeAddProcess(),
        )
      ],
    );
  }
}
