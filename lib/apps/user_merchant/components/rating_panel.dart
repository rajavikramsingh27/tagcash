import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';

class RatingPanel extends StatefulWidget {
  final String id;
  final String type;
  final Function(String) onRatingChanges;

  const RatingPanel({
    Key key,
    this.id,
    this.type,
    this.onRatingChanges,
  }) : super(key: key);

  @override
  _RatingPanelState createState() => _RatingPanelState();
}

class _RatingPanelState extends State<RatingPanel> {
  bool isLoading = false;
  double _currentSliderValue = 0;

  updateRating() async {
    print("rateHandler");
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> apiBodyObj = {};
    apiBodyObj['rating'] = _currentSliderValue.round().toString();
    apiBodyObj['to_id'] = widget.id;
    apiBodyObj['to_type'] = widget.type;

    Map<String, dynamic> response =
        await NetworkHelper.request('ratings/addratings', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      var responseValue = response['result'];
      widget.onRatingChanges(responseValue.round().toString());
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  'RATE',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 10),
                Slider(
                  value: _currentSliderValue,
                  min: -10,
                  max: 10,
                  divisions: 10,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => updateRating(),
                  child: Text("RATE"),
                )
              ],
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
