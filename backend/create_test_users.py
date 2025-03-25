#!/usr/bin/env python
"""
Script to create test users for the Employee Management System.
"""
import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'employee_management.settings')
django.setup()

from django.contrib.auth.models import User
from api.models import LeaveBalance, Task

def create_users():
    # Create employee user if it doesn't exist
    if not User.objects.filter(username='employee').exists():
        employee = User.objects.create_user(
            username='employee',
            password='password123',
            email='employee@example.com',
            first_name='Test',
            last_name='Employee'
        )
        print(f"Created employee user: {employee.username}")
        
        # Create leave balance for employee
        LeaveBalance.objects.create(
            user=employee,
            annual_leave=20,
            sick_leave=10,
            personal_leave=5
        )
        print("Created leave balance for employee")

    # Create manager user if it doesn't exist
    if not User.objects.filter(username='manager').exists():
        manager = User.objects.create_user(
            username='manager',
            password='password123',
            email='manager@example.com',
            first_name='Test',
            last_name='Manager',
            is_staff=True
        )
        print(f"Created manager user: {manager.username}")
        
        # Create leave balance for manager
        LeaveBalance.objects.create(
            user=manager,
            annual_leave=25,
            sick_leave=15,
            personal_leave=7
        )
        print("Created leave balance for manager")
    
    # Create some sample tasks
    employee = User.objects.get(username='employee')
    manager = User.objects.get(username='manager')
    
    if Task.objects.count() == 0:
        Task.objects.create(
            title="Complete project documentation",
            description="Write comprehensive documentation for the API endpoints",
            assigned_to=employee,
            assigned_by=manager,
            due_date="2025-04-15",
            priority="High",
            status="In Progress"
        )
        
        Task.objects.create(
            title="Fix login bug",
            description="Address the issue with login timeout on mobile devices",
            assigned_to=employee,
            assigned_by=manager,
            due_date="2025-04-10",
            priority="Critical",
            status="To Do"
        )
        
        Task.objects.create(
            title="Review code changes",
            description="Review pull request #42 for the new feature",
            assigned_to=manager,
            assigned_by=manager,
            due_date="2025-04-05",
            priority="Medium",
            status="To Do"
        )
        
        print("Created sample tasks")

if __name__ == '__main__':
    create_users()
    print("Test users created successfully!")
