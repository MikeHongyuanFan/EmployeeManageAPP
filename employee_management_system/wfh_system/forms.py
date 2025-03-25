from django import forms
from django.utils import timezone
from .models import WFHRequest

class WFHRequestForm(forms.ModelForm):
    """Form for creating WFH requests"""
    class Meta:
        model = WFHRequest
        fields = ['date', 'reason']
        widgets = {
            'date': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
            'reason': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
        }
    
    def clean_date(self):
        date = self.cleaned_data.get('date')
        
        # Check if date is in the past
        if date and date < timezone.now().date():
            raise forms.ValidationError("Date cannot be in the past.")
        
        return date

class WFHRequestProcessForm(forms.Form):
    """Form for processing WFH requests"""
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
