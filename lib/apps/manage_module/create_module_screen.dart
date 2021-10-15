import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/manage_module/components/option_shop_template.dart';
import 'package:tagcash/apps/manage_module/components/option_tutorial_template.dart';
import 'package:tagcash/apps/manage_module/models/shop_item.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/dialog.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import 'details_module_screen.dart';
import 'models/module_category.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:image_picker/image_picker.dart';

import 'models/template_module.dart';

class CreateModuleScreen extends StatefulWidget {
  @override
  _CreateModuleScreenState createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  bool isLoading = false;
  bool transferClickPossible = true;
  MapboxMapController mapController;

  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;

  Future<List<ModuleCategory>> categoryList;
  ModuleCategory categoryDropdownValue;

  List developmentMethods = [];

  Map developmentMethodValue;
  String developmentMethodName = '';

  File _iconImageFile;
  Uint8List _iconImageBytes;
  final picker = ImagePicker();

  bool geoRestrictStatus = false;
  bool subscriptionStatus = false;

  String initialCountryCode = 'PH';
  String countrySelectedId = '174';

  int geoMethodIndex = 0;
  Location location = Location();
  LocationData _locationData =
      LocationData.fromMap({'latitude': 14.590517, 'longitude': 120.979941});
  double _currentSliderValue = 10;

  bool availableForUser = true;
  bool availableForMerchant = true;
  bool privateModuleStatus = false;
  bool agreeTermsStatus = false;
  Future<List<Role>> rolesListData;
  Role roleSelected;

  TapGestureRecognizer _myTapGestureRecognizer;
  LatLng selececedLocation;

  int _paymentMethod = 0;

  TextEditingController _nameController;
  TextEditingController _urlController;
  TextEditingController _shortDescriptionController;
  TextEditingController _amountController;

  Future<List<TemplateModule>> availableTemplates;
  TemplateModule templateSelected;
  String templateData = '';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _urlController = TextEditingController();
    _shortDescriptionController = TextEditingController();
    _amountController = TextEditingController();

