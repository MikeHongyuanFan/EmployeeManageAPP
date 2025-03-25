from rest_framework import serializers
from .models import CustomUser, Employee, Department

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_staff', 'user_type', 'department']

class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = ['id', 'name', 'description']

class EmployeeSerializer(serializers.ModelSerializer):
    department_name = serializers.SerializerMethodField()
    manager_name = serializers.SerializerMethodField()
    user_details = UserSerializer(source='user', read_only=True)
    
    class Meta:
        model = Employee
        fields = ['id', 'user', 'user_details', 'employee_id', 'department', 
                  'department_name', 'position', 'manager', 'manager_name', 
                  'date_joined', 'phone', 'address', 'emergency_contact', 
                  'profile_picture']
    
    def get_department_name(self, obj):
        if obj.department:
            return obj.department.name
        return ""
    
    def get_manager_name(self, obj):
        if obj.manager and obj.manager.user:
            return f"{obj.manager.user.get_full_name()}"
        return ""
