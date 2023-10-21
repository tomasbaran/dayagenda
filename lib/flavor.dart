import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dayagenda/models/enums.dart';

class Flavor {
  static FlavorType? selectedFlavor;

  static Future<FlavorType> selected() async {
    // cache performance enhancement
    // if (_selected != null) {
    //   return _selected!;
    // }

    final packageInfo = await PackageInfo.fromPlatform();
    await dotenv.load(fileName: "lib/dotenv");

    if (packageInfo.packageName == dotenv.get('PACKAGE_NAME_DEV')) {
      selectedFlavor = FlavorType.dev;
    } else if (packageInfo.packageName == dotenv.get('PACKAGE_NAME_LIVE')) {
      selectedFlavor = FlavorType.live;
      // web
    } else if (kIsWeb) {
      const environmentParameter = String.fromEnvironment('flavor');
      switch (environmentParameter) {
        case 'dev':
          selectedFlavor = FlavorType.dev;
        case 'live':
          selectedFlavor = FlavorType.live;
        default:
          throw Exception("Unknown environment $environmentParameter");
      }
    }

    return selectedFlavor!;
  }
}
