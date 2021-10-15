class MerchatExtrasStatus {
  String text,verificationType,status,hashProof;

  MerchatExtrasStatus(
      {this.text,
      this.verificationType,
      this.status,
      this.hashProof,
     
    });

  MerchatExtrasStatus.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    verificationType = json['verification_type'];
    status = json['status'];
    hashProof = json['hash_proof'];
  }
   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['verification_type'] = this.verificationType;
    data['status'] = this.status;
    data['hash_proof'] = this.hashProof;
    return data;
  }
  
}