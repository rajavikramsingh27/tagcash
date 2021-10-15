import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:universal_platform/universal_platform.dart';

class ExportStatement extends StatefulWidget {
  final String walletId;
  const ExportStatement({
    Key key,
    this.walletId,
  }) : super(key: key);

  @override
  _ExportStatementState createState() => _ExportStatementState();
}

class _ExportStatementState extends State<ExportStatement> {
  bool isLoading = false;

  void todayExport() {
    exportReportClickHandle(DateTime.now(), DateTime.now());
  }

  void yesterdayExport() {
    DateTime fromDate = Jiffy().startOf(Units.DAY).subtract(days: 1).utc();
    DateTime toDate = Jiffy().endOf(Units.DAY).subtract(days: 1).utc();
    exportReportClickHandle(fromDate, toDate);
  }

  void lastSevenExport() {
    DateTime fromDate = Jiffy().startOf(Units.WEEK).utc();
    DateTime toDate = Jiffy().endOf(Units.WEEK).utc();
    exportReportClickHandle(fromDate, toDate);
  }

  void lastThertyExport() {
    DateTime fromDate = Jiffy().startOf(Units.DAY).subtract(days: 30).utc();
    DateTime toDate = Jiffy().endOf(Units.DAY).utc();
    exportReportClickHandle(fromDate, toDate);
  }

  void lastMonthExport() {
    var _lastMonth = Jiffy().subtract(months: 1);
    DateTime fromDate = Jiffy(_lastMonth).startOf(Units.MONTH).utc();
    DateTime toDate = Jiffy(_lastMonth).endOf(Units.MONTH).utc();
    exportReportClickHandle(fromDate, toDate);
  }

  void thisMonthExport() {
    DateTime fromDate = Jiffy().startOf(Units.MONTH).utc();
    DateTime toDate = Jiffy().endOf(Units.MONTH).utc();
    exportReportClickHandle(fromDate, toDate);
  }

  void customRangeExport() async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    exportReportClickHandle(picked.start, picked.end);
  }

  void exportReportClickHandle(DateTime fromDate, DateTime toDate) async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['from_wallet_id'] = widget.walletId;

    apiBodyObj['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate);
    apiBodyObj['to_date'] = DateFormat('yyyy-MM-dd').format(toDate);

    // apiBodyObj['download_url'] = '1';
    apiBodyObj['download_pdf'] = '1';

    var bytes =
        await NetworkHelper.requestPdf('wallet/transactions', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    writePdfFile(bytes);
  }

  writePdfFile(var data) async {
    if (UniversalPlatform.isWeb) {
      final path = await getSavePath();
      final name = 'statement.pdf';
      final mimeType = 'application/pdf';
      final file = XFile.fromData(data, name: name, mimeType: mimeType);
      await file.saveTo(path);

      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: getTranslated(context, 'statement_saved_successfully'),
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      Directory directory;
      directory = await getTemporaryDirectory();
      final File file = File('${directory.path}/statement.pdf');
      await file.writeAsBytes(data);

      Navigator.pop(context);
      Share.shareFiles(['${directory.path}/statement.pdf'],
          text: 'Statement PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  getTranslated(context, 'download_statement'),
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.today),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      child: Text(getTranslated(context, 'today')),
                      onPressed: () => todayExport(),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      child: Text(getTranslated(context, 'yesterday')),
                      onPressed: () => yesterdayExport(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        child: Text(getTranslated(context, 'last_seven_days')),
                        onPressed: () => lastSevenExport(),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: OutlinedButton(
                        child: Text(getTranslated(context, 'last_therty_days')),
                        onPressed: () => lastThertyExport(),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.event_note),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      child: Text(getTranslated(context, 'last_month')),
                      onPressed: () => lastMonthExport(),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      child: Text(getTranslated(context, 'this_month')),
                      onPressed: () => thisMonthExport(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        child: Text(getTranslated(context, 'custom')),
                        onPressed: () => customRangeExport(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: isLoading ? Center(child: Loading()) : SizedBox(),
        )
      ],
    );
  }
}
