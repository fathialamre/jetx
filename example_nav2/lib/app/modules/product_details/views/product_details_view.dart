import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../controllers/product_details_controller.dart';

class ProductDetailsView extends JetWidget<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ProductDetailsView is working',
              style: TextStyle(fontSize: 20),
            ),
            Text('ProductId: ${controller.productId}')
          ],
        ),
      ),
    );
  }
}
