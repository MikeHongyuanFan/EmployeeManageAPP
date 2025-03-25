from rest_framework import serializers
from .models import WFHRequest

class WFHRequestSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    
    class Meta:
        model = WFHRequest
        fields = ['id', 'user', 'user_name', 'date', 'reason', 'status', 
                 'processed_by', 'processed_at', 'rejection_reason', 'created_at']
    
    def get_user_name(self, obj):
        return obj.user.get_full_name() or obj.user.username
