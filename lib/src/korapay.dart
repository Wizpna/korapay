import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class KoraPay extends StatefulWidget {
  final String secretKey;
  final String reference;
  final String callbackUrl;
  final String currency;
  final String email;
  final double amount;
  final String name;
  final String? narration;
  final metadata;
  final paymentChannel;
  final void Function() transactionCompleted;
  final void Function() transactionNotCompleted;

  const KoraPay({
    super.key,
    required this.secretKey,
    required this.email,
    required this.reference,
    required this.currency,
    required this.amount,
    required this.callbackUrl,
    required this.transactionCompleted,
    required this.transactionNotCompleted,
    this.metadata,
    this.narration,
    required this.name,
    this.paymentChannel,
  });

  @override
  State<KoraPay> createState() => _KoraPayState();
}

class _KoraPayState extends State<KoraPay> {
  /// Makes HTTP Request to KoraPay for access to make payment.
  Future makePaymentRequest() async {
    http.Response? response;
    final amount = widget.amount;

    try {
      /// Sending Data to KoraPay.
      response = await http.post(
        /// Url to send data to
        Uri.parse('https://api.korapay.com/merchant/api/v1/charges/initialize'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.secretKey}',
        },

        /// Data to send to the URL.
        body: jsonEncode({
          "customer": {
            "name": widget.name,
            "email": widget.email,
          },
          "amount": amount.toString(),
          "reference": widget.reference,
          "currency": widget.currency,
          "metadata": widget.metadata,
          "narration": widget.narration,
          "redirect_url": widget.callbackUrl,
          "channels": widget.paymentChannel
        }),
      );
    } on Exception catch (e) {
      /// In the event of an exception, take the user back and show a SnackBar error.
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        var snackBar =
            SnackBar(content: Text("Fatal error occurred, ${e.toString()}"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    if (response!.statusCode == 200) {
      return KoraPayResponse.fromJson(jsonDecode(response.body));
    } else {
      /// Anything else means there is an issue
      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      var snackBar = SnackBar(content: Text(response.body.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ///Display loading dialog
  displayLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(width: 20),
              Text("Please wait...",
                  style: Theme.of(context).textTheme.bodyMedium)
            ],
          ),
        );
      },
    );
  }

  /// Checks for transaction status of current transaction before view closes.
  Future checkTransactionStatus(String ref) async {
    http.Response? response;
    try {
      /// Getting data, passing [ref] as a value to the URL that is being requested.
      response = await http.get(
        Uri.parse('https://api.korapay.com/merchant/api/v1/charges/$ref'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.secretKey}',
        },
      );
    } on Exception catch (_) {
      /// In the event of an exception, take the user back and show a SnackBar error.
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        var snackBar = const SnackBar(
            content: Text("Fatal error occurred, Please check your internet"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    if (response!.statusCode == 200) {
      var decodedRespBody = jsonDecode(response.body);
      if (decodedRespBody["data"]["status"] == "success") {
        widget.transactionCompleted();
      } else {
        widget.transactionNotCompleted();
      }
    } else {
      /// Anything else means there is an issue
      widget.transactionNotCompleted();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      var snackBar = SnackBar(content: Text(response.body.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FutureBuilder(
        future: makePaymentRequest(),
        builder: (context, snapshot) {
          /// Show screen if snapshot has data and status is true.
          if (snapshot.hasData && snapshot.data!.status == true) {
            final controller = WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setUserAgent("Flutter;Webview")
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (request) async {
                    if (request.url.contains(widget.callbackUrl)) {
                      await checkTransactionStatus(
                              snapshot.data!.data!.reference.toString())
                          .then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..loadRequest(
                  Uri.parse(snapshot.data!.data!.checkoutUrl.toString()));
            return Scaffold(
              appBar: AppBar(
                title: const Text("Kora Pay"),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    displayLoader();

                    ///check transaction status before closing the view back to the previous screen
                    checkTransactionStatus(
                            snapshot.data!.data!.reference.toString())
                        .then((value) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ),
              body: WebViewWidget(
                controller: controller,
                gestureRecognizers: gestureRecognizers,
              ),
            );
          }

          if (snapshot.hasError) {
            return Material(
              child: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class KoraPayResponse {
  final bool? status;
  final String? message;
  final Data? data;

  const KoraPayResponse(
      {required this.status, required this.message, required this.data});

  factory KoraPayResponse.fromJson(Map<String, dynamic> json) {
    return KoraPayResponse(
      status: json['status'],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  String? reference;
  String? checkoutUrl;

  Data({this.reference, this.checkoutUrl});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        reference: json["reference"],
        checkoutUrl: json["checkout_url"],
      );
}
