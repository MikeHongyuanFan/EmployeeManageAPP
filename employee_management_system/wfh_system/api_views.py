from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import WFHRequest
from .serializers import WFHRequestSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def wfh_request_list(request):
    """
    List all WFH requests or create a new WFH request
    """
    if request.method == 'GET':
        # For employees, show only their requests
        # For managers, show all requests from their team
        if hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above():
            wfh_requests = WFHRequest.objects.filter(
                user__in=request.user.get_managed_employees()
            )
        else:
            wfh_requests = WFHRequest.objects.filter(user=request.user)
            
        serializer = WFHRequestSerializer(wfh_requests, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Create a new WFH request
        data = request.data.copy()
        data['user'] = request.user.id  # Set the user to the current user
        
        serializer = WFHRequestSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def wfh_request_detail(request, pk):
    """
    Retrieve, update or delete a WFH request
    """
    try:
        wfh_request = WFHRequest.objects.get(pk=pk)
    except WFHRequest.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Check permissions
    if hasattr(request.user, 'is_manager_or_above') and not request.user.is_manager_or_above() and wfh_request.user != request.user:
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method == 'GET':
        serializer = WFHRequestSerializer(wfh_request)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        # Only managers can update status
        if 'status' in request.data and hasattr(request.user, 'is_manager_or_above') and not request.user.is_manager_or_above():
            return Response({'error': 'Only managers can update status'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        # Employees can only update their own requests and only if pending
        if wfh_request.user == request.user and wfh_request.status != 'pending':
            return Response({'error': 'Can only edit pending requests'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        
        serializer = WFHRequestSerializer(wfh_request, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Only allow deletion of pending requests
        if wfh_request.status != 'pending':
            return Response({'error': 'Can only delete pending requests'}, 
                           status=status.HTTP_400_BAD_REQUEST)
        
        wfh_request.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
