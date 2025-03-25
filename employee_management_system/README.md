# Employee Management System

A comprehensive Django-based system for managing employee information, leave requests, work from home arrangements, tasks, meetings, and documents.

## Features

### User Authentication System
- Custom user model with employee and manager roles
- User registration and login
- Working time tracking

### Leave Management System
- Leave request submission
- Leave approval workflow
- Leave balance tracking

### Work From Home (WFH) System
- WFH request submission
- WFH approval workflow
- WFH time tracking

### Calendar System
- Meeting scheduling
- Support for both Zoom and face-to-face meetings
- Calendar view with filtering options

### Task Management System
- Task creation and assignment
- Task status tracking
- Personal tasks for employees
- Task prioritization and deadlines

### Document Management System
- Document upload and categorization
- Access control for documents
- Document commenting system
- Document search and filtering

## Installation

1. Clone the repository:
```
git clone <repository-url>
cd employee-management-system
```

2. Create a virtual environment and activate it:
```
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```
pip install -r requirements.txt
```

4. Apply migrations:
```
python manage.py migrate
```

5. Create a superuser:
```
python manage.py createsuperuser
```

6. Run the development server:
```
python manage.py runserver
```

7. Access the application at http://127.0.0.1:8000/

## Usage

### For Employees
- Submit leave requests
- Request work from home days
- Track working hours
- Create and manage personal tasks
- View and participate in meetings
- Access shared documents

### For Managers
- Approve or reject leave requests
- Approve or reject work from home requests
- Create and assign tasks to employees
- Schedule meetings with employees
- Upload and manage documents
- View employee working hours

## Project Structure

The project is organized into several Django apps:

- `accounts`: User authentication and profile management
- `leave_system`: Leave request management
- `wfh_system`: Work from home management
- `calendar_system`: Meeting and calendar management
- `task_management`: Task creation and assignment
- `document_management`: Document upload and sharing

## Technologies Used

- Django 4.2
- Bootstrap 5
- JavaScript/jQuery
- Select2 for enhanced dropdowns
- SQLite (development) / PostgreSQL (production)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
