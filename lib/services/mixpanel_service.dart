import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static Mixpanel? mixpanel;

  static Future<void> initMixpanel() async {
    try {
      mixpanel = await Mixpanel.init(dotenv.get('MIXPANEL_TOKEN'), trackAutomaticEvents: true);
    } catch (e) {
      log("Mixpanel initialization error: $e");
    }
  }
}
