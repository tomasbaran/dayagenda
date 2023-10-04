import 'package:flutter/material.dart';
import 'package:today/flavor.dart';
import 'package:today/models/enums.dart';
import 'package:today/widgets/my_material_app.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupGetIt();

  final appState = getIt<AppState>();
  await appState.initializeSelectedFlavor();

  runApp(const TodayApp());
}

class TodayApp extends StatelessWidget {
  const TodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Flavor.selectedFlavor == FlavorType.dev
          ? Banner(
              location: BannerLocation.bottomEnd,
              message: 'DEV',
              color: Colors.blue,
              child: MyMaterialApp(),
            )
          : MyMaterialApp(),
    );
  }
}
