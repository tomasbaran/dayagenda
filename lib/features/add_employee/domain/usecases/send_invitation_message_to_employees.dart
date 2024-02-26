import 'package:dayagenda/features/add_employee/data/repositories/send_sms.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';

class SendInvitationMessageToEmployees {
  final SendSms sendSmsRepo;

  SendInvitationMessageToEmployees(this.sendSmsRepo);

  Future call(List<Employee> employees) async {
    return await sendSmsRepo(employees, 'You are invited to join our team!');
  }
}