    _myTapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launch('https://www.tagcash.com/privacy.php');
      };

    checkLocation();

    categoryList = categoryListLoad();

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      rolesListData = rolesListLoad();
      availableTemplates = loadAvailableTemplates();

      developmentMethods = [
        {"name": "Flutter", "value": "flutter"},
        {"name": "Template", "value": "template"},
        {"name": "Web URL", "value": "website"},
        {"name": "HTML", "value": "html"},
      ];
    } else {
      developmentMethods = [
        {"name": "Flutter", "value": "flutter"},
        {"name": "Web URL", "value": "website"},
        {"name": "HTML", "value": "html"},
      ];
    }
  }

  @override
  void dispose() {
    _myTapGestureRecognizer.dispose();

    _nameController.dispose();
    _urlController.dispose();
    _shortDescriptionController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  Future<List<ModuleCategory>> categoryListLoad() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/CategoryList');

    List responseList = response['list'];

    List<ModuleCategory> getData = responseList.map<ModuleCategory>((json) {
      return ModuleCategory.fromJson(json);
    }).toList();

    return getData;
  }

  Future<List<Role>> rolesListLoad() async {
    Map<String, dynamic> response = await NetworkHelper.request('role/list');

    List responseList = response['result'];

    List<Role> getData = responseList.map<Role>((json) {
      return Role.fromJson(json);
    }).toList();

    getData.insert(0, Role(id: 0, roleName: 'Any Role'));

    return getData;
  }

  Future<List<TemplateModule>> loadAvailableTemplates() async {
    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/TemplateList');

    List responseList = response['list'];

    List<TemplateModule> getData = responseList.map<TemplateModule>((json) {
      return TemplateModule.fromJson(json);
    }).toList();

    return getData;
  }

  checkLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    // setState(() {
    //   locationAvailable = true;
    // });
  }

  next() {
    // currentStep + 1 != steps.length

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'user') {
      currentStep + 1 != 2 ? goTo(currentStep + 1) : submitModuleData();
    }
    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      currentStep + 1 != 3 ? goTo(currentStep + 1) : submitModuleData();
    }
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  void _onMapCreated(MapboxMapController controller) {
    this.mapController = controller;
  }

  void _onStyleLoaded() {
    addImageFromAsset('assetImage', "assets/images/custom-icon.png");
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController.addImage(name, list);
  }

  Symbol addedSymbol;

  void _onMapClicked(Point<double> point, LatLng coordinates) {
    if (addedSymbol != null) {
      mapController.removeSymbol(addedSymbol);
    }

    selececedLocation = LatLng(coordinates.latitude, coordinates.longitude);
    mapController
        .addSymbol(SymbolOptions(
          geometry: LatLng(coordinates.latitude, coordinates.longitude),
          iconImage: 'assetImage',
          iconSize: 1.5,
        ))
        .then((value) => addedSymbol = value);
  }

  void iconSelectClicked() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() {
          _iconImageFile = File(pickedFile.path);
        });
        await pickedFile.readAsBytes().then((value) => _iconImageBytes = value);
      } else {
        File croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 256,
          maxHeight: 256,
          compressFormat: ImageCompressFormat.png,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Color(0xFFe44933),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
        );

        setState(() {
          _iconImageFile = croppedFile;
        });
        await croppedFile
            .readAsBytes()
            .then((value) => _iconImageBytes = value);
      }
    }
  }

  void submitModuleData() async {
    if (_nameController.text.trim() == '') {
      showSnackBar('Please enter a name of Mini Program');
      return;
    }
    if (!Validator.isAlphaNumeric(_nameController.text.replaceAll(' ', ''))) {
      showSnackBar('Please enter an alphanumeric name');
      return;
    }
    if (categoryDropdownValue == null) {
      showSnackBar('Please select category');
      return;
    }
    if (developmentMethodValue == null) {
      showSnackBar('Please select development method');
      return;
    }

    if (developmentMethodValue['value'] == 'website' &&
        !Validator.isURL('https://${_urlController.text}')) {
      showSnackBar('Please add a valid URL');
      return;
    }

    if (developmentMethodValue['value'] == 'template' && templateData == '') {
      showSnackBar('Please select template options');
      return;
    }

    if (_iconImageFile == null) {
      showSnackBar('Select Mini Program Icon');
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['module_name'] = _nameController.text.trim();

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModules/CheckExistModuleName', apiBodyObj);

    if (response['nameExit'] == 'no') {
      createNewModule();
    } else {
      setState(() {
        isLoading = false;
      });

      showSimpleDialog(context,
          title: getTranslated(context, 'error'),
          message: 'You already have a mini program with same name.');
    }
  }

  void createNewModule() async {
    Map<String, String> apiBodyObj = {};

    apiBodyObj['module_name'] = _nameController.text.trim();

    apiBodyObj['module_type'] = developmentMethodValue['value'];
    if (developmentMethodValue['value'] == 'website') {
      String moduleUrl = 'https://' + _urlController.text.toLowerCase();
      apiBodyObj['beta_module_url'] = moduleUrl;
      apiBodyObj['live_module_url'] = moduleUrl;
    }

    if (developmentMethodValue['value'] == 'template') {
      apiBodyObj['template_details'] = templateData;
    }

    apiBodyObj['category_id'] = categoryDropdownValue.id.toString();
    apiBodyObj['short_description'] = _shortDescriptionController.text;

    if (geoRestrictStatus) {
      if (geoMethodIndex == 0) {
        apiBodyObj['geo_country_id'] = countrySelectedId;
      } else {
        apiBodyObj['geo_latitude'] = selececedLocation.latitude.toString();
        apiBodyObj['geo_Longitude'] =
            selececedLocation.longitude.toString(); //make L small
        apiBodyObj['geo_radius'] = _currentSliderValue.round().toString();
      }
    }

    //(0-both,1-user,2- merchant) change to perspective
    if (availableForUser && availableForMerchant) {
      apiBodyObj['access_visible'] = '0';
    } else if (availableForUser) {
      apiBodyObj['access_visible'] = '1';
    } else if (availableForMerchant) {
      apiBodyObj['access_visible'] = '2';
    }

    if (privateModuleStatus) {
      apiBodyObj['access_module'] = 'private';

      apiBodyObj['access_module_role '] = '0';
      if (roleSelected != null) {
        apiBodyObj['access_module_role '] = roleSelected.id.toString();
      }
    } else {
      apiBodyObj['access_module'] = 'public';
    }

    if (_paymentMethod == 1) {
      apiBodyObj['pricing'] = 'paid'; //(free,paid)
      if (subscriptionStatus) {
        apiBodyObj['subscription_type'] = 'monthly'; //monthly,single,yearly
      } else {
        apiBodyObj['subscription_type'] = 'single';
      }
      apiBodyObj['wallet_id'] = '1152';
      apiBodyObj['amount'] = _amountController.text;
    } else {
      apiBodyObj['pricing'] = 'free';
      // apiBodyObj['subscription_amount'] = '0';
    }

    Map<String, dynamic> fileData;
    if (_iconImageFile != null) {
      var file = _iconImageFile;
      String basename = path.basename(file.path);

      fileData = {};
      fileData['key'] = 'icon';
      fileData['fileName'] = basename;
      fileData['path'] = file.path;
      fileData['bytes'] = _iconImageBytes;
    }

    //(create ,review ,develop ,published and inactive)
    if (privateModuleStatus && developmentMethodValue['value'] == 'website') {
      apiBodyObj['stages'] = 'published';
      apiBodyObj['app_published'] = '1';
    } else {
      apiBodyObj['stages'] = 'develop';
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModules/Create', apiBodyObj, fileData);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailsModuleScreen(moduleId: int.parse(response['id'])),
        ),
      );
    } else {}
  }

  showSnackBar(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  Widget build(BuildContext context) {
    bool userPerspective =
        Provider.of<PerspectiveProvider>(context).getActivePerspective() ==
                'user'
            ? true
            : false;

    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'MINI PROGRAM CONFIG',
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Stepper(
              currentStep: currentStep,
              type: StepperType.horizontal,
              physics: currentStep == 0
                  ? AlwaysScrollableScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              onStepContinue: next,
              onStepTapped: (step) => goTo(step),
              onStepCancel: cancel,
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (userPerspective)
                        ElevatedButton(
                          onPressed: currentStep == 1
                              ? agreeTermsStatus
                                  ? onStepContinue
                                  : null
                              : onStepContinue,
                          child: Text(currentStep == 1 ? 'SUBMIT' : 'CONTINUE'),
                        ),
                      if (!userPerspective)
                        ElevatedButton(
                          onPressed: currentStep == 2
                              ? agreeTermsStatus
                                  ? onStepContinue
                                  : null
                              : onStepContinue,
                          child: Text(currentStep == 2 ? 'SUBMIT' : 'CONTINUE'),
                        )
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Details'),
                  isActive: currentStep == 0 ? true : false,
                  state: StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name of Mini Program',
                        ),
                        maxLength: 50,
                        // maxLengthEnforced: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: FutureBuilder(
                            future: categoryList,
                            builder: (context,
                                AsyncSnapshot<List<ModuleCategory>> snapshot) {
                              if (snapshot.hasError) print(snapshot.error);

                              if (snapshot.hasData) {
                                return DropdownButtonFormField<ModuleCategory>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    labelText: 'Category',
                                    border: const OutlineInputBorder(),
                                  ),
                                  value: categoryDropdownValue,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  onChanged: (ModuleCategory newValue) {
                                    setState(() {
                                      categoryDropdownValue = newValue;
                                    });
                                  },
                                  items: snapshot.data
                                      .map<DropdownMenuItem<ModuleCategory>>(
                                          (value) {
                                    return DropdownMenuItem<ModuleCategory>(
                                      value: value,
                                      child: Row(
                                        children: [
                                          // Text(value),
                                          Image.network(
                                            value.icon,
                                            width: 30,
                                            height: 30,
                                          ),
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
                            }),
                      ),
                      DropdownButtonFormField(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          labelText: 'Development method',
                          border: const OutlineInputBorder(),
                        ),
                        value: developmentMethodValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (newValue) {
                          setState(() {
                            developmentMethodValue = newValue;
                            developmentMethodName = newValue['value'];
                          });
                        },
                        items:
                            developmentMethods.map<DropdownMenuItem>((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value['name']),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      if (developmentMethodName == 'flutter' ||
                          developmentMethodName == 'html')
                        Text(
                            'Code can be uploaded to git repository, URL will be given after completing the details here.'),
                      if (developmentMethodName == 'website') ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'https://',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            // SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  labelText: 'URL',
                                  // helperText: 'Enter a valid URL',
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                      if (developmentMethodName == 'template') ...[
                        SizedBox(height: 20),
                        FutureBuilder(
                          future: availableTemplates,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<TemplateModule>> snapshot) {
                            if (snapshot.hasError) print(snapshot.error);

                            return snapshot.hasData
                                ? DropdownButtonFormField<TemplateModule>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Template',
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                    ),
                                    value: templateSelected,
                                    icon: Icon(Icons.arrow_downward),
                                    items: snapshot.data
                                        .map<DropdownMenuItem<TemplateModule>>(
                                            (TemplateModule value) {
                                      return DropdownMenuItem<TemplateModule>(
                                        value: value,
                                        child: Text(
                                          value.name,
                                        ),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Select Template';
                                      }
                                      return null;
                                    },
                                    onChanged: (TemplateModule newValue) {
                                      setState(() {
                                        templateSelected = newValue;
                                        templateData = '';

                                        if (templateSelected.code == 'dating') {
                                          Map<String, dynamic> templateDataMap =
                                              {};
                                          templateDataMap['template_code'] =
                                              templateSelected.code;
                                          templateDataMap['template_data'] = [
                                            '0'
                                          ];

                                          templateData =
                                              jsonEncode(templateDataMap);
                                        }
                                      });
                                    },
                                  )
                                : Center(child: Loading());
                          },
                        ),
                      ],
                      if (templateSelected != null) ...[
                        SizedBox(height: 10),
                        Text(
                          '${templateSelected.amount} Credit per month',
                          textAlign: TextAlign.center,
                          // style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 20),
                        if (templateSelected.code == 'help_tutorials')
                          OptionTutorialTemplate(
                            onTutorialChanged: (List selectedId) {
                              Map<String, dynamic> templateDataMap = {};
                              templateDataMap['template_code'] =
                                  templateSelected.code;
                              templateDataMap['template_data'] = selectedId;

                              templateData = jsonEncode(templateDataMap);
                            },
                          ),
                        if (templateSelected.code == 'shopping')
                          OptionShopTemplate(
                            onShopChanged: (ShopItem shopItem) {
                              Map<String, dynamic> templateDataMap = {};
                              templateDataMap['template_code'] =
                                  templateSelected.code;
                              templateDataMap['template_data'] = [shopItem.id];

                              templateData = jsonEncode(templateDataMap);
                            },
                          ),
                      ],
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _shortDescriptionController,
                        minLines: 2,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Graphics',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        title: Text('Icon'),
                        subtitle: Text('JPEG or 32-bit PNG 256 px by 256 px'),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: _iconImageFile != null
                                ? DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(_iconImageFile.path)
                                        : FileImage(_iconImageFile),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onTap: () => iconSelectClicked(),
                        contentPadding: EdgeInsets.all(0),
                      )
                    ],
                  ),
                ),
                Step(
                  title: const Text('GEO'),
                  isActive: currentStep == 1 ? true : false,
                  state: StepState.indexed,
                  content: Column(
                    // shrinkWrap: true,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text("Geo Restriction"),
                            value: geoRestrictStatus,
                            contentPadding: EdgeInsets.all(0),
                            onChanged: (newValue) {
                              setState(() {
                                geoRestrictStatus = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          Text(
                            'Restrict access to services on a geographical basis. Select a country or specify a location.',
                          ),
                          AbsorbPointer(
                            absorbing: geoRestrictStatus ? false : true,
                            child: Opacity(
                              opacity: geoRestrictStatus ? 1 : 0.5,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  CustomSlidingSegmentedControl<int>(
                                    fixedWidth: 100,
                                    children: {
                                      0: Text('Country'),
                                      1: Text('Location'),
                                    },
                                    radius: 12,
                                    elevation: 4,
                                    innerPadding: 4,
                                    initialValue: geoMethodIndex,
                                    onValueChanged: (value) {
                                      setState(() {
                                        geoMethodIndex = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Visibility(
                                    visible: geoMethodIndex == 0,
                                    child: CountriesFormField(
                                      labelText: 'Select country',
                                      initialCountryCode: initialCountryCode,
                                      onChanged: (country) {
                                        if (country != null) {
                                          _formKey.currentState.validate();
                                          countrySelectedId = country['id'];
                                        }
                                      },
                                      validator: (country) {
                                        if (country == null) {
                                          return 'Pleae select a country';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Visibility(
                                    visible: geoMethodIndex == 1,
                                    child: SizedBox(
                                      height: 160.0,
                                      child: MapboxMap(
                                        accessToken: AppConstants.mapboxKey,
                                        onMapCreated: _onMapCreated,
                                        onStyleLoadedCallback: _onStyleLoaded,
                                        myLocationEnabled: false,
                                        compassEnabled: false,
                                        zoomGesturesEnabled: true,
                                        onMapClick: _onMapClicked,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(_locationData.latitude,
                                              _locationData.longitude),
                                          zoom: 11.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Visibility(
                                    visible: geoMethodIndex == 1,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Radius',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                        Expanded(
                                          child: Slider(
                                            value: _currentSliderValue,
                                            min: 5,
                                            max: 50,
                                            // divisions: 5,
                                            label: _currentSliderValue
                                                .round()
                                                .toString(),
                                            onChanged: (double value) {
                                              setState(() {
                                                _currentSliderValue = value;
                                              });
                                            },
                                          ),
                                        ),
                                        Text(
                                          _currentSliderValue
                                                  .round()
                                                  .toString() +
                                              ' km',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      if (userPerspective) ...[
                        SizedBox(height: 30),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'I Agree To The ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                  text: 'Terms And Conditions',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                  recognizer: _myTapGestureRecognizer)
                            ]),
                          ),
                          value: agreeTermsStatus,
                          onChanged: (newValue) {
                            setState(() {
                              agreeTermsStatus = newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!userPerspective) ...[
                  Step(
                    title: const Text('Access'),
                    isActive: currentStep == 2 ? true : false,
                    state: StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Visible to',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            CheckboxListTile(
                              title: Text("User"),
                              value: availableForUser,
                              onChanged: (newValue) {
                                setState(() {
                                  availableForUser = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            CheckboxListTile(
                              title: Text("Business"),
                              value: availableForMerchant,
                              onChanged: (newValue) {
                                setState(() {
                                  availableForMerchant = newValue;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                        Text(
                            'Private Mini Programs will be visible only to yourself or to members of a Business'),
                        CheckboxListTile(
                          title: Text("Private module"),
                          value: privateModuleStatus,
                          onChanged: (newValue) {
                            setState(() {
                              privateModuleStatus = newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (!userPerspective && privateModuleStatus) ...[
                          FutureBuilder(
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
                                            child: Text(value.roleName),
                                          );
                                        }).toList(),
                                        onChanged: (Role newValue) {
                                          setState(() {
                                            roleSelected = newValue;
                                          });
                                        },
                                      )
                                    : Center(child: Loading());
                              })
                        ],
                        SizedBox(height: 20),
                        Text(
                          'Pricing ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                title: Text('Free'),
                                value: 0,
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                title: Text('Paid'),
                                value: 1,
                                groupValue: _paymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_paymentMethod == 1) ...[
                          CheckboxListTile(
                            title: Text("Subscription"),
                            value: subscriptionStatus,
                            contentPadding: EdgeInsets.all(0),
                            onChanged: (newValue) {
                              setState(() {
                                subscriptionStatus = newValue;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: false),
                            decoration: InputDecoration(
                              icon: Icon(Icons.payment),
                              labelText: subscriptionStatus
                                  ? 'Monthly subscription'
                                  : 'Mini Program price',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter amount';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4),
                          Text(
                            'User will be charged in Credits.',
                          ),
                        ],
                        SizedBox(height: 30),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'I Agree To The ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                  text: 'Terms And Conditions',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                  recognizer: _myTapGestureRecognizer)
                            ]),
                          ),
                          value: agreeTermsStatus,
                          onChanged: (newValue) {
                            setState(() {
                              agreeTermsStatus = newValue;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                  // Step(
                  //   title: const Text('Pricing'),
                  //   isActive: currentStep == 3 ? true : false,
                  //   state: StepState.indexed,
                  //   content: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [

                  //     ],
                  //   ),
                  // ),
                ],
              ],
            ),
          ),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}
