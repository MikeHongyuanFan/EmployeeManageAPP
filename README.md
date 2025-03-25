# Employee Management System

A comprehensive system for managing employee information, leave requests, work-from-home arrangements, tasks, meetings, and documents.

## Project Components

### 1. Django Backend
- REST API for all system operations
- Authentication and authorization
- Database management
- Business logic implementation

### 2. Flutter Mobile App
- Cross-platform mobile application
- Employee and manager interfaces
- Real-time notifications
- Offline capabilities

## Getting Started

### Setting Up the Backend

1. **Install Dependencies**:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Run Migrations**:
   ```bash
   python manage.py migrate
   ```

3. **Create Test Users**:
   ```bash
   python create_test_users.py
   ```

4. **Start the Server**:
   ```bash
   python manage.py runserver 8000
   ```

### Setting Up the Mobile App

1. **Install Flutter SDK** (if not already installed):
   - Follow the instructions at [flutter.dev](https://flutter.dev/docs/get-started/install)

2. **Install Dependencies**:
   ```bash
   cd mobile-flutter/employee_management_app
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

See the detailed instructions in `mobile-flutter/run_instructions.md` for more information.

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

## API Endpoints

The backend provides the following API endpoints:

- `/api/login/` - User authentication
- `/api/logout/` - User logout
- `/api/profile/` - User profile information
- `/api/employees/` - Employee list (manager only)
- `/api/leave-requests/` - Leave request management
- `/api/wfh-requests/` - WFH request management
- `/api/leave-balance/` - User leave balance
- `/api/tasks/` - Task management
- `/api/working-hours/` - Working time logging
- `/api/meetings/` - Calendar meetings
- `/api/documents/` - File/document access
- `/api/notifications/` - Real-time events

## Testing

For testing purposes, use the following credentials:

- **Employee Role**:
  - Username: `employee`
  - Password: `password123`

- **Manager Role**:
  - Username: `manager`
  - Password: `password123`
