from django.contrib import admin
from .models import Meeting

@admin.register(Meeting)
class MeetingAdmin(admin.ModelAdmin):
    list_display = ('title', 'organizer', 'start_time', 'end_time', 'location', 'created_at')
    list_filter = ('start_time', 'organizer')
    search_fields = ('title', 'description', 'organizer__username', 'location')
    date_hierarchy = 'start_time'
    
    filter_horizontal = ('participants',)
    
    fieldsets = (
        (None, {
            'fields': ('title', 'description', 'organizer')
        }),
        ('Schedule', {
            'fields': ('start_time', 'end_time', 'location')
        }),
        ('Participants', {
            'fields': ('participants',)
        }),
    )
    
    readonly_fields = ('created_at',)
