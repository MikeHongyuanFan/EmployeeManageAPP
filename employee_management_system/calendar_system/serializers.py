from rest_framework import serializers
from .models import Meeting

class MeetingSerializer(serializers.ModelSerializer):
    organizer_name = serializers.SerializerMethodField()
    attendees_names = serializers.SerializerMethodField()
    
    class Meta:
        model = Meeting
        fields = ['id', 'title', 'description', 'start_time', 'end_time', 
                  'location', 'organizer', 'organizer_name', 'attendees', 
                  'attendees_names', 'created_at', 'updated_at']
    
    def get_organizer_name(self, obj):
        if obj.organizer:
            return f"{obj.organizer.first_name} {obj.organizer.last_name}"
        return ""
    
    def get_attendees_names(self, obj):
        return [f"{attendee.first_name} {attendee.last_name}" for attendee in obj.attendees.all()]
