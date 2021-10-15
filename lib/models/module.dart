import 'dart:convert';

class Module {
  int id;
  String name;
  String moduleCode;
  String moduleType;
  String icon;
  String urlBeta;
  String urlLive;
  bool favorite;
  bool personal;
  String stages;
  String shortDescription;
  String pricing;
  String subscriptionType;
  String walletId;
  String amount;
  TemplateDetails templateDetails;
  String availableSale;
  String saleAmount;
  String saleWalletId;

  Module({
    this.id,
    this.name,
    this.moduleCode,
    this.moduleType,
    this.icon,
    this.urlBeta,
    this.urlLive,
    this.favorite,
    this.personal,
    this.stages,
    this.shortDescription,
    this.pricing,
    this.subscriptionType,
    this.walletId,
    this.amount,
    this.templateDetails,
    this.availableSale,
    this.saleAmount,
    this.saleWalletId,
  });

  Module.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    name = json['module_name'];
    moduleCode = json['module_code'] ?? '';
    moduleType = json['module_type'];
    icon = json['icon'] ?? '';
    urlBeta = json['beta_module_url'] ?? '';
    urlLive = json['live_module_url'] ?? '';
    favorite = json['favorite'] ?? false;
    personal = json['personal'] ?? false;
    stages = json['stages'];
    shortDescription = json['short_description'];
    pricing = json['pricing'];
    subscriptionType = json['subscription_type'] ?? '';
    walletId = json['wallet_id'] ?? '';
    amount = json['amount'] ?? '';

    if (json['module_type'] == 'template' && json['template_details'] != null) {
      templateDetails =
          TemplateDetails.fromJson(jsonDecode(json['template_details']));
    } else {
      templateDetails = null;
    }

    availableSale = json['available_sale'] ?? '';
    saleAmount = json['sale_amount'] ?? '';
    saleWalletId = json['sale_wallet_id'] ?? '';
  }
}

class TemplateDetails {
  String templateCode;
  List<String> templateData;

  TemplateDetails({this.templateCode, this.templateData});

  TemplateDetails.fromJson(Map<String, dynamic> json) {
    templateCode = json['template_code'];
    templateData = json['template_data'].cast<String>();
  }
}
