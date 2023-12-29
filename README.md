# DayAgenda

## FIREBASE CONFIG
0. Open Xcode project:
1. Create firebase_flavors/dev & firebase_flavors/live folders  under Runner folder and put corresponding GoogleService-Info.plist in them:
   a. firebase_flavors/dev/GoogleService-Info.plist
   b. firebase_flavors/live/GoogleService-Info.plist
2. Install Firebase CLI `curl -sL https://firebase.tools | bash`
3. `firebase login`
4. `dart pub global activate flutterfire_cli`
5. Add `firebase_options_dev`:
```
flutterfire config \
  --project=dayagenda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.ambee.dayagenda.dev \
  --macos-bundle-id=com.ambee.dayagenda.dev \
  --android-package-name=com.ambee.dayagenda.dev
```
5.  Add `firebase_options_live`:
```
flutterfire config \
  --project=dayagenda-live \
  --out=lib/firebase_options_live.dart \
  --ios-bundle-id=com.ambee.dayagenda \
  --macos-bundle-id=com.ambee.dayagenda \
  --android-package-name=com.ambee.dayagenda
```

when uploading to dev firebase hosting:
1. flutter build web --dart-define FLAVOR=dev
2. firebase use dev
3. firebase deploy

when uploading to live firebase hosting:
1. flutter build web --dart-define FLAVOR=live
2. firebase use live
3. firebase deploy
