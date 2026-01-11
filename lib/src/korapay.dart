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
  final Object paymentChannel;
  final VoidCallback transactionCompleted;
  final VoidCallback transactionNotCompleted;

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
    required this.name,
    required this.paymentChannel,
  });

  @override
  State<KoraPay> createState() => _KoraPayState();
}

class _KoraPayState extends State<KoraPay> {
  late final Future<KoraPayResponse> _paymentFuture;

  bool _transactionHandled = false;

  final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers = {
    Factory(() => EagerGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    _paymentFuture = _makePaymentRequest();
  }

  // ===================== PAYMENT INITIALIZATION =====================

  Future<KoraPayResponse> _makePaymentRequest() async {
    final response = await http.post(
      Uri.parse('https://api.korapay.com/merchant/api/v1/charges/initialize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.secretKey}',
      },
      body: jsonEncode({
        "customer": {
          "name": widget.name,
          "email": widget.email,
        },
        "amount": widget.amount.toString(),
        "reference": widget.reference,
        "currency": widget.currency,
        "redirect_url": widget.callbackUrl,
        "channels": widget.paymentChannel,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return KoraPayResponse.fromJson(jsonDecode(response.body));
  }

  // ===================== TRANSACTION VERIFICATION =====================

  Future<void> _checkTransactionStatus(String ref) async {
    if (_transactionHandled) return;
    _transactionHandled = true;

    try {
      final response = await http.get(
        Uri.parse('https://api.korapay.com/merchant/api/v1/charges/$ref'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.secretKey}',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final status = decoded["data"]["status"];

        if (status == "success") {
          widget.transactionCompleted();
        } else {
          widget.transactionNotCompleted();
        }
      } else {
        widget.transactionNotCompleted();
      }
    } catch (_) {
      _transactionHandled = false;
      widget.transactionNotCompleted();
    }
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FutureBuilder<KoraPayResponse>(
        future: _paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          if (snapshot.hasError || snapshot.data?.status != true) {
            return Scaffold(
              body: Center(
                child: Text(snapshot.error?.toString() ?? "Payment failed"),
              ),
            );
          }

          final data = snapshot.data!.data!;
          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setUserAgent("Flutter;WebView")
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) {
                  if (request.url.startsWith(widget.callbackUrl)) {
                    _checkTransactionStatus(data.reference!);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(data.checkoutUrl!));

          return Scaffold(
            appBar: AppBar(
              title: const Text("Kora Pay"),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  await _checkTransactionStatus(data.reference!);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: WebViewWidget(
              controller: controller,
              gestureRecognizers: _gestureRecognizers,
            ),
          );
        },
      ),
    );
  }
}

// ===================== MODELS =====================

class KoraPayResponse {
  final bool? status;
  final String? message;
  final Data? data;

  const KoraPayResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory KoraPayResponse.fromJson(Map<String, dynamic> json) {
    return KoraPayResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] == null ? null : Data.fromJson(json['data']),
    );
  }
}

class Data {
  final String? reference;
  final String? checkoutUrl;

  Data({this.reference, this.checkoutUrl});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      reference: json['reference'],
      checkoutUrl: json['checkout_url'],
    );
  }
}
