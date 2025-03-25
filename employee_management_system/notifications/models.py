from django.db import models
from django.conf import settings
from django.urls import reverse

class Notification(models.Model):
    """Model for user notifications"""
    
    # Notification types
    LEAVE_REQUEST = 'leave_request'
    LEAVE_APPROVED = 'leave_approved'
    LEAVE_REJECTED = 'leave_rejected'
    WFH_REQUEST = 'wfh_request'
    WFH_APPROVED = 'wfh_approved'
    WFH_REJECTED = 'wfh_rejected'
    TASK_ASSIGNED = 'task_assigned'
    TASK_UPDATED = 'task_updated'
    TASK_COMPLETED = 'task_completed'
    MEETING_SCHEDULED = 'meeting_scheduled'
    MEETING_UPDATED = 'meeting_updated'
    MEETING_CANCELLED = 'meeting_cancelled'
    DOCUMENT_SHARED = 'document_shared'
    DOCUMENT_COMMENTED = 'document_commented'
    
    NOTIFICATION_TYPES = [
        (LEAVE_REQUEST, 'Leave Request'),
        (LEAVE_APPROVED, 'Leave Approved'),
        (LEAVE_REJECTED, 'Leave Rejected'),
        (WFH_REQUEST, 'WFH Request'),
        (WFH_APPROVED, 'WFH Approved'),
        (WFH_REJECTED, 'WFH Rejected'),
        (TASK_ASSIGNED, 'Task Assigned'),
        (TASK_UPDATED, 'Task Updated'),
        (TASK_COMPLETED, 'Task Completed'),
        (MEETING_SCHEDULED, 'Meeting Scheduled'),
        (MEETING_UPDATED, 'Meeting Updated'),
        (MEETING_CANCELLED, 'Meeting Cancelled'),
        (DOCUMENT_SHARED, 'Document Shared'),
        (DOCUMENT_COMMENTED, 'Document Commented'),
    ]
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    notification_type = models.CharField(max_length=50, choices=NOTIFICATION_TYPES)
    title = models.CharField(max_length=255)
    message = models.TextField()
    related_object_id = models.PositiveIntegerField(null=True, blank=True)
    related_object_type = models.CharField(max_length=50, blank=True)
    url = models.CharField(max_length=255, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.get_notification_type_display()} for {self.user}"
    
    def mark_as_read(self):
        """Mark notification as read"""
        self.is_read = True
        self.save()
    
    @classmethod
    def create_notification(cls, user, notification_type, title, message, related_object=None, url=None):
        """
        Create a new notification
        
        Args:
            user: User to notify
            notification_type: Type of notification
            title: Notification title
            message: Notification message
            related_object: Related model instance (optional)
            url: URL to redirect to when clicked (optional)
        
        Returns:
            Notification instance
        """
        related_object_id = None
        related_object_type = ''
        
        if related_object:
            related_object_id = related_object.id
            related_object_type = related_object.__class__.__name__
            
            # If no URL is provided but we have a related object, try to generate one
            if not url:
                try:
                    if hasattr(related_object, 'get_absolute_url'):
                        url = related_object.get_absolute_url()
                except:
                    pass
        
        return cls.objects.create(
            user=user,
            notification_type=notification_type,
            title=title,
            message=message,
            related_object_id=related_object_id,
            related_object_type=related_object_type,
            url=url or ''
        )
