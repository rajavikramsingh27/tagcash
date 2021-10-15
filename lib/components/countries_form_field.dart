import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/utils/countries.dart';

class CountriesFormField extends StatefulWidget {
  const CountriesFormField({
    Key key,
    this.initialCountryCode,
    this.labelText,
    this.showName = true,
    this.onSaved,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  /// 2 Letter ISO Code
  final String initialCountryCode;
  final String labelText;
  final bool showName;

  final void Function(String) onSaved;
  final void Function(Map<String, String>) onChanged;
  final String Function(String) validator;

  // final ValueChanged<String> onChanged;
  // final FormFieldValidator<String> validator;

  @override
  _CountriesFormFieldState createState() => _CountriesFormFieldState();
}

class _CountriesFormFieldState extends State<CountriesFormField> {
  Map<String, String> _selectedCountry =
      countries.firstWhere((item) => item['code'] == 'US');
  List<Map<String, String>> filteredCountries = countries;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountryCode != null) {
      _selectedCountry = countries
          .firstWhere((item) => item['code'] == widget.initialCountryCode);
    }
  }

  Future<void> _changeCountry() async {
    filteredCountries = countries;
    await showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (ctx, setState) => Dialog(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.search),
                        labelText: 'Search by Country Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCountries = countries
                              .where((country) => country['name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCountries.length,
                        itemBuilder: (ctx, index) => Column(
                          children: <Widget>[
                            ListTile(
                              leading: Text(
                                kIsWeb
                                    ? filteredCountries[index]['code']
                                    : filteredCountries[index]['flag'],
                                style: TextStyle(fontSize: kIsWeb ? 14 : 30),
                              ),
                              title: Text(
                                filteredCountries[index]['name'],
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              trailing: Text(
                                filteredCountries[index]['dial_code'],
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              onTap: () {
                                _selectedCountry = filteredCountries[index];
                                if (widget.onChanged != null) {
                                  widget.onChanged(filteredCountries[index]);
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                            Divider(thickness: 1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormField(onSaved: (_) {
      if (widget.onSaved != null)
        return widget.onSaved(_selectedCountry['name']);
      return null;
    }, validator: (_) {
      if (widget.validator != null)
        return widget.validator(_selectedCountry['name']);
      return null;
    }, builder: (state) {
      return GestureDetector(
        onTap: _changeCountry,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.labelText,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
          child: Row(
            children: [
              Text(
                kIsWeb ? _selectedCountry['code'] : _selectedCountry['flag'],
                style: TextStyle(fontSize: kIsWeb ? 14 : 24),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.showName
                      ? _selectedCountry['name']
                      : _selectedCountry['dial_code'],
                  style: TextStyle(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down,
              ),
            ],
          ),
        ),
      );
    });
  }
}
