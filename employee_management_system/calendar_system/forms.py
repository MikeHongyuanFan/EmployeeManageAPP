from django import forms
from django.utils import timezone
from .models import Meeting

class MeetingForm(forms.ModelForm):
    """Form for creating and updating meetings"""
    class Meta:
        model = Meeting
        fields = ['title', 'description', 'start_time', 'end_time', 'location', 'participants']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
            'start_time': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'form-control'}),
            'end_time': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'form-control'}),
            'location': forms.TextInput(attrs={'class': 'form-control'}),
            'participants': forms.SelectMultiple(attrs={'class': 'form-control select2'}),
        }
    
    def clean(self):
        cleaned_data = super().clean()
        start_time = cleaned_data.get('start_time')
        end_time = cleaned_data.get('end_time')
        
        # Check if end time is before start time
        if start_time and end_time and end_time <= start_time:
            raise forms.ValidationError("End time must be after start time.")
        
        # Check if start time is in the past
        if start_time and start_time < timezone.now():
            raise forms.ValidationError("Start time cannot be in the past.")
