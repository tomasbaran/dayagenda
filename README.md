# DayAgenda Installation

## Firebase Flavors Config
0. Install Firebase CLI `curl -sL https://firebase.tools | bash`
1. `firebase login`
2. `dart pub global activate flutterfire_cli`

#### DEV: 
1. 
```
flutterfire config \
  --project=dayagenda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.ambee.dayagenda.dev \
  --macos-bundle-id=com.ambee.dayagenda.dev \
  --android-package-name=com.ambee.dayagenda.dev
```
2. `mv ios/firebase_app_id_file.json ios/firebase_app_id_file_dev.json`
3. `mv macos/firebase_app_id_file.json macos/firebase_app_id_file_dev.json`
4. `mv android/app/google-services.json android/app/google-services_dev.json`

#### LIVE: 
1. 
```
flutterfire config \
  --project=dayagenda-live \
  --out=lib/firebase_options_live.dart \
  --ios-bundle-id=com.ambee.dayagenda \
  --macos-bundle-id=com.ambee.dayagenda \
  --android-package-name=com.ambee.dayagenda
```
2. `mv ios/firebase_app_id_file.json ios/firebase_app_id_file_live.json`
3. `mv macos/firebase_app_id_file.json macos/firebase_app_id_file_live.json`
4. `mv android/app/google-services.json android/app/google-services_live.json`

## Deploying 
#### DEV firebase hosting:
`flutter build web --dart-define flavor=dev && firebase deploy --project dayagenda-dev`

#### LIVE firebase hosting:
`flutter build web --dart-define flavor=live && firebase deploy --project dayagenda-live`
