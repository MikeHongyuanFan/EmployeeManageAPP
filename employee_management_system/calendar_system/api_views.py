from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Meeting
from .serializers import MeetingSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def meeting_list(request):
    """
    List all meetings or create a new meeting
    """
    if request.method == 'GET':
        # Show meetings where the user is an attendee or organizer
        meetings = Meeting.objects.filter(attendees=request.user) | Meeting.objects.filter(organizer=request.user)
        serializer = MeetingSerializer(meetings.distinct(), many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Create a new meeting
        data = request.data.copy()
        data['organizer'] = request.user.id  # Set the organizer to the current user
        
        serializer = MeetingSerializer(data=data)
        if serializer.is_valid():
            meeting = serializer.save()
            # Add the organizer as an attendee if not already included
            if request.user.id not in data.get('attendees', []):
                meeting.attendees.add(request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def meeting_detail(request, pk):
    """
    Retrieve, update or delete a meeting
    """
    try:
        meeting = Meeting.objects.get(pk=pk)
    except Meeting.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Check permissions
    is_organizer = meeting.organizer == request.user
    is_attendee = meeting.attendees.filter(id=request.user.id).exists()
    
    if not (is_organizer or is_attendee):
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method == 'GET':
        serializer = MeetingSerializer(meeting)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        # Only the organizer can update meeting details
        if not is_organizer:
            return Response({'error': 'Only the organizer can update meeting details'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        serializer = MeetingSerializer(meeting, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Only the organizer can delete a meeting
        if not is_organizer:
            return Response({'error': 'Only the organizer can delete a meeting'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        meeting.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
