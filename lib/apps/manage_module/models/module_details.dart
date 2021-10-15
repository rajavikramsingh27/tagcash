class ModuleDetails {
  int id;
  String moduleName;
  String moduleType;
  String categoryId;
  String shortDescription;
  String icon;
  var geoCountryId;
  var geoLatitude;
  var geoLongitude;
  var geoRadius;
  int accessVisible;
  String accessModule;
  String accessModuleRole;
  String pricing;
  String subscriptionAmount;
  int appPublished;
  String stages;
  String gitUrl;
  String betaModuleUrl;
  String liveModuleUrl;

  ModuleDetails(
      {this.id,
      this.moduleName,
      this.moduleType,
      this.categoryId,
      this.shortDescription,
      this.icon,
      this.geoCountryId,
      this.geoLatitude,
      this.geoLongitude,
      this.geoRadius,
      this.accessVisible,
      this.accessModule,
      this.accessModuleRole,
      this.pricing,
      this.subscriptionAmount,
      this.appPublished,
      this.stages,
      this.gitUrl,
      this.betaModuleUrl,
      this.liveModuleUrl});

  ModuleDetails.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    moduleName = json['module_name'].toString();
    moduleType = json['module_type'];
    categoryId = json['category_id'].toString();
    shortDescription = json['short_description'].toString();
    icon = json['icon'] ?? '';
    // geoCountryId = json['geo_country_id'];
    // geoLatitude = json['geo_latitude'];
    // geoLongitude = json['geo_Longitude'];
    // geoRadius = json['geo_radius'];
    accessVisible = int.parse(json['access_visible']) ?? 0;
    accessModule = json['access_module'];
    accessModuleRole = json['access_module_role'] ?? '0';

    pricing = json['pricing'];
    subscriptionAmount = json['subscription_amount'].toString();

    appPublished = int.parse(json['app_published']);
    stages = json['stages'];
    gitUrl = json['git_url'] ?? '';
    betaModuleUrl = json['beta_module_url'];
    liveModuleUrl = json['live_module_url'];
  }
}
