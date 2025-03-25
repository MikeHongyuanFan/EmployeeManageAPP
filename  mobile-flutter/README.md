# Employee Management System - Mobile App

A Flutter-based mobile application for the Employee Management System that integrates with the existing Django backend. This app allows employees to manage leave requests, work-from-home arrangements, tasks, meetings, and documents.

## Features

### Authentication
- Login with username and password
- Secure token storage
- Role-based access (Employee vs Manager)

### Employee Features
- Dashboard with leave balance, task alerts, and WFH status
- Submit and view leave/WFH requests
- Clock-in working hours
- Task management
- View meetings calendar
- Document upload and viewing
- Profile management

### Manager Features
- Employee list and profiles
- Approve/reject leave and WFH requests
- Assign and manage tasks
- Create and manage meetings
- Access shared documents
- Review working hour logs

## Project Structure

```
/lib
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── leave_request.dart
│   ├── wfh_request.dart
│   ├── task.dart
│   ├── meeting.dart
│   ├── document.dart
│   └── leave_balance.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── employee_dashboard.dart
│   ├── manager_dashboard.dart
│   ├── leave_request_screen.dart
│   ├── wfh_request_screen.dart
│   ├── tasks_screen.dart
│   ├── meetings_screen.dart
│   ├── documents_screen.dart
│   ├── profile_screen.dart
│   ├── leave_approval_screen.dart
│   ├── wfh_approval_screen.dart
│   └── employee_list_screen.dart
├── services/                 # API and other services
│   └── api_service.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── leave_provider.dart
│   ├── wfh_provider.dart
│   └── task_provider.dart
├── widgets/                  # Reusable UI components
│   ├── status_chip.dart
│   ├── priority_icon.dart
│   ├── empty_state.dart
│   └── loading_overlay.dart
└── utils/                    # Utilities and helpers
    ├── constants.dart
    └── theme.dart
```

## Backend Integration

The app connects to the existing Django backend through REST API endpoints:

- `/api/login/` - User authentication
- `/api/profile/` - User profile information
- `/api/leave-requests/` - Leave request management
- `/api/wfh-requests/` - WFH request management
- `/api/leave-balance/` - User leave balance
- `/api/tasks/` - Task management
- `/api/working-hours/` - Working time logging
- `/api/meetings/` - Calendar meetings
- `/api/documents/` - File/document access
- `/api/notifications/` - Real-time events

## Getting Started

### Prerequisites
- Flutter SDK (2.0 or higher)
- Android Studio / Xcode for emulators
- A running instance of the Django backend

### Setup
1. Clone the repository
2. Update the API base URL in `lib/services/api_service.dart`
3. Run `flutter pub get` to install dependencies
4. Run the app with `flutter run`

### Running on Emulators

#### Android Emulator
```bash
flutter run
```

#### iOS Simulator (Mac only)
```bash
flutter run -d iOS
```

#### Web (Optional)
```bash
flutter run -d chrome
```

## Dependencies

- `http` - API interaction
- `provider` - State management
- `shared_preferences` / `flutter_secure_storage` - Auth token storage
- `table_calendar` - Calendar features
- `file_picker`, `path_provider` - Document upload/download
- `fl_chart` - Data visualization
- `intl` - Date formatting
- `flutter_local_notifications` - Push notifications

## Future Enhancements

- Offline mode with data synchronization
- Push notifications for request updates
- Geolocation-based clock-in
- In-app reporting with charts and statistics
- Biometric authentication
