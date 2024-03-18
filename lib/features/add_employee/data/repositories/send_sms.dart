import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

class SendSms {
  Future<void> call(Employee employee, String message) async {
    debugPrint('send sms to employee: $employee with message: $message');

    String _result = await sendSMS(message: message, recipients: [employee.phone!]).catchError((onError) {
      print('smsError: $onError');
      return onError;
    });
    print('send_sms: $_result');
    // send sms
  }
}
