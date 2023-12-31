# DayAgenda Installation

## iOS Installation of Missing Files
0. `flutter create .`

## Firebase Flavors Config
0. Install Firebase CLI `curl -sL https://firebase.tools | bash`
1. `firebase login`
2. `dart pub global activate flutterfire_cli`

`firebase_options_dev`:
```
flutterfire config \
  --project=dayagenda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.ambee.dayagenda.dev \
  --macos-bundle-id=com.ambee.dayagenda.dev \
  --android-package-name=com.ambee.dayagenda.dev
```
`firebase_options_live`:
```
flutterfire config \
  --project=dayagenda-live \
  --out=lib/firebase_options_live.dart \
  --ios-bundle-id=com.ambee.dayagenda \
  --macos-bundle-id=com.ambee.dayagenda \
  --android-package-name=com.ambee.dayagenda
```
## Deploying 
#### DEV firebase hosting:
`flutter build web --dart-define flavor=dev && firebase deploy --project dayagenda-dev`

#### LIVE firebase hosting:
`flutter build web --dart-define flavor=live && firebase deploy --project dayagenda-live`
