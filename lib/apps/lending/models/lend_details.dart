class LendDetails {
  var loanedAmount;
  var amountPending;
  var amountReceived;
  List<Installment> installments;

  LendDetails(
      {this.loanedAmount,
      this.amountPending,
      this.amountReceived,
      this.installments});

  LendDetails.fromJson(dynamic json) {
    if (json['loan_status'] != null) {
      loanedAmount = json['loan_status']['loaned_amount'];
      amountPending = double.parse(
          (json['loan_status']['amount_pending']).toStringAsFixed(2));
      amountReceived = json['loan_status']['amount_received'];
    } else {
      loanedAmount = 0;
      amountPending = 0;
      amountReceived = 0;
    }
    if (json['installments'] != null) {
      print(json['installments'].toString());
      var list = json['installments'] as List;
      installments = list.map((i) => Installment.fromJson(i)).toList();
      print("Installments");
      for (var i = 0; i < installments.length; i++) {
        print(installments[i].amountTransfered.toString());
      }
    } else {
      installments = [];
    }
  }
}

class Installment {
  String transferDate;
  var amountTransfered;
  var daysDiff;
  var transactionId;
  var transactionStatus;
  var transferType;

  Installment(
      {this.transferDate,
      this.amountTransfered,
      this.daysDiff,
      this.transactionId,
      this.transactionStatus,
      this.transferType});

  Installment.fromJson(Map<String, dynamic> json) {
    transferDate = json['transfer_date'];
    amountTransfered = json['amount_transfered'];
    daysDiff = json['days_diff'];
    transactionId = json['transaction_id'];
    transactionStatus = json['transaction_status'];
    transferType = json['transfer_type'];
  }
}
