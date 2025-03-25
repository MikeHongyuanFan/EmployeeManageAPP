from django.contrib import admin
from .models import Document, DocumentCategory, DocumentComment

@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'uploaded_by', 'file_size_display', 'created_at')
    list_filter = ('category', 'created_at')
    search_fields = ('title', 'description', 'uploaded_by__username')
    date_hierarchy = 'created_at'
    
    filter_horizontal = ('shared_with',)
    
    fieldsets = (
        (None, {
            'fields': ('title', 'description', 'category', 'uploaded_by')
        }),
        ('File', {
            'fields': ('file',)
        }),
        ('Sharing', {
            'fields': ('shared_with',)
        }),
    )
    
    readonly_fields = ('created_at',)
    
    def file_size_display(self, obj):
        """Display file size in human-readable format"""
        size_bytes = obj.file.size
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.2f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.2f} TB"
    
    file_size_display.short_description = 'File Size'

@admin.register(DocumentCategory)
class DocumentCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name', 'description')

@admin.register(DocumentComment)
class DocumentCommentAdmin(admin.ModelAdmin):
    list_display = ('document', 'user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('document__title', 'user__username', 'comment')
    date_hierarchy = 'created_at'
    
    readonly_fields = ('created_at',)
