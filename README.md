# Task_App

## 📌 Overview
Task_App is a simple and efficient task management application that helps users schedule and manage their daily tasks with notifications.

## 🔥 Features
- 📅 Schedule tasks with reminders
- 🔔 Instant and scheduled notifications
- ⏰ Uses Flutter Local Notifications for precise scheduling
- 🌐 Timezone-aware scheduling using `timezone` package
- 🎨 Simple and user-friendly UI

## 🛠️ Technologies Used
- **Flutter**
- **Dart**
- **flutter_local_notifications** for notifications
- **timezone** for timezone support
- **Android Alarm Manager** (for background task scheduling)

## 🚀 Getting Started

### Prerequisites
- Install Flutter SDK: [Flutter Setup](https://flutter.dev/docs/get-started/install)
- Ensure you have an updated Android SDK
- Enable developer mode on your test device

### Installation
Clone the repository:
```sh
git clone https://github.com/KingSlayerArbaaz/Task_manager.git
cd Task_App
```
Install dependencies:
```sh
flutter pub get
```
Run the app in debug mode:
```sh
flutter run
```
Build the APK:
```sh
flutter build apk --release
```

## 📜 Android Permissions
Make sure the following permissions are added to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## 🚨 Troubleshooting
**Scheduled notifications not working in release mode?**
1. Ensure ProGuard rules are updated in `proguard-rules.pro`:
```prolog
-keep class com.dexterous.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.gson.** { *; }
-keepclassmembers class * { @Keep *; }
```
2. Add `tz.initializeTimeZones();` before scheduling notifications.
3. Test with `flutter build apk --release` and install on a real device.

## 📬 Contact
For issues, feel free to open an issue on GitHub or reach out to me at arbaazbaig98gmail.com.

Happy Coding! 🚀

