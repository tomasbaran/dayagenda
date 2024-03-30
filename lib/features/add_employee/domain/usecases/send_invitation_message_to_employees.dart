import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/add_employee/data/repositories/send_sms.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/invitation_message.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';

class SendInvitationMessageToEmployees {
  final FirestoreRepository firestoreRepository;
  final SendSms sendSmsRepo;
  SendInvitationMessageToEmployees({required this.sendSmsRepo, required this.firestoreRepository});

  Future call(Employee employee, Group group) async {
    await sendSmsRepo(employee, InvitationMessage.call(employee));
    firestoreRepository.updateTmpEmployeeInfo(employee.copyWith(status: EmployeeStatus.invitationSent));
    print('group: $group');

    firestoreRepository.updateGroupEmployee(
      group.id!,
      employee,
      employee.copyWith(status: EmployeeStatus.invitationSent),
    );
  }
}
