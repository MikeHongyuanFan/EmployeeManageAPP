from django.contrib import admin
from .models import WFHRequest

@admin.register(WFHRequest)
class WFHRequestAdmin(admin.ModelAdmin):
    list_display = ('user', 'date', 'status', 'created_at')
    list_filter = ('status', 'date')
    search_fields = ('user__username', 'user__email', 'reason')
    date_hierarchy = 'date'
    
    fieldsets = (
        (None, {
            'fields': ('user', 'date', 'reason')
        }),
        ('Status', {
            'fields': ('status', 'processed_by', 'processed_at', 'rejection_reason')
        }),
    )
    
    readonly_fields = ('created_at', 'processed_at')
