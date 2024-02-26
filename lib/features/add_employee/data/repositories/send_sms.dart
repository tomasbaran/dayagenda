import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';

class SendSms {
  Future<void> call(List<Employee> employees, String message) async {
    print('send sms to employees: $employees with message: $message');
    // send sms
  }
}
