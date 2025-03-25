from django.db import models
from django.conf import settings
from django.utils import timezone
from django.urls import reverse
from datetime import timedelta

class LeaveRequest(models.Model):
    """Model for employee leave requests"""
    # Leave types
    ANNUAL = 'annual'
    SICK = 'sick'
    PERSONAL = 'personal'
    UNPAID = 'unpaid'
    BEREAVEMENT = 'bereavement'
    MATERNITY = 'maternity'
    PATERNITY = 'paternity'
    
    LEAVE_TYPES = [
        (ANNUAL, 'Annual Leave'),
        (SICK, 'Sick Leave'),
        (PERSONAL, 'Personal Leave'),
        (UNPAID, 'Unpaid Leave'),
        (BEREAVEMENT, 'Bereavement Leave'),
        (MATERNITY, 'Maternity Leave'),
        (PATERNITY, 'Paternity Leave'),
    ]
    
    # Status choices
    PENDING = 'pending'
    APPROVED = 'approved'
    REJECTED = 'rejected'
    CANCELLED = 'cancelled'
    
    STATUS_CHOICES = [
        (PENDING, 'Pending'),
        (APPROVED, 'Approved'),
        (REJECTED, 'Rejected'),
        (CANCELLED, 'Cancelled'),
    ]
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='leave_requests'
    )
    leave_type = models.CharField(max_length=20, choices=LEAVE_TYPES)
    start_date = models.DateField()
    end_date = models.DateField()
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PENDING)
    processed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='leave_requests_processed'
    )
    processed_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user} - {self.get_leave_type_display()} ({self.start_date} to {self.end_date})"
    
    def get_absolute_url(self):
        return reverse('leave_request_detail', args=[self.id])
    
    def get_days(self):
        """Calculate number of days requested"""
        delta = self.end_date - self.start_date
        return delta.days + 1
        
    def get_hours(self):
        """Calculate number of hours requested (8 hours per day)"""
        return self.get_days() * 8
    
    def approve(self, processed_by):
        """Approve leave request"""
        self.status = self.APPROVED
        self.processed_by = processed_by
        self.processed_at = timezone.now()
        self.save()
        
        # Update leave balance
        if self.leave_type in [self.ANNUAL, self.SICK, self.PERSONAL]:
            # Get or create leave balance
            balance, created = LeaveBalance.objects.get_or_create(user=self.user)
            hours = self.get_hours()  # 8 hours per day
            
            if self.leave_type == self.ANNUAL:
                balance.annual_leave_hours -= hours
            elif self.leave_type == self.SICK:
                balance.sick_leave_hours -= hours
            elif self.leave_type == self.PERSONAL:
                balance.personal_leave_hours -= hours
            
            balance.update_day_balances()  # Update day balances based on hour balances
    
    def reject(self, processed_by, rejection_reason):
        """Reject leave request"""
        self.status = self.REJECTED
        self.processed_by = processed_by
        self.processed_at = timezone.now()
        self.rejection_reason = rejection_reason
        self.save()
    
    def cancel(self):
        """Cancel leave request"""
        if self.status == self.APPROVED:
            # Restore leave balance
            if self.leave_type in [self.ANNUAL, self.SICK, self.PERSONAL]:
                balance, created = LeaveBalance.objects.get_or_create(user=self.user)
                hours = self.get_hours()  # 8 hours per day
                
                if self.leave_type == self.ANNUAL:
                    balance.annual_leave_hours += hours
                elif self.leave_type == self.SICK:
                    balance.sick_leave_hours += hours
                elif self.leave_type == self.PERSONAL:
                    balance.personal_leave_hours += hours
                
                balance.update_day_balances()  # Update day balances based on hour balances
        
        self.status = self.CANCELLED
        self.save()

class LeaveBalance(models.Model):
    """Model for tracking employee leave balances"""
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='leave_balance'
    )
    annual_leave_balance = models.DecimalField(max_digits=5, decimal_places=1, default=20)
    sick_leave_balance = models.DecimalField(max_digits=5, decimal_places=1, default=10)
    personal_leave_balance = models.DecimalField(max_digits=5, decimal_places=1, default=5)
    
    # Leave balances in hours (8 hours per day)
    annual_leave_hours = models.DecimalField(max_digits=6, decimal_places=1, default=160)  # 20 days * 8 hours
    sick_leave_hours = models.DecimalField(max_digits=6, decimal_places=1, default=80)     # 10 days * 8 hours
    personal_leave_hours = models.DecimalField(max_digits=6, decimal_places=1, default=40) # 5 days * 8 hours
    
    def __str__(self):
        return f"Leave Balance for {self.user}"
        
    def update_day_balances(self):
        """Update day balances based on hour balances"""
        self.annual_leave_balance = self.annual_leave_hours / 8
        self.sick_leave_balance = self.sick_leave_hours / 8
        self.personal_leave_balance = self.personal_leave_hours / 8
        self.save()
        
    @property
    def total_days_available(self):
        """Calculate total available leave days across all types"""
        return self.annual_leave_balance + self.sick_leave_balance + self.personal_leave_balance
        """Update day balances based on hour balances"""
        self.annual_leave_balance = self.annual_leave_hours / 8
        self.sick_leave_balance = self.sick_leave_hours / 8
        self.personal_leave_balance = self.personal_leave_hours / 8
        self.save()
