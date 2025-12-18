import 'package:flutter/material.dart';

String formatCurrency(num value, {String symbol = 'Rp. '}) {
  final s = value.toInt().toString();
  return symbol + s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}

class CurrencyText extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String symbol;
  final TextAlign? textAlign;

  const CurrencyText({Key? key, required this.value, this.style, this.symbol = 'Rp. ', this.textAlign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCurrency(value, symbol: symbol),
      style: style,
      textAlign: textAlign,
    );
  }
}
