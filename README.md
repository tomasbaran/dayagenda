# DayAgenda Installation

## Firebase Config (iOS)
0. Open Xcode project:
1. Create firebase_flavors/dev & firebase_flavors/live folders  under Runner folder and put corresponding GoogleService-Info.plist in them:
   a. firebase_flavors/dev/GoogleService-Info.plist
   b. firebase_flavors/live/GoogleService-Info.plist

## Firebase Config (web)
0. Install Firebase CLI `curl -sL https://firebase.tools | bash`
1. `firebase login`
2. `dart pub global activate flutterfire_cli`
3. Add `firebase_options_dev`:
```
flutterfire config \
  --project=dayagenda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.ambee.dayagenda.dev \
  --macos-bundle-id=com.ambee.dayagenda.dev \
  --android-package-name=com.ambee.dayagenda.dev
```
4.  Add `firebase_options_live`:
```
flutterfire config \
  --project=dayagenda-live \
  --out=lib/firebase_options_live.dart \
  --ios-bundle-id=com.ambee.dayagenda \
  --macos-bundle-id=com.ambee.dayagenda \
  --android-package-name=com.ambee.dayagenda
```
## Uploading 
#### to dev firebase hosting:
1. `flutter build web --dart-define FLAVOR=dev`
2. `firebase use dev`
3. `firebase deploy`

#### to live firebase hosting:
1. `flutter build web --dart-define FLAVOR=live`
2. `firebase use live`
3. `firebase deploy`
