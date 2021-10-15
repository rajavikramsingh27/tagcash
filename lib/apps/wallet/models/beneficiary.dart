class Beneficiary {
  int id;
  String beneficiaryName;
  int bankAccountNumber;
  int incomingLimit;
  int mobileCountryCode;
  int mobileNumber;
  String bankName;
  int bankCode;
  String beneficiaryAddLine1;
  String beneficiaryAddLine2;
  String beneficiaryCity;
  String beneficiaryProvince;
  String beneficiaryZipCode;
  int beneficiaryCountry;
  String status;
  int coolingPeriodAmount;
  int coolingPeriodInHours;

  Beneficiary(
      {this.id,
      this.beneficiaryName,
      this.bankAccountNumber,
      this.incomingLimit,
      this.mobileCountryCode,
      this.mobileNumber,
      this.bankName,
      this.bankCode,
      this.beneficiaryAddLine1,
      this.beneficiaryAddLine2,
      this.beneficiaryCity,
      this.beneficiaryProvince,
      this.beneficiaryZipCode,
      this.beneficiaryCountry,
      this.status,
      this.coolingPeriodAmount,
      this.coolingPeriodInHours});

  Beneficiary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    beneficiaryName = json['beneficiary_name'];
    bankAccountNumber = json['bank_account_number'];
    incomingLimit = json['incoming_limit'];
    mobileCountryCode = json['mobile_country_code'];
    mobileNumber = json['mobile_number'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    beneficiaryAddLine1 = json['beneficiary_add_line1'];
    beneficiaryAddLine2 = json['beneficiary_add_line2'];
    beneficiaryCity = json['beneficiary_city'];
    beneficiaryProvince = json['beneficiary_province'];
    beneficiaryZipCode = json['beneficiary_zipCode'];
    beneficiaryCountry = json['beneficiary_country'];
    status = json['status'];
    coolingPeriodAmount = json['cooling_period_amount'];
    coolingPeriodInHours = json['cooling_period_in_hours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['beneficiary_name'] = this.beneficiaryName;
    data['bank_account_number'] = this.bankAccountNumber;
    data['incoming_limit'] = this.incomingLimit;
    data['mobile_country_code'] = this.mobileCountryCode;
    data['mobile_number'] = this.mobileNumber;
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    data['beneficiary_add_line1'] = this.beneficiaryAddLine1;
    data['beneficiary_add_line2'] = this.beneficiaryAddLine2;
    data['beneficiary_city'] = this.beneficiaryCity;
    data['beneficiary_province'] = this.beneficiaryProvince;
    data['beneficiary_zipCode'] = this.beneficiaryZipCode;
    data['beneficiary_country'] = this.beneficiaryCountry;
    data['status'] = this.status;
    data['cooling_period_amount'] = this.coolingPeriodAmount;
    data['cooling_period_in_hours'] = this.coolingPeriodInHours;
    return data;
  }
}
