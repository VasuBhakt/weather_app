import 'dart:ui';

import 'package:flutter/material.dart';

class AdditionalInfoCard extends StatelessWidget {
  final String attribute;
  final double value;
  final Icon icon;
  final String additional;

  const AdditionalInfoCard({
    super.key,
    required this.attribute,
    required this.value,
    required this.icon,
    required this.additional,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  attribute,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                icon,
                const SizedBox(height: 16),
                Text("${value.toStringAsFixed(2)} $additional", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
