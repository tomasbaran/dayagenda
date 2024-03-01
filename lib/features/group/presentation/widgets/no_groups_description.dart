import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class NoGroupsDescription extends StatelessWidget {
  const NoGroupsDescription({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Gestiona tareas de tus empleados.',
          style: navBarAccountEmailInputTextStyle,
        ),
        const SizedBox(height: 24),
        Text(
          'Toca + para agrega un grupo (e.g. empresa, departamento, proyecto, etc.).',
          style: navBarAccountEmailInputTextStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
