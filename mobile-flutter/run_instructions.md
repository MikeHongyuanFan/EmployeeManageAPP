# Running the Employee Management Mobile App

This document provides detailed instructions for setting up and running the Flutter mobile application for the Employee Management System.

## Prerequisites

1. **Flutter SDK**: Make sure you have Flutter installed on your system.
   - Check your installation with `flutter doctor`
   - If not installed, follow the instructions at [flutter.dev](https://flutter.dev/docs/get-started/install)

2. **Backend Server**: The Django backend server should be running.
   - Default URL is `http://localhost:8000` for web or `http://10.0.2.2:8000` for Android emulator
   - Make sure the server is accessible from your device/emulator

## Setup Instructions

1. **Navigate to the app directory**:
   ```bash
   cd mobile-flutter/employee_management_app
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Check for issues**:
   ```bash
   flutter analyze
   ```

## Running the App

### For Development

1. **Start an emulator or connect a device**:
   - For Android: `flutter emulators --launch <emulator_id>`
   - For iOS: Open Simulator app on macOS
   - Or connect a physical device via USB

2. **Run the app**:
   ```bash
   flutter run
   ```

### For Web Testing

1. **Enable web support** (if not already enabled):
   ```bash
   flutter config --enable-web
   ```

2. **Run the web version**:
   ```bash
   flutter run -d chrome
   ```

## Testing Credentials

Use these credentials to test the application:

- **Employee Role**:
  - Username: `employee`
  - Password: `password123`

- **Manager Role**:
  - Username: `manager`
  - Password: `password123`

## Troubleshooting

1. **API Connection Issues**:
   - Check that the backend server is running
   - Verify the API base URL in `lib/services/api_service.dart`
   - For Android emulator, make sure you're using `10.0.2.2` instead of `localhost`

2. **Login Problems**:
   - Ensure you're using the correct credentials
   - Check the Django server logs for authentication issues

3. **UI Rendering Issues**:
   - Try running `flutter clean` and then `flutter pub get`
   - Restart the app with `flutter run`

## Building for Production

1. **Android APK**:
   ```bash
   flutter build apk
   ```

2. **iOS IPA** (requires macOS and Apple Developer account):
   ```bash
   flutter build ios
   ```

3. **Web**:
   ```bash
   flutter build web
   ```

## Complete Run Commands

### Starting the Backend Server

```bash
# Navigate to the backend directory
cd /Users/hongyuandan/Desktop/Employee\ management\ system\ test\ 2/backend

# Run the Django server
python manage.py runserver 8000
```

### Starting the Flutter App

```bash
# Navigate to the Flutter app directory
cd /Users/hongyuandan/Desktop/Employee\ management\ system\ test\ 2/mobile-flutter/employee_management_app

# Run the app on Chrome (for web testing)
flutter run -d chrome

# Alternatively, run on a connected device or emulator
flutter run
```

### Running Both in Separate Terminal Windows

For the best development experience, run both the backend and frontend in separate terminal windows:

**Terminal 1 (Backend)**:
```bash
cd /Users/hongyuandan/Desktop/Employee\ management\ system\ test\ 2/backend
python manage.py runserver 8000
```

**Terminal 2 (Frontend)**:
```bash
cd /Users/hongyuandan/Desktop/Employee\ management\ system\ test\ 2/mobile-flutter/employee_management_app
flutter run -d chrome
```

This allows you to see logs from both the backend and frontend simultaneously.
