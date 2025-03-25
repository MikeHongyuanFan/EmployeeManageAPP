from django.contrib import admin
from .models import Task, TaskComment

@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ('title', 'created_by', 'assigned_to', 'priority', 'status', 'deadline', 'created_at')
    list_filter = ('status', 'priority', 'is_personal', 'created_at')
    search_fields = ('title', 'description', 'created_by__username', 'assigned_to__username')
    date_hierarchy = 'created_at'
    
    fieldsets = (
        (None, {
            'fields': ('title', 'description', 'created_by', 'assigned_to')
        }),
        ('Details', {
            'fields': ('priority', 'status', 'deadline', 'is_personal')
        }),
    )
    
    readonly_fields = ('created_at',)

@admin.register(TaskComment)
class TaskCommentAdmin(admin.ModelAdmin):
    list_display = ('task', 'user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('task__title', 'user__username', 'comment')
    date_hierarchy = 'created_at'
    
    readonly_fields = ('created_at',)
