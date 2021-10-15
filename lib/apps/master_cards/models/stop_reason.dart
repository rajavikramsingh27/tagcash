class StopReason {
  String reasonId;
  String reason;

  StopReason({this.reasonId, this.reason});

  StopReason.fromJson(Map<String, dynamic> json) {
    reasonId = json['reason_id'];
    reason = json['reason'];
  }
}
