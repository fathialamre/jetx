import 'package:jetx/jetx.dart';

class ProductDetailsController extends JetxController {
  final String productId;

  ProductDetailsController(this.productId);
  @override
  void onInit() {
    super.onInit();
    Jet.log('ProductDetailsController created with id: $productId');
  }

  @override
  void onClose() {
    Jet.log('ProductDetailsController close with id: $productId');

    super.onClose();
  }
}
