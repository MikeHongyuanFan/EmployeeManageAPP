from django.contrib import admin
from .models import LeaveRequest, LeaveBalance

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ('user', 'leave_type', 'start_date', 'end_date', 'status', 'created_at')
    list_filter = ('leave_type', 'status', 'start_date')
    search_fields = ('user__username', 'user__email', 'reason')
    date_hierarchy = 'start_date'
    
    fieldsets = (
        (None, {
            'fields': ('user', 'leave_type', 'start_date', 'end_date', 'reason')
        }),
        ('Status', {
            'fields': ('status', 'processed_by', 'processed_at', 'rejection_reason')
        }),
    )
    
    readonly_fields = ('created_at', 'processed_at')

@admin.register(LeaveBalance)
class LeaveBalanceAdmin(admin.ModelAdmin):
    list_display = ('user', 'annual_leave_balance', 'sick_leave_balance', 'personal_leave_balance')
    search_fields = ('user__username', 'user__email')
    
    fieldsets = (
        (None, {
            'fields': ('user',)
        }),
        ('Leave Balances', {
            'fields': ('annual_leave_balance', 'sick_leave_balance', 'personal_leave_balance')
        }),
    )
