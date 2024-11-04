import 'package:financial_app/screens/w_arrow.dart';
import 'package:financial_app/screens/w_rounded_container.dart';
import 'package:financial_app/screens/w_tap.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const BigButton(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: RoundedContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text.text.white.size(20).bold.make(),
            const Arrow(),
          ],
        ),
      ),
    );
  }
}
