# Employee Management App

A Flutter mobile application for the Employee Management System.

## Features

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

## Getting Started

### Prerequisites

- Flutter SDK (follow the instructions at [flutter.dev](https://flutter.dev/docs/get-started/install))
- Backend server running (see main project README)

### Installation

1. Clone the repository
2. Navigate to the app directory:
   ```bash
   cd mobile-flutter/employee_management_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Testing Credentials

- **Employee Role**:
  - Username: `employee`
  - Password: `password123`

- **Manager Role**:
  - Username: `manager`
  - Password: `password123`

## API Integration

The app connects to the Django backend API for all operations. The API service is configured in `lib/services/api_service.dart`.

## Project Structure

- `lib/models/` - Data models
- `lib/screens/` - UI screens
- `lib/services/` - API and other services
- `assets/` - Images and other assets
