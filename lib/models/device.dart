class Device {
  String id;
  String appId;
  String appName;
  String mobileName;
  String uniqueId;
  String lastActive;
  String status;

  Device(
      {this.id,
      this.appId,
      this.appName,
      this.mobileName,
      this.uniqueId,
      this.lastActive,
      this.status});

  Device.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appId = json['app_id'];
    appName = json['app_name'] ?? '';
    mobileName = json['mobile_name'];
    uniqueId = json['unique_id'];
    lastActive = json['last_active'];
    status = json['status'];
  }
}
