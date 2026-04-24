// lib/widgets/price_tag.dart

import 'package:flutter/material.dart';

enum PriceTagSize { small, medium, large }

class PriceTag extends StatelessWidget {
  final double price;
  final PriceTagSize size;
  final Color? color;
  final String currencySymbol;

  const PriceTag({
    super.key,
    required this.price,
    this.size = PriceTagSize.medium,
    this.color,
    this.currencySymbol = '৳',
  });

  double get _fontSize {
    switch (size) {
      case PriceTagSize.small:
        return 13;
      case PriceTagSize.medium:
        return 16;
      case PriceTagSize.large:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.deepPurple;

    return RichText(
      textScaler: MediaQuery.of(context).textScaler, // ✅ better accessibility
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Roboto',
        ),
        children: [
          TextSpan(
            text: '$currencySymbol ',
            style: TextStyle(
              fontSize: (_fontSize - 2).clamp(10, 100),
              color: effectiveColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: price.toStringAsFixed(0),
            style: TextStyle(
              fontSize: _fontSize,
              color: effectiveColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
