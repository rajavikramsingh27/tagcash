import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/user_merchant/models/role.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/countries_form_field.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';
import 'package:path/path.dart' as path;
import 'models/module_category.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:image_picker/image_picker.dart';

import 'models/module_details.dart';

class EditModuleScreen extends StatefulWidget {
  final int moduleId;

  const EditModuleScreen({Key key, this.moduleId}) : super(key: key);

  @override
  _EditModuleScreenState createState() => _EditModuleScreenState();
}

class _EditModuleScreenState extends State<EditModuleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool transferClickPossible = true;
  MapboxMapController mapController;

  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;

  Future<List<ModuleCategory>> categoryList;
  ModuleCategory categoryDropdownValue;
  Future<List<Role>> rolesListData;
  Role roleSelected;

  int stackIndex = 0;

  ModuleDetails moduleData;
  ModuleDetails moduleDetails;

  Map developmentMethodValue;

  File _iconImageFile;
  Uint8List _iconImageBytes;
  final picker = ImagePicker();

  bool geoRestrictStatus = false;
  bool subscriptionStatus = false;

  int geoMethodIndex = 0;
  String initialCountryCode = 'PH';
  String countrySelectedId = '174';
  Location location = Location();
  LocationData _locationData =
      LocationData.fromMap({'latitude': 14.590517, 'longitude': 120.979941});
  double _currentSliderValue = 10;

  bool availableForUser = false;
  bool availableForMerchant = false;
  bool privateModuleStatus = false;
  bool agreeTermsStatus = false;

  LatLng selececedLocation;

  int _paymentMethod = 0;

  // List<Step> steps = ;

  TextEditingController _urlController;
  TextEditingController _shortDescriptionController;
  TextEditingController _amountController;

  bool developmentIsWeb = false;
  String _serverIconPath = '';
  String moduleName = '';
  String moduleType = '';

  @override
  void initState() {
    super.initState();

    _urlController = TextEditingController();
    _shortDescriptionController = TextEditingController();
    _amountController = TextEditingController();

    getModuleDetails();
  }

  @override
  void dispose() {
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

  void getModuleDetails() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['id'] = widget.moduleId.toString();

    Map<String, dynamic> response =
        await NetworkHelper.request('DynamicModules/ModuleById', apiBodyObj);

    // if (response['status'] == 'success') {
    Map responseMap = response['list'];
    moduleData = ModuleDetails.fromJson(responseMap);

    ModuleDetails moduleDetails = ModuleDetails.fromJson(responseMap);

    moduleName = moduleDetails.moduleName;
    moduleType = methodsName(moduleDetails.moduleType);

    if (moduleDetails.moduleType == 'website') {
      developmentIsWeb = true;

      String liveModuleUrl = moduleDetails.liveModuleUrl;
      _urlController.text = liveModuleUrl.replaceAll('https://', '');
    }
    _shortDescriptionController.text = moduleDetails.shortDescription;
    _serverIconPath = moduleDetails.icon;

    if (moduleDetails.accessVisible == 0) {
      availableForUser = true;
      availableForMerchant = true;
    } else if (moduleDetails.accessVisible == 1) {
      availableForUser = true;
    } else if (moduleDetails.accessVisible == 2) {
      availableForMerchant = true;
    }

    stackIndex = 1;
    // }
    setState(() {});

    String categoryActive = moduleDetails.categoryId;
    categoryList = categoryListLoad();

    categoryList.then((value) {
      for (var item in value) {
        if (categoryActive == item.id.toString()) {
          categoryDropdownValue = item;
        }
      }
    });

    if (Provider.of<PerspectiveProvider>(context, listen: false)
            .getActivePerspective() ==
        'community') {
      rolesListData = rolesListLoad();
    }
  }

  String methodsName(String method) {
    switch (method) {
      case 'flutter':
        return 'Flutter';
        break;
      case 'html':
        return 'HTML';
        break;
      case 'website':
        return 'Web URL';
        break;
      case 'template':
        return 'Using Template';
        break;
      default:
        return '';
    }
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

  // _locationData = await location.getLocation();
  // print(_locationData.latitude);
  // print(_locationData.longitude);

  // setState(() {
  //   locationAvailable = true;
  // });

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
    if (categoryDropdownValue == null) {
      showSnackBar('Please select category');
      return;
    }

    if (developmentIsWeb &&
        !Validator.isURL('https://${_urlController.text}')) {
      showSnackBar('Please add a valid URL');
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};

    apiBodyObj['id'] = widget.moduleId.toString();

    if (developmentIsWeb) {
      String moduleUrl = 'https://' + _urlController.text.toLowerCase();
      apiBodyObj['beta_module_url'] = moduleUrl;
      apiBodyObj['live_module_url'] = moduleUrl;
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
    }

    Map<String, dynamic> response = await NetworkHelper.request(
        'DynamicModules/Create', apiBodyObj, fileData);

    // setState(() {
    //   isLoading = false;
    // });
    if (response['status'] == 'success') {
      Navigator.pop(context);
    } else {}
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'MINI PROGRAM EDIT',
      ),
      key: _scaffoldKey,
      body: IndexedStack(
        index: stackIndex,
        children: [
          Center(child: Loading()),
          Stack(
            children: [
              Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      ListTile(
                        title: Text(moduleName),
                        subtitle: Text(moduleType),
                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
                      developmentIsWeb
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'https://',
                                    style:
                                        Theme.of(context).textTheme.headline6,
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
                          : SizedBox(),
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
                      _iconImageFile == null
                          ? ListTile(
                              title: Text('Icon'),
                              subtitle:
                                  Text('JPEG or 32-bit PNG 256 px by 256 px'),
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  image: _serverIconPath != ''
                                      ? DecorationImage(
                                          image: NetworkImage(_serverIconPath),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onTap: () => iconSelectClicked(),
                              contentPadding: EdgeInsets.all(0),
                            )
                          : ListTile(
                              title: Text('Icon'),
                              subtitle:
                                  Text('JPEG or 32-bit PNG 256 px by 256 px'),
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  image: DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(_iconImageFile.path)
                                        : FileImage(_iconImageFile),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onTap: () => iconSelectClicked(),
                              contentPadding: EdgeInsets.all(0),
                            ),
                      SizedBox(height: 20),
                      Text(
                        'Geographical Restriction',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Geo Restriction",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        value: geoRestrictStatus,
                        contentPadding: EdgeInsets.all(0),
                        onChanged: (newValue) {
                          setState(() {
                            geoRestrictStatus = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (geoRestrictStatus) ...[
                        SizedBox(height: 10),
                        Center(
                          child: CustomSlidingSegmentedControl<int>(
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
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              Expanded(
                                child: Slider(
                                  value: _currentSliderValue,
                                  min: 5,
                                  max: 50,
                                  // divisions: 5,
                                  label: _currentSliderValue.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                _currentSliderValue.round().toString() + ' km',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
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
                        ],
                      ),
                      SizedBox(height: 20),
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
                      if (Provider.of<PerspectiveProvider>(context,
                                      listen: false)
                                  .getActivePerspective() ==
                              'community' &&
                          privateModuleStatus) ...[
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
                            }),
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
                      ElevatedButton(
                        onPressed: () => submitModuleData(),
                        child: Text('SUBMIT'),
                      )
                    ],
                  )),
              isLoading ? Center(child: Loading()) : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
