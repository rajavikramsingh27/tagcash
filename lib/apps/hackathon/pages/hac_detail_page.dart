import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/hackathon/edit_hackathon_screen.dart';
import 'package:tagcash/apps/hackathon/models/admin_detail.dart';
import 'package:tagcash/apps/hackathon/models/hackathon_detail.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/constants.dart';
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'package:tagcash/services/networking.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class HacDetailPage extends StatefulWidget {
  final String hackathonId;
  final String hackathonStatus;

  final bool ownerStatus;

  const HacDetailPage(
      {Key key, this.hackathonId, this.ownerStatus, this.hackathonStatus})
      : super(key: key);

  @override
  _HacDetailPageState createState() => _HacDetailPageState();
}

class _HacDetailPageState extends State<HacDetailPage> {
  Future<HackathonDetail> hackathonDetail;
  bool isLoading = false;

  bool editableUser = false;
  bool sponserUser = false;

  @override
  void initState() {
    super.initState();

    if (widget.ownerStatus) {
      editableUser = true;
    }

    hackathonDetail = hackathonDetailLoad();
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

      getData.forEach((AdminDetail adminDetail) {
        if (adminDetail.userDetail.id == activeId &&
            adminDetail.roleName == 'ADMIN') {
          setState(() {
            editableUser = true;
          });
        }
        if (adminDetail.userDetail.id == activeId &&
            adminDetail.roleName == 'SPONSOR') {
          setState(() {
            sponserUser = true;
          });
        }
      });
    }
  }

  Future<HackathonDetail> hackathonDetailLoad() async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.hackathonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/HackathonDetail', apiBodyObj);

    dynamic responseData = response['result'];

    return HackathonDetail.fromJson(responseData);
  }

  String registrationDate(HackathonDetail detail) {
    String regDate = DateFormat('MMM dd')
        .format(DateTime.parse(detail.registrationOpenFrom));
    return 'Registration open $regDate';
  }

  String hackathonDateFormate(
      String startDate, String endDate, String duration) {
    DateTime sDate = DateTime.parse(startDate);
    DateTime eDate = DateTime.parse(endDate);
    final DateFormat formatter = DateFormat('yyyy MMM dd hha');
    final String formattedDate = formatter.format(sDate);
    final String formattedDate1 = formatter.format(eDate);
    return formattedDate +
        ' to ' +
        formattedDate1 +
        ' - ' +
        '($duration hours)';
  }

  MaterialColor statusColor(String status) {
    MaterialColor statColor = Colors.grey;

    if (status == 'OPEN') {
      statColor = Colors.green;
    } else if (status == 'INVITE ONLY') {
      statColor = Colors.red;
    }

    return statColor;
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void removeHackathon() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.hackathonId;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/RemoveHackathon', apiBodyObj);

    if (response['status'] == 'success') {
      Fluttertoast.showToast(
          msg: "Hackathon removed successfully",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context, true);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void editHackathon(HackathonDetail detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHackathonScreen(hackathonDetail: detail),
      ),
    ).whenComplete(() {
      hackathonDetail = hackathonDetailLoad();
      setState(() {});
    });
  }

  void sponserPrizeAddClicked() {
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
                  child: SponserPrizeAdd(hackathonId: widget.hackathonId)),
            ),
          );
        }).then((value) => value != null ? loadHackathonData(value) : null);
  }

  void loadHackathonData(SponsorPrize sponsorPrize) async {
    hackathonDetail.then((value) => value.sponsorPrize.add(sponsorPrize));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: hackathonDetail,
              builder: (context, AsyncSnapshot<HackathonDetail> snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                if (snapshot.hasData) {
                  HackathonDetail detail = snapshot.data;

                  return ListView(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    children: [
                      Text(
                        detail.hackathonName,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          widget.hackathonStatus,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor(widget.hackathonStatus)),
                        ),
                      ),
                      Text(hackathonDateFormate(
                          detail.startTime, detail.endTime, detail.duration)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          registrationDate(detail),
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Text(detail.hackathonDescription),
                      SizedBox(height: 10),
                      detail.hackathonUrl.isNotEmpty
                          ? ListTile(
                              title: Text(detail.hackathonUrl),
                              onTap: () =>
                                  _launchInBrowser(detail.hackathonUrl),
                            )
                          : SizedBox(),
                      SizedBox(height: 20),
                      Text(
                        'Prizes',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.only(left: kDefaultPadding),
                          itemCount: detail.prize.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              contentPadding: EdgeInsets.all(0),
                              visualDensity: VisualDensity(vertical: -2),
                              leading: Icon(
                                Icons.emoji_events_outlined,
                                size: 34,
                              ),
                              title: Text(detail.prize[index]),
                            );
                          }),
                      SizedBox(height: 20),
                      Text(
                        'Sponsor Prizes',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.only(left: kDefaultPadding),
                          itemCount: detail.sponsorPrize.length,
                          itemBuilder: (BuildContext context, int index) {
                            SponsorPrize sponsorPrize =
                                detail.sponsorPrize[index];
                            return ListTile(
                              contentPadding: EdgeInsets.all(0),
                              visualDensity: VisualDensity(vertical: -2),
                              leading: Icon(
                                Icons.redeem,
                                size: 30,
                              ),
                              title: Text(sponsorPrize.prize),
                              subtitle: Text(
                                sponsorPrize.sponsorName,
                              ),
                            );
                          }),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          if (widget.ownerStatus) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => removeHackathon(),
                                child: Text('DELETE'),
                              ),
                            ),
                          ],
                          if (editableUser) ...[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ElevatedButton(
                                  onPressed: () => editHackathon(detail),
                                  child: Text('EDIT'),
                                ),
                              ),
                            ),
                          ],
                          if (sponserUser) ...[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: ElevatedButton(
                                  onPressed: () => sponserPrizeAddClicked(),
                                  child: Text('ADD PRIZE'),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(child: Loading());
                }
              }),
          isLoading ? Center(child: Loading()) : SizedBox(),
        ],
      ),
    );
  }
}

class SponserPrizeAdd extends StatefulWidget {
  const SponserPrizeAdd({
    Key key,
    this.hackathonId,
  }) : super(key: key);

  final String hackathonId;

  @override
  _SponserPrizeAddState createState() => _SponserPrizeAddState();
}

class _SponserPrizeAddState extends State<SponserPrizeAdd> {
  TextEditingController _prizeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _prizeController.dispose();
    super.dispose();
  }

  addsponserPrize() async {
    setState(() {
      isLoading = true;
    });

    UserData userData =
        Provider.of<UserProvider>(context, listen: false).userData;
    SponsorPrize sponsorPrize = SponsorPrize(
        prize: _prizeController.text,
        sponsorId: userData.id.toString(),
        sponsorName: '${userData.firstName} ${userData.lastName}');

    Map<String, String> apiBodyObj = {};
    apiBodyObj['_id'] = widget.hackathonId;
    apiBodyObj['prize'] = _prizeController.text;

    Map<String, dynamic> response = await NetworkHelper.request(
        'HackathonMini/AddHackathonPrize', apiBodyObj);

    setState(() {
      isLoading = false;
    });
    if (response['status'] == 'success') {
      Navigator.pop(context, sponsorPrize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Text(
              'Add Sponsor Prize',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            TextFormField(
              controller: _prizeController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Prize',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                child: Text('ADD'),
                onPressed: () {
                  addsponserPrize();
                })
          ],
        ),
        isLoading ? Center(child: Loading()) : SizedBox(),
      ],
    );
  }
}
