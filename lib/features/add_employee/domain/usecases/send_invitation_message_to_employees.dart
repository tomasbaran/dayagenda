import 'package:dayagenda/features/add_employee/data/repositories/send_sms.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/globals/constants.dart';

class SendInvitationMessageToEmployees {
  final SendSms sendSmsRepo;

  SendInvitationMessageToEmployees(this.sendSmsRepo);

  Future call(List<Employee> employees) async {
    return await sendSmsRepo(employees, smsMessage);
  }
}
