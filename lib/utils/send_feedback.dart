import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dayagenda/globals/constants.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dayagenda/style/style_constants.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SendFeedback {
  void sendEmail(BuildContext context, String subject) async {
    final authService = getIt<AuthService>();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      debugPrint('kIsWeb is true');
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      String appVersion = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      String dash = '--------------------------------------\n';
      String uid = 'UID: ${authService.uid}\n';
      String versionAndBuild = '$appName version: $appVersion($buildNumber)\n';
      String webUesrAgent = 'web user agent: ${webBrowserInfo.userAgent}\n';
      String webLanguage = 'web language: ${webBrowserInfo.language}\n';
      String webVendor = 'web vendor: ${webBrowserInfo.vendor}\n';

      String deviceInfoForDebugging = '\n\n\n\n$dash$uid$versionAndBuild$webUesrAgent$webLanguage$webVendor';

      try {
        String? encodeQueryParameters(Map<String, String> params) {
          return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
        }

        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: feedbackRecipient,
          query: encodeQueryParameters(<String, String>{
            'subject': '$subject ($appName $appVersion)',
            'body': deviceInfoForDebugging,
          }),
        );

        launchUrl(emailLaunchUri);
      } catch (e) {
        showErrorMessageBottomSheet(context);
      }
    } else {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // ?packageInfo.appName has a bug if you don't include the name in Plist.info: https://github.com/flutter/flutter/issues/42510
      String appName = packageInfo.appName;
      String appVersion = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        String dash = '--------------------------------------\n';
        String uid = 'UID: ${authService.uid}\n';
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
        String uid = 'UID: ${authService.uid}\n';
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
          log(e.toString());
          showErrorMessageBottomSheet(context);
        }
      }
    }
  }

  Future showErrorMessageBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
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
        decoration: const BoxDecoration(
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
                  const TextSpan(text: ' from wherever it is convenient to you.'),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
