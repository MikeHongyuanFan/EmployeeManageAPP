from django.db import models
from django.conf import settings
from django.urls import reverse

class Meeting(models.Model):
    """Model for meetings and events"""
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    organizer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='organized_meetings'
    )
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='meetings'
    )
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    location = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['start_time']
    
    def __str__(self):
        return f"{self.title} ({self.start_time.strftime('%Y-%m-%d %H:%M')})"
    
    def get_absolute_url(self):
        return reverse('meeting_detail', args=[self.id])
    
    def get_duration_minutes(self):
        """Calculate meeting duration in minutes"""
        delta = self.end_time - self.start_time
        return delta.total_seconds() / 60
