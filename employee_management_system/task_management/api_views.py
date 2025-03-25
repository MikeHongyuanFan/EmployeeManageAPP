from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Task
from .serializers import TaskSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def task_list(request):
    """
    List all tasks or create a new task
    """
    if request.method == 'GET':
        # For employees, show tasks assigned to them
        # For managers, show tasks they assigned and tasks assigned to their team
        if hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above():
            tasks = Task.objects.filter(
                assigned_to__in=request.user.get_managed_employees()
            ) | Task.objects.filter(assigned_by=request.user)
        else:
            tasks = Task.objects.filter(assigned_to=request.user)
            
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Create a new task
        data = request.data.copy()
        data['assigned_by'] = request.user.id  # Set the assigner to the current user
        
        # Only managers can assign tasks to others
        if 'assigned_to' in data and data['assigned_to'] != request.user.id:
            if not (hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above()):
                return Response({'error': 'Only managers can assign tasks to others'}, 
                               status=status.HTTP_403_FORBIDDEN)
        
        serializer = TaskSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def task_detail(request, pk):
    """
    Retrieve, update or delete a task
    """
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Check permissions
    is_manager = hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above()
    is_assigned_to = task.assigned_to == request.user
    is_assigned_by = task.assigned_by == request.user
    
    if not (is_manager or is_assigned_to or is_assigned_by):
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method == 'GET':
        serializer = TaskSerializer(task)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        # Only the assigner or a manager can update task details
        # The assignee can only update the status
        if not (is_manager or is_assigned_by) and not (is_assigned_to and set(request.data.keys()).issubset({'status'})):
            return Response({'error': 'Permission denied'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        serializer = TaskSerializer(task, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Only the assigner or a manager can delete a task
        if not (is_manager or is_assigned_by):
            return Response({'error': 'Permission denied'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        task.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
