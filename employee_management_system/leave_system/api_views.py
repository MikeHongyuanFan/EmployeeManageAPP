from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import LeaveRequest
from .serializers import LeaveRequestSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def leave_request_list(request):
    """
    List all leave requests or create a new leave request
    """
    if request.method == 'GET':
        # For employees, show only their requests
        # For managers, show all requests from their team
        if hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above():
            leave_requests = LeaveRequest.objects.filter(
                employee__in=request.user.get_managed_employees()
            )
        else:
            leave_requests = LeaveRequest.objects.filter(employee=request.user)
            
        serializer = LeaveRequestSerializer(leave_requests, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Create a new leave request
        data = request.data.copy()
        data['employee'] = request.user.id  # Set the employee to the current user
        
        serializer = LeaveRequestSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def leave_request_detail(request, pk):
    """
    Retrieve, update or delete a leave request
    """
    try:
        leave_request = LeaveRequest.objects.get(pk=pk)
    except LeaveRequest.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Check permissions
    if hasattr(request.user, 'is_manager_or_above') and not request.user.is_manager_or_above() and leave_request.employee != request.user:
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method == 'GET':
        serializer = LeaveRequestSerializer(leave_request)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        # Only managers can update status
        if 'status' in request.data and hasattr(request.user, 'is_manager_or_above') and not request.user.is_manager_or_above():
            return Response({'error': 'Only managers can update status'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        # Employees can only update their own requests and only if pending
        if leave_request.employee == request.user and leave_request.status != 'pending':
            return Response({'error': 'Can only edit pending requests'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        
        serializer = LeaveRequestSerializer(leave_request, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Only allow deletion of pending requests
        if leave_request.status != 'pending':
            return Response({'error': 'Can only delete pending requests'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        
        leave_request.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
