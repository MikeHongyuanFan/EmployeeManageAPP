# Running the Employee Management App

This document provides detailed instructions for setting up and running the Employee Management mobile application.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** - Follow the installation instructions at [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Android Studio** or **Xcode** (depending on your target platform)
3. **Git** for version control

## Setup Instructions

### 1. Check Flutter Installation

Verify that Flutter is correctly installed by running:

```bash
flutter doctor
```

Fix any issues reported by the Flutter doctor before proceeding.

### 2. Get Dependencies

Navigate to the app directory and get the required dependencies:

```bash
cd mobile-flutter/employee_management_app
flutter pub get
```

### 3. Configure Backend Connection

The app is configured to connect to a backend running at `http://localhost:8000/api`. If your backend is running on a different address:

- For Android emulator: If using localhost on your machine, use `10.0.2.2` instead of `localhost` in the API service.
- For iOS simulator: `localhost` should work fine.

To modify the backend URL, edit the `lib/services/api_service.dart` file and update the `baseUrl` constant.

### 4. Run the App

#### For Development

```bash
flutter run
```

This will launch the app on a connected device or emulator.

#### Specify a Device

If you have multiple devices connected, you can specify which one to use:

```bash
flutter devices  # List available devices
flutter run -d <device_id>  # Run on specific device
```

### 5. Build for Production

#### Android

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`.

#### iOS

```bash
flutter build ios --release
```

Then open the Xcode project in the `ios` folder and archive it for distribution.

## Testing Credentials

Use these credentials to test the application:

- **Employee Role**:
  - Username: `employee`
  - Password: `password123`

- **Manager Role**:
  - Username: `manager`
  - Password: `password123`

## Troubleshooting

### Common Issues

1. **Backend Connection Issues**:
   - Ensure the Django backend is running
   - Check the URL configuration in `api_service.dart`
   - For Android emulator, make sure you're using `10.0.2.2` instead of `localhost`

2. **Build Failures**:
   - Run `flutter clean` and then try building again
   - Update Flutter SDK: `flutter upgrade`

3. **Package Issues**:
   - Try running `flutter pub get` again
   - Check for package compatibility issues in `pubspec.yaml`

### Getting Help

If you encounter any issues not covered here, please contact the development team or create an issue in the project repository.
