import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:flutter_sms/flutter_sms.dart';

class SendSms {
  Future<void> call(List<Employee> employees, String message) async {
    print('send sms to employees: $employees with message: $message');

    for (var employee in employees) {
      String _result = await sendSMS(message: message, recipients: [employee.phone!]).catchError((onError) {
        print(onError);
        return onError;
      });
      print(_result);
    }
    // send sms
  }
}
