import 'dart:developer';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static Mixpanel? mixpanel;

  static Future<void> initMixpanel(String mixpanelToken) async {
    try {
      mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
    } catch (e) {
      log("Mixpanel initialization error: $e");
    }
  }
}
