from django import forms
from django.utils import timezone
from .models import Task, TaskComment

class TaskForm(forms.ModelForm):
    """Form for creating and updating tasks"""
    class Meta:
        model = Task
        fields = ['title', 'description', 'assigned_to', 'priority', 'deadline', 'is_personal']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
            'assigned_to': forms.Select(attrs={'class': 'form-control'}),
            'priority': forms.Select(attrs={'class': 'form-control'}),
            'deadline': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'form-control'}),
            'is_personal': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }
    
    def clean_deadline(self):
        deadline = self.cleaned_data.get('deadline')
        
        # Check if deadline is in the past
        if deadline and deadline < timezone.now():
            raise forms.ValidationError("Deadline cannot be in the past.")
        
        return deadline

class TaskCommentForm(forms.ModelForm):
    """Form for adding comments to tasks"""
    class Meta:
        model = TaskComment
        fields = ['comment']
        widgets = {
            'comment': forms.Textarea(attrs={'rows': 2, 'class': 'form-control'}),
        }
