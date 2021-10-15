class RedEnvelopeCreated {
  int id;
  int envelopeCreatedId; 
  int envelopeCreatedType;
  String title;
  int randomize;
  int envelopeTotalAmount; 
  int envelopeWalletType;
  int enveloperReceipientType;
  int envelopeReceipientRole;
  int envelopeTotalUsers;
  DateTime createdAt;
  int envelopeStatus;
  String currencyCode;
  

  RedEnvelopeCreated({
  this.id,
  this.envelopeCreatedId, 
  this.envelopeCreatedType,
  this.title,
  this.randomize,
  this.envelopeTotalAmount, 
  this.envelopeWalletType,
  this.enveloperReceipientType,
  this.envelopeReceipientRole,
  this.envelopeTotalUsers,
  this.createdAt,
  this.envelopeStatus,
  this.currencyCode
  });

  RedEnvelopeCreated.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    envelopeCreatedId = json['envelope_created_id'];
    envelopeCreatedType = json['envelope_created_type'];
    title = json['title'];
    randomize = json['randomize'];
    envelopeTotalAmount = json['envelope_total_amount'];
    envelopeWalletType = json['envelope_wallet_type'];
    enveloperReceipientType = json['envelope_receipient_type'];
    envelopeReceipientRole = json['envelope_receipient_role'];
    envelopeTotalUsers = json['envelope_total_users'];
    createdAt = DateTime.parse(json['created_at']);
    envelopeStatus = json['envelope_status'];
    currencyCode = json['currency_code'];

  }
}