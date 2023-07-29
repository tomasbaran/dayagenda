import 'package:flutter/material.dart';
import 'package:today/globals/constants.dart';
import 'package:today/services/auth_service.dart';

import 'package:today/style/style_constants.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SendFeedback {
  void sendEmail(BuildContext context, String subject) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // ?packageInfo.appName has a bug if you don't include the name in Plist.info: https://github.com/flutter/flutter/issues/42510
    String appName = packageInfo.appName;
    String appVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String dash = '--------------------------------------\n';
      String uid = 'UID: ${AuthService().uid}\n';
      String versionAndBuild = '$appName version: $appVersion($buildNumber)\n';
      String brand = 'Brand: ${androidInfo.brand}\n';
      String manufacturer = 'Manufacturer: ${androidInfo.manufacturer}\n';
      String isPhysicalDevice = 'Physical Device: ${androidInfo.isPhysicalDevice}\n';
      String model = 'Model: ${androidInfo.model}\n';
      String supportedAbis = 'SupportedAbis: ${androidInfo.supportedAbis}\n';
      String type = 'Type: ${androidInfo.type}\n';
      String versionBaseOs = 'Version BaseOS: ${androidInfo.version.baseOS}\n';
      String versionCodeName = 'Version Type (Release/Beta): ${androidInfo.version.codename}\n';
      String versionPreviewSdkInt = 'Version PreviewSdkInt: ${androidInfo.version.previewSdkInt}\n';
      String versionRelease = 'Version Release: ${androidInfo.version.release}\n';
      //SRC: https://developer.android.com/reference/android/os/Build.VERSION_CODES
      String versionSdk = 'Version SDK: ${androidInfo.version.sdkInt}\n';
      // String versionSecurityPatch =
      //     'Version SecurityPatch: ${androidInfo.version.securityPatch}\n';
      String deviceInfoForDebugging =
          '\n\n\n\n$dash$uid$versionAndBuild$isPhysicalDevice$brand$manufacturer$model$supportedAbis$type$versionBaseOs$versionCodeName$versionPreviewSdkInt$versionRelease$versionSdk';

      final Email email = Email(
        body: deviceInfoForDebugging,
        subject: '$subject ($appName $appVersion)',
        recipients: [feedbackRecipient],
        isHTML: false,
      );
      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        showErrorMessageBottomSheet(context);
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String dash = '--------------------------------------\n';
      String uid = 'UID: ${AuthService().uid}\n';
      String versionAndBuild = '$appName version: $appVersion($buildNumber)\n';
      String isPhysicalDevice = 'Physical Device: ${iosInfo.isPhysicalDevice}\n';
      String uuid = 'UUID: ${iosInfo.identifierForVendor}\n';
      String model = 'Model: ${iosInfo.model} (${iosInfo.utsname.machine})\n';
      String os = 'OS: ${iosInfo.systemName} ${iosInfo.systemVersion}\n';
      String utsnameRelease = 'UTS Name (release level): ${iosInfo.utsname.release}\n';
      String utsnameSystem = 'UTS Name (operatin system name): ${iosInfo.utsname.sysname}\n';
      // String utsnameVersion =
      //     'UTS Name (Kernel version): ${iosInfo.utsname.version}\n';

      String deviceInfoForDebugging = '\n\n\n\n$dash$uid$versionAndBuild$isPhysicalDevice$model$os$utsnameRelease$utsnameSystem$uuid';

      final Email email = Email(
        body: deviceInfoForDebugging,
        subject: '$subject ($appName $appVersion)',
        recipients: [feedbackRecipient],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
      } catch (e) {
        print(e);
        showErrorMessageBottomSheet(context);
      }
    }
  }

  Future showErrorMessageBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(42),
          topRight: Radius.circular(42),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kThemeColor11,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(42),
            topRight: Radius.circular(42),
          ),
          //borderRadius: BorderRadius.circular(42),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 45, 30, 45),
              child: Text(
                'No email app found',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: addNewTaskSheetFieldHintTitleTextStyle, text: 'Please, send me an email to ', children: <TextSpan>[
                  TextSpan(text: feedbackRecipient, style: addNewTaskSheetFieldHintTitleTextStyle.copyWith(decoration: TextDecoration.underline)),
                  TextSpan(text: ' from wherever it is convenient to you.'),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
