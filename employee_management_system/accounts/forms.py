from django import forms
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm, PasswordChangeForm
from .models import CustomUser, WorkingTime

class CustomUserCreationForm(UserCreationForm):
    """Form for user registration"""
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'first_name', 'last_name', 'password1', 'password2')
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to form fields
        for field_name in self.fields:
            self.fields[field_name].widget.attrs.update({'class': 'form-control'})

class ManagerRegistrationForm(UserCreationForm):
    """Form for manager registration"""
    department = forms.ChoiceField(choices=CustomUser.DEPARTMENTS, required=True)
    
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'first_name', 'last_name', 'department', 'password1', 'password2')
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to form fields
        for field_name in self.fields:
            self.fields[field_name].widget.attrs.update({'class': 'form-control'})
    
    def save(self, commit=True):
        user = super().save(commit=False)
        user.user_type = CustomUser.MANAGER
        if commit:
            user.save()
        return user

class CustomAuthenticationForm(AuthenticationForm):
    """Form for user login"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to form fields
        for field_name in self.fields:
            self.fields[field_name].widget.attrs.update({'class': 'form-control'})

class CustomPasswordChangeForm(PasswordChangeForm):
    """Form for changing password"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to form fields
        for field_name in self.fields:
            self.fields[field_name].widget.attrs.update({'class': 'form-control'})

class UserProfileForm(forms.ModelForm):
    """Form for updating user profile"""
    class Meta:
        model = CustomUser
        fields = ('first_name', 'last_name', 'email', 'phone_number', 
                  'address', 'emergency_contact', 'date_of_birth', 'profile_picture')
        widgets = {
            'date_of_birth': forms.DateInput(attrs={'type': 'date', 'class': 'form-control'}),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Add Bootstrap classes to form fields
        for field_name in self.fields:
            if field_name != 'date_of_birth':  # Already has class from widgets
                self.fields[field_name].widget.attrs.update({'class': 'form-control'})

class WorkingTimeForm(forms.ModelForm):
    """Form for tracking working time"""
    class Meta:
        model = WorkingTime
        fields = ('hours_worked', 'description')
        widgets = {
            'hours_worked': forms.NumberInput(attrs={'class': 'form-control', 'step': '0.25', 'min': '0', 'max': '24'}),
            'description': forms.Textarea(attrs={'class': 'form-control', 'rows': 3}),
        }
