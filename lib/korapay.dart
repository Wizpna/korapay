library korapay;

import 'package:flutter/material.dart';
import 'package:korapay/src/korapay.dart';
import 'package:uuid/uuid.dart';

/// Main class, use the [now] method and provide arguments like;
/// secret [secretKey], [reference], [currency], [name], [email], [email], [paymentChannel] and [amount].
class PayWithKora {
  String generateUuidV4() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<dynamic> now({
    /// Context provided from current view
    required BuildContext context,

    /// Secret key is provided from your KoraPay account
    required String secretKey,

    /// Email of the customer
    required String customerEmail,

    /// Name of the customer
    required String customerName,

    /// Alpha numeric and/or number ID to a transaction
    required String reference,

    /// callBack URL to handle redirection
    required String callbackUrl,

    /// Currency of the transaction
    required String currency,

    /// reason for payment
    String? customerNarration,

    /// Amount you want to charge the user
    required double amount,

    /// What happens next after transaction is completed
    required Function() transactionCompleted,

    /// What happens next after transaction is not completed
    required Function() transactionNotCompleted,

    /// Payment Channels you want to make available to the user
    required Object paymentChannel,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KoraPay(
          secretKey: secretKey,
          email: customerEmail,
          reference: reference,
          currency: currency,
          amount: amount,
          paymentChannel: paymentChannel,
          transactionCompleted: transactionCompleted,
          transactionNotCompleted: transactionNotCompleted,
          callbackUrl: callbackUrl,
          name: customerName,
          narration: customerNarration,
        ),
      ),
    );
  }
}
