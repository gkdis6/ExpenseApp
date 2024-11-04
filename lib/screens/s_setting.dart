import 'package:financial_app/data/preference/prefs.dart';
import 'package:financial_app/screens/w_big_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import 'd_number.dart';
import 'w_switch_menu.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: '설정'.text.make(),
      ),
      body: ListView(
        children: [
          //switch
          Obx(
            () => SwitchMenu(
              '푸시 설정',
              Prefs.isPushOnRx.get(),
              onChanged: (bool isOn) {
                Prefs.isPushOnRx.set(isOn);
              },
            ),
          ),
          //slider
          Obx(
            () => Slider(
              value: Prefs.sliderPosition.get(),
              onChanged: (double value) {
                Prefs.sliderPosition.set(value);
                // Prefs.sliderPosition(value); 동일
              },
            ),
          ),
          //date time
          Obx(
            () => BigButton(
              '저장된 숫자 ${Prefs.number.get()}',
              onTap: () async {
                final number = await NumberDialog().show();
                if (number != null) {
                  Prefs.number.set(number);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
