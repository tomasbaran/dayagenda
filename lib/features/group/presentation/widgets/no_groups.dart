import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class NoGroups extends StatelessWidget {
  const NoGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Mis Grupos',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.add_circle_rounded,
                size: 32,
                color: kBlueAccentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
