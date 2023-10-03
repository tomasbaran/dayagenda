import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:today/models/enums.dart';

class Flavor {
  static FlavorType? _selected;

  static Future<FlavorType> selected() async {
    // cache performance enhancement
    // if (_selected != null) {
    //   return _selected!;
    // }

    final packageInfo = await PackageInfo.fromPlatform();
    await dotenv.load(fileName: "lib/.env");

    if (packageInfo.packageName == dotenv.get('PACKAGE_NAME_DEV')) {
      _selected = FlavorType.dev;
    } else if (packageInfo.packageName == dotenv.get('PACKAGE_NAME_LIVE')) {
      _selected = FlavorType.live;
    }

    return _selected!;
  }
}
