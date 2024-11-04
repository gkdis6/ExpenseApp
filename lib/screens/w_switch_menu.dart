import 'package:financial_app/screens/w_empty_expanded.dart';
import 'package:financial_app/screens/w_os_switch.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class SwitchMenu extends StatelessWidget {
  final String title;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const SwitchMenu(this.title, this.isOn, {super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title.text.bold.make(),
        emptyExpanded,
        OsSwitch(value: isOn, onChanged: onChanged)
      ],
    ).p20();
  }
}
