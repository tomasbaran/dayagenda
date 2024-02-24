import 'package:flutter/material.dart';
import 'package:dayagenda/flavor.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/widgets/my_material_app.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/states/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupGetIt();

  final appState = locate<AppState>();
  await appState.initializeSelectedFlavor();

  runApp(const DayAgendaApp());
}

class DayAgendaApp extends StatelessWidget {
  const DayAgendaApp({super.key});

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
