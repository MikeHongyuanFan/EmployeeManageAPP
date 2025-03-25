from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from .models import CustomUser, Employee
from .serializers import UserSerializer, EmployeeSerializer

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """
    User login and token generation
    """
    username = request.data.get('username')
    password = request.data.get('password')
    
    if not username or not password:
        return Response({'error': 'Please provide both username and password'}, 
                       status=status.HTTP_400_BAD_REQUEST)
    
    user = authenticate(username=username, password=password)
    
    if not user:
        return Response({'error': 'Invalid credentials'}, 
                       status=status.HTTP_401_UNAUTHORIZED)
    
    # Get or create token
    token, created = Token.objects.get_or_create(user=user)
    
    # Get employee data
    try:
        employee = Employee.objects.get(user=user)
        employee_data = EmployeeSerializer(employee).data
    except Employee.DoesNotExist:
        employee_data = {}
    
    return Response({
        'token': token.key,
        'user_id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'is_staff': user.is_staff,
        'employee': employee_data
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    """
    User logout and token deletion
    """
    try:
        request.user.auth_token.delete()
        return Response({'message': 'Successfully logged out'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    """
    Get user profile information
    """
    user = request.user
    user_data = UserSerializer(user).data
    
    try:
        employee = Employee.objects.get(user=user)
        employee_data = EmployeeSerializer(employee).data
    except Employee.DoesNotExist:
        employee_data = {}
    
    return Response({
        'user': user_data,
        'employee': employee_data
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def employees_list(request):
    """
    Get list of employees (for managers only)
    """
    # Check if user is a manager
    if not hasattr(request.user, 'is_manager_or_above') or not request.user.is_manager_or_above():
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    # Get employees managed by this manager
    employees = request.user.get_managed_employees()
    serializer = EmployeeSerializer(employees, many=True)
    
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([AllowAny])
def test(request):
    """
    Test endpoint to check if API is working
    """
    return Response({'message': 'API is working!'}, status=status.HTTP_200_OK)
