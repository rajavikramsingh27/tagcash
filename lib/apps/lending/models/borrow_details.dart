class BorrowDetails {
  var loanedAmount;
  var amountPending;
  var amountPendingWithInterest;
  var amountPaid;
  List<Installment> installments;

  BorrowDetails(
      {this.loanedAmount,
      this.amountPending,
      this.amountPendingWithInterest,
      this.amountPaid,
      this.installments});

  BorrowDetails.fromJson(dynamic json) {
    if (json['loan_details'] != null) {
      loanedAmount = json['loan_details']['loaned_amount'];
      amountPending = double.parse(
          (json['loan_details']['amount_pending']).toStringAsFixed(2));
      amountPendingWithInterest = double.parse((json['loan_details']
              ['amount_pending_with_interest'])
          .toStringAsFixed(2));
      amountPaid = json['loan_details']['amount_paid'];
    } else {
      loanedAmount = 0;
      amountPending = 0;
      amountPendingWithInterest = 0;
      amountPaid = 0;
    }
    if (json['installments'] != null) {
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
  var transactionStatus;
  var transferType;

  Installment(
      {this.transferDate,
      this.amountTransfered,
      this.transactionStatus,
      this.transferType});

  Installment.fromJson(Map<String, dynamic> json) {
    transferDate = json['transfer_date'];
    amountTransfered = json['amount_transfered'];
    transactionStatus = json['transaction_status'];
    transferType = json['transfer_type'];
  }
}
