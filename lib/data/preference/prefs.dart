import '../theme/custom_theme.dart';
import 'item/nullable_preference_item.dart';
import 'item/preference_item.dart';
import 'item/rx_preference_item.dart';

class Prefs {
  static final appTheme = NullablePreferenceItem<CustomTheme>('appTheme');
  static final isPushOn = PreferenceItem<bool>('isPushOn', false);
  static final isPushOnRx = RxPreferenceItem<bool, RxBool>('isPushOn', false);
  static final sliderPosition =
      RxPreferenceItem<double, RxDouble>('sliderPosition', 0.0);
  // static final birthday = RxnPreferenceItem<DateTime, Rxn<DateTime>>('birthday', null);
  static final number = RxPreferenceItem<int, RxInt>('number', 0);
}
