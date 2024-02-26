import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/globals/constants.dart';

class InvitationMessage {
  static String call(Employee employee) =>
      'Buenos días ${employee.firstName}! Vamos a probar una herramienta para aumentar la productividad. Favor de registrarse acá: $kDayagendaUrl/#/register_employee/${employee.uid}. Gracias de antemano. Saludos!';
}
