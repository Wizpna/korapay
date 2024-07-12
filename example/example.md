import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:korapay/korapay.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

// This widget is the root of your application.
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Pay With Kora',
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
useMaterial3: true,
),
home: const MyHomePage(title: 'Pay With Kora'),
);
}
}

class MyHomePage extends StatefulWidget {
const MyHomePage({super.key, required this.title});

final String title;

@override
State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor: Theme.of(context).colorScheme.inversePrimary,
title: Text(widget.title),
centerTitle: true,
),
body: Center(
child: MaterialButton(
color: Theme.of(context).colorScheme.inversePrimary,
child: const Text(
"Pay with Korapay",
style: TextStyle(fontSize: 16),
),
onPressed: () {
final uniqueTransRef = PayWithKora().generateUuidV4();

            PayWithKora().now(
                context: context,
                secretKey: "sk_test_j9KBpCCF5Sz3i21YYYLswHe4DLKNLdvWZ......."
                customerEmail: "amadipromise07@gmail.com",
                reference: uniqueTransRef,
                currency: "NGN",
                amount: 20000.00,
                transactionCompleted: () {
                  print("Transaction Successful");
                },
                transactionNotCompleted: () {
                  print("Transaction Not Successful!");
                },
                paymentChannel: ['card'],
                metaData: {},
                customerName: 'Promise Amadi',
                callbackUrl: 'https://www.gmail.com');
          },
        ),
      ),
    );
}
}
