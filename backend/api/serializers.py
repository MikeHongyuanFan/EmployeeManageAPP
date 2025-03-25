from rest_framework import serializers
from django.contrib.auth.models import User
from .models import LeaveBalance, LeaveRequest, WFHRequest, Task, Meeting, Document, WorkingHours

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_staff']
        read_only_fields = ['id', 'is_staff']

class LeaveBalanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = LeaveBalance
        fields = ['id', 'user', 'annual_leave', 'sick_leave', 'personal_leave']
        read_only_fields = ['id', 'user']

class LeaveRequestSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    
    class Meta:
        model = LeaveRequest
        fields = ['id', 'user', 'user_name', 'leave_type', 'start_date', 'end_date', 'reason', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_user_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"

class WFHRequestSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    
    class Meta:
        model = WFHRequest
        fields = ['id', 'user', 'user_name', 'date', 'reason', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_user_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"

class TaskSerializer(serializers.ModelSerializer):
    assigned_to_name = serializers.SerializerMethodField()
    assigned_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'assigned_to', 'assigned_to_name', 'assigned_by', 'assigned_by_name', 'priority', 'status', 'due_date', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_assigned_to_name(self, obj):
        return f"{obj.assigned_to.first_name} {obj.assigned_to.last_name}"
    
    def get_assigned_by_name(self, obj):
        return f"{obj.assigned_by.first_name} {obj.assigned_by.last_name}"

class MeetingSerializer(serializers.ModelSerializer):
    organizer_name = serializers.SerializerMethodField()
    participants_names = serializers.SerializerMethodField()
    
    class Meta:
        model = Meeting
        fields = ['id', 'title', 'description', 'organizer', 'organizer_name', 'participants', 'participants_names', 'date', 'start_time', 'end_time', 'location', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_organizer_name(self, obj):
        return f"{obj.organizer.first_name} {obj.organizer.last_name}"
    
    def get_participants_names(self, obj):
        return [f"{user.first_name} {user.last_name}" for user in obj.participants.all()]

class DocumentSerializer(serializers.ModelSerializer):
    uploaded_by_name = serializers.SerializerMethodField()
    shared_with_names = serializers.SerializerMethodField()
    
    class Meta:
        model = Document
        fields = ['id', 'title', 'file', 'uploaded_by', 'uploaded_by_name', 'shared_with', 'shared_with_names', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_uploaded_by_name(self, obj):
        return f"{obj.uploaded_by.first_name} {obj.uploaded_by.last_name}"
    
    def get_shared_with_names(self, obj):
        return [f"{user.first_name} {user.last_name}" for user in obj.shared_with.all()]

class WorkingHoursSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    
    class Meta:
        model = WorkingHours
        fields = ['id', 'user', 'user_name', 'date', 'clock_in', 'clock_out', 'work_type']
        read_only_fields = ['id']
    
    def get_user_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"
