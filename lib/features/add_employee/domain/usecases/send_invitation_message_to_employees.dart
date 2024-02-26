import 'package:dayagenda/features/add_employee/data/repositories/send_sms.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/invitation_message.dart';

class SendInvitationMessageToEmployees {
  final SendSms sendSmsRepo;
  SendInvitationMessageToEmployees(this.sendSmsRepo);

  Future call(List<Employee> employees) async {
    for (var employee in employees) {
      await sendSmsRepo([employee], InvitationMessage.call(employee));
    }
  }
}
