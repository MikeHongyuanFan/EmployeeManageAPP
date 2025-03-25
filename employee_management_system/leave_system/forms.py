from django import forms
from django.utils import timezone
from .models import LeaveRequest

class LeaveRequestForm(forms.ModelForm):
    """Form for creating leave requests"""
    class Meta:
        model = LeaveRequest
        fields = ['leave_type', 'start_date', 'end_date', 'reason']
        widgets = {
            'start_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'end_date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'reason': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
            'leave_type': forms.Select(attrs={'class': 'form-control'}),
        }
    
    def clean(self):
        cleaned_data = super().clean()
        start_date = cleaned_data.get('start_date')
        end_date = cleaned_data.get('end_date')
        
        # Check if end date is before start date
        if start_date and end_date and end_date < start_date:
            raise forms.ValidationError("End date cannot be before start date.")
        
        # Check if start date is in the past
        if start_date and start_date < timezone.now().date():
            raise forms.ValidationError("Start date cannot be in the past.")
        
        return cleaned_data

class LeaveRequestProcessForm(forms.Form):
    """Form for processing leave requests"""
    APPROVE = 'approved'
    REJECT = 'rejected'
    
    ACTIONS = [
        (APPROVE, 'Approve'),
        (REJECT, 'Reject'),
    ]
    
    action = forms.ChoiceField(choices=ACTIONS, widget=forms.RadioSelect(attrs={'class': 'form-check-input'}))
    rejection_reason = forms.CharField(
        widget=forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
        required=False
    )
    
    def clean(self):
        cleaned_data = super().clean()
        action = cleaned_data.get('action')
        rejection_reason = cleaned_data.get('rejection_reason')
        
        # If rejecting, require a reason
        if action == self.REJECT and not rejection_reason:
            raise forms.ValidationError("Please provide a reason for rejection.")
