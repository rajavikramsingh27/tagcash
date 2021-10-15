class ModuleItem {
  int id;
  String moduleCode;
  String shortTitle;
  String longTitle;
  String icon;
  String merchantOrUser;
  String status;
  bool favorite;

  ModuleItem(
      {this.id,
      this.moduleCode,
      this.shortTitle,
      this.longTitle,
      this.icon,
      this.merchantOrUser,
      this.status,
      this.favorite});

  ModuleItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moduleCode = json['module_code'];
    shortTitle = json['short_title'];
    longTitle = json['long_title'];
    icon = json['icon'];
    merchantOrUser = json['merchant_or_user'];
    status = json['status'];
    favorite = json['favorite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['module_code'] = this.moduleCode;
    data['short_title'] = this.shortTitle;
    data['long_title'] = this.longTitle;
    data['icon'] = this.icon;
    data['merchant_or_user'] = this.merchantOrUser;
    data['status'] = this.status;
    data['favorite'] = this.favorite;
    return data;
  }
}
