import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main(List<String> args) async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _razorpay = Razorpay();
  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              String razorpayKeyId = dotenv.get("RAZORPAY_KEY_ID");
              final dio = Dio();
              final response = await dio.post(
                  "http://192.168.1.3:5000/create-order",
                  data: {"amount": 1});
              if (response.statusCode == 200) {
                log("data:-- ${response.data["data"]}");
                final data = response.data['data'];
                var options = {
                  'key': razorpayKeyId,
                  'amount': data['amount_due'],
                  'name': 'HRMS',
                  'order_id': data['id'],
                  'description': 'Payment',
                  'timeout': 360,
                  'prefill': {
                    'contact': '9924868060',
                    'email': 'monparasmit1@gmail.com'
                  }
                };
                _razorpay.open(options);
              }
            } on DioException catch (e) {
              log("Error:-- $e");
            }
          },
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}

void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    final dio = Dio();
    final result = await dio.post("http://192.168.1.3:5000/payment", data: {
      "razorpay_payment_id": response.paymentId,
      "razorpay_order_id": response.orderId,
      "razorpay_signature": response.signature,
    });
    if (result.statusCode == 200) {
      log("data:-- ${result.data}");
    }
  } on DioException catch (e) {
    log("Error:-- $e");
  }
}

void _handlePaymentError(PaymentFailureResponse response) {}

void _handleExternalWallet(ExternalWalletResponse response) {}
