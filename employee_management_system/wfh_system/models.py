from django.db import models
from django.conf import settings
from django.utils import timezone
from django.urls import reverse

class WFHRequest(models.Model):
    """Model for work from home requests"""
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
        related_name='wfh_requests'
    )
    date = models.DateField()
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PENDING)
    processed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='wfh_requests_processed'
    )
    processed_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        unique_together = ['user', 'date']
    
    def __str__(self):
        return f"{self.user} - WFH on {self.date}"
    
    def get_absolute_url(self):
        return reverse('wfh_request_detail', args=[self.id])
    
    def approve(self, processed_by):
        """Approve WFH request"""
        self.status = self.APPROVED
        self.processed_by = processed_by
        self.processed_at = timezone.now()
        self.save()
    
    def reject(self, processed_by, rejection_reason):
        """Reject WFH request"""
        self.status = self.REJECTED
        self.processed_by = processed_by
        self.processed_at = timezone.now()
        self.rejection_reason = rejection_reason
        self.save()
    
    def cancel(self):
        """Cancel WFH request"""
        self.status = self.CANCELLED
        self.save()
