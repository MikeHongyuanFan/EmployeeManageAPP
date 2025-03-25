from django.db import models
from django.contrib.auth.models import AbstractUser
from django.urls import reverse
from django.utils import timezone

def profile_picture_upload_path(instance, filename):
    """Generate file path for profile picture uploads"""
    return f'profile_pictures/{instance.username}/{filename}'

class CustomUser(AbstractUser):
    """Extended user model with additional fields"""
    # User types
    EMPLOYEE = 'employee'
    MANAGER = 'manager'
    HR = 'hr'
    ADMIN = 'admin'
    
    USER_TYPES = [
        (EMPLOYEE, 'Employee'),
        (MANAGER, 'Manager'),
        (HR, 'HR'),
        (ADMIN, 'Admin'),
    ]
    
    # Departments
    IT = 'it'
    HR_DEPT = 'hr'
    FINANCE = 'finance'
    MARKETING = 'marketing'
    SALES = 'sales'
    OPERATIONS = 'operations'
    CUSTOMER_SERVICE = 'customer_service'
    RESEARCH = 'research'
    
    DEPARTMENTS = [
        (IT, 'Information Technology'),
        (HR_DEPT, 'Human Resources'),
        (FINANCE, 'Finance'),
        (MARKETING, 'Marketing'),
        (SALES, 'Sales'),
        (OPERATIONS, 'Operations'),
        (CUSTOMER_SERVICE, 'Customer Service'),
        (RESEARCH, 'Research & Development'),
    ]
    
    # Additional fields
    user_type = models.CharField(max_length=20, choices=USER_TYPES, default=EMPLOYEE)
    department = models.CharField(max_length=20, choices=DEPARTMENTS, null=True, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    emergency_contact = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    hire_date = models.DateField(null=True, blank=True)
    profile_picture = models.ImageField(upload_to=profile_picture_upload_path, null=True, blank=True)
    manager = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='managed_employees'
    )
    
    def __str__(self):
        return self.get_full_name() or self.username
    
    def get_absolute_url(self):
        return reverse('profile')
    
    def is_manager_or_above(self):
        """Check if user is a manager or higher role"""
        return self.user_type in [self.MANAGER, self.HR, self.ADMIN]
    
    def is_hr_or_admin(self):
        """Check if user is HR or admin"""
        return self.user_type in [self.HR, self.ADMIN]
    
    def get_managed_employees(self):
        """Get all employees managed by this user"""
        return self.managed_employees.all()
    
    def get_managed_employees_count(self):
        """Get count of managed employees"""
        return self.managed_employees.count()
    
    def get_pending_leave_requests(self):
        """Get pending leave requests for managed employees"""
        from leave_system.models import LeaveRequest
        return LeaveRequest.objects.filter(
            user__in=self.managed_employees.all(),
            status=LeaveRequest.PENDING
        )
    
    def get_pending_wfh_requests(self):
        """Get pending WFH requests for managed employees"""
        from wfh_system.models import WFHRequest
        return WFHRequest.objects.filter(
            user__in=self.managed_employees.all(),
            status=WFHRequest.PENDING
        )

class WorkingTime(models.Model):
    """Model for tracking employee working time"""
    user = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='working_times'
    )
    date = models.DateField(default=timezone.now)
    hours_worked = models.DecimalField(max_digits=4, decimal_places=2)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-date']
        unique_together = ['user', 'date']
    
    def __str__(self):
        return f"{self.user} - {self.date} ({self.hours_worked} hours)"

# Add the missing Employee and Department models
class Department(models.Model):
    """Department model"""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    def __str__(self):
        return self.name

class Employee(models.Model):
    """Employee model that extends the CustomUser model"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='employee_profile')
    employee_id = models.CharField(max_length=20, unique=True)
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    position = models.CharField(max_length=100)
    manager = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='subordinates')
    date_joined = models.DateField(default=timezone.now)
    phone = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    emergency_contact = models.CharField(max_length=100, blank=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', null=True, blank=True)
    
    def __str__(self):
        return f"{self.user.get_full_name()} ({self.employee_id})"
