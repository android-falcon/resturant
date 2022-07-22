import 'package:flutter/material.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';

class PayScreen extends StatefulWidget {
  final CartModel cart;

  const PayScreen({Key? key, required this.cart}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Text('ana'),
      ),
    );
  }
}
