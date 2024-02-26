import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';

class SendInvitationMessageToEmployees {
  final EmployeeRepository repository;

  SendInvitationMessageToEmployees(this.repository);

  @override
  Future call(List<Employee> employees) async {
    return await repository.sendInvitationMessageToEmployees(params.employees);
  }
}
