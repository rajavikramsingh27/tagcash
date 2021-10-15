import '../services/base_response.dart';
import '../utils/core/parsing.dart';

class NodeUser extends BaseResponse {
  int tagcashId; //32093
  Map avatar;
  String firstname; // "Puneet"
  String lastname; //: "Sethi"
  String nickname;
  String nodeId;
  String userGender;
  String profileBio;
  String userId;
  String chargePerMinAmount;
  String chargeCurrencyId;
  String chargePerSession;
  String minutePerSession;

  NodeUser.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.tagcashId = Parsing.intFrom(json['user_id']);
    this.nodeId = Parsing.stringFrom(json['_id']);
    this.firstname = Parsing.stringFrom(json['user_firstname']);
    this.lastname = Parsing.stringFrom(json['user_lastname']);
    this.nickname = Parsing.stringFrom(json['user_nickname']);
    this.avatar = Parsing.mapFrom(json['avatar']);
    this.userGender = Parsing.stringFrom(json['user_gender']);
    this.profileBio = Parsing.stringFrom(json['profile_bio']);
    this.userId = Parsing.stringFrom(json['user_id']);
    this.chargePerMinAmount = Parsing.stringFrom(json['charge_per_min']);
    this.chargeCurrencyId = Parsing.stringFrom(json['charge_currency_id']);
    this.chargePerSession = Parsing.stringFrom(json['charge_per_session']);
    this.minutePerSession = Parsing.stringFrom(json['min_per_session']);
  }
}
