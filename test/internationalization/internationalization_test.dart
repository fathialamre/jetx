import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import '../navigation/utils/wrapper.dart';

void main() {
  testWidgets("Jet.defaultDialog smoke test", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pumpAndSettle();

    expect('covid'.tr, 'Corona Virus');
    expect('total_confirmed'.tr, 'Total Confirmed');
    expect('total_deaths'.tr, 'Total Deaths');

    Jet.updateLocale(const Locale('pt', 'BR'));

    await tester.pumpAndSettle();

    expect('covid'.tr, 'Corona Vírus');
    expect('total_confirmed'.tr, 'Total confirmado');
    expect('total_deaths'.tr, 'Total de mortes');

    Jet.updateLocale(const Locale('en', 'EN'));

    await tester.pumpAndSettle();

    expect('covid'.tr, 'Corona Virus');
    expect('total_confirmed'.tr, 'Total Confirmed');
    expect('total_deaths'.tr, 'Total Deaths');
  });
}
