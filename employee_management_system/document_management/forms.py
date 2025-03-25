from django import forms
from django.contrib.auth import get_user_model
from .models import Document, DocumentCategory, DocumentComment

User = get_user_model()

class DocumentForm(forms.ModelForm):
    """Form for uploading and updating documents"""
    class Meta:
        model = Document
        fields = ['title', 'description', 'file', 'category']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
            'file': forms.FileInput(attrs={'class': 'form-control'}),
            'category': forms.Select(attrs={'class': 'form-control'}),
        }

class DocumentShareForm(forms.Form):
    """Form for sharing documents with other users"""
    users = forms.ModelMultipleChoiceField(
        queryset=User.objects.all(),
        widget=forms.SelectMultiple(attrs={'class': 'form-control select2'}),
        required=False
    )
    
    def __init__(self, *args, **kwargs):
        document = kwargs.pop('document', None)
        super().__init__(*args, **kwargs)
        
        if document:
            self.fields['users'].initial = document.shared_with.all()

class DocumentCommentForm(forms.ModelForm):
    """Form for adding comments to documents"""
    class Meta:
        model = DocumentComment
        fields = ['comment']
        widgets = {
            'comment': forms.Textarea(attrs={'rows': 2, 'class': 'form-control'}),
        }

class DocumentCategoryForm(forms.ModelForm):
    """Form for creating and updating document categories"""
    class Meta:
        model = DocumentCategory
        fields = ['name', 'description']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control'}),
            'description': forms.Textarea(attrs={'rows': 3, 'class': 'form-control'}),
        }
