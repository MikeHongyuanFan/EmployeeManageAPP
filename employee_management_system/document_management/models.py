from django.db import models
from django.conf import settings
from django.urls import reverse

def document_upload_path(instance, filename):
    """Generate file path for document uploads"""
    return f'documents/{instance.uploaded_by.username}/{filename}'

class DocumentCategory(models.Model):
    """Model for document categories"""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    class Meta:
        verbose_name_plural = 'Document Categories'
        ordering = ['name']
    
    def __str__(self):
        return self.name

class Document(models.Model):
    """Model for documents"""
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    file = models.FileField(upload_to=document_upload_path)
    category = models.ForeignKey(
        DocumentCategory,
        on_delete=models.SET_NULL,
        null=True,
        related_name='documents'
    )
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='uploaded_documents'
    )
    shared_with = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='shared_documents',
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return self.title
    
    def get_absolute_url(self):
        return reverse('document_detail', args=[self.id])
    
    @property
    def file_extension(self):
        """Get file extension"""
        name = self.file.name
        return name.split('.')[-1] if '.' in name else ''
    
    @property
    def is_image(self):
        """Check if document is an image"""
        image_extensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg']
        return self.file_extension.lower() in image_extensions
    
    @property
    def is_pdf(self):
        """Check if document is a PDF"""
        return self.file_extension.lower() == 'pdf'
    
    @property
    def is_document(self):
        """Check if document is a text document"""
        doc_extensions = ['doc', 'docx', 'txt', 'rtf', 'odt']
        return self.file_extension.lower() in doc_extensions
    
    @property
    def is_spreadsheet(self):
        """Check if document is a spreadsheet"""
        sheet_extensions = ['xls', 'xlsx', 'csv', 'ods']
        return self.file_extension.lower() in sheet_extensions

class DocumentComment(models.Model):
    """Model for comments on documents"""
    document = models.ForeignKey(Document, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return f"Comment on {self.document} by {self.user}"
