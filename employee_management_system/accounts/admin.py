from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, WorkingTime

class CustomUserAdmin(UserAdmin):
    """Admin configuration for CustomUser model"""
    list_display = ('username', 'email', 'first_name', 'last_name', 'user_type', 'department')
    list_filter = ('user_type', 'department', 'is_staff', 'is_active')
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name', 'email', 'phone_number', 'address', 'emergency_contact', 'date_of_birth', 'profile_picture')}),
        ('Work Info', {'fields': ('user_type', 'department', 'manager', 'hire_date')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2', 'first_name', 'last_name', 'user_type', 'department'),
        }),
    )
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('username',)
    filter_horizontal = ('groups', 'user_permissions',)

class WorkingTimeAdmin(admin.ModelAdmin):
    """Admin configuration for WorkingTime model"""
    list_display = ('user', 'date', 'hours_worked', 'description', 'created_at')
    list_filter = ('date', 'user')
    search_fields = ('user__username', 'user__email', 'description')
    date_hierarchy = 'date'
    readonly_fields = ('created_at', 'updated_at')

# Register models
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(WorkingTime, WorkingTimeAdmin)
