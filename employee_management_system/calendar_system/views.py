from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from django.http import JsonResponse
from .models import Meeting
from .forms import MeetingForm
from leave_system.models import LeaveRequest
from wfh_system.models import WFHRequest

@login_required
def calendar_view(request):
    """View for displaying the calendar with all events"""
    # Get user's meetings
    meetings = Meeting.objects.filter(participants=request.user)
    
    # Get user's leave requests
    leave_requests = LeaveRequest.objects.filter(user=request.user, status='approved')
    
    # Get user's WFH requests
    wfh_requests = WFHRequest.objects.filter(user=request.user, status='approved')
    
    # Format events for calendar
    events = []
    
    # Add meetings to events
    for meeting in meetings:
        events.append({
            'id': f'meeting_{meeting.id}',
            'title': meeting.title,
            'start': meeting.start_time.isoformat(),
            'end': meeting.end_time.isoformat(),
            'url': f'/calendar/meetings/{meeting.id}/',
            'backgroundColor': '#007bff',  # Blue
            'borderColor': '#007bff',
        })
    
    # Add leave requests to events
    for leave in leave_requests:
        events.append({
            'id': f'leave_{leave.id}',
            'title': f'Leave: {leave.get_leave_type_display()}',
            'start': leave.start_date.isoformat(),
            'end': leave.end_date.isoformat(),
            'url': f'/leave/{leave.id}/',
            'backgroundColor': '#dc3545',  # Red
            'borderColor': '#dc3545',
            'allDay': True,
        })
    
    # Add WFH requests to events
    for wfh in wfh_requests:
        events.append({
            'id': f'wfh_{wfh.id}',
            'title': 'Work From Home',
            'start': wfh.date.isoformat(),
            'url': f'/wfh/{wfh.id}/',
            'backgroundColor': '#28a745',  # Green
            'borderColor': '#28a745',
            'allDay': True,
        })
    
    return render(request, 'calendar_system/calendar.html', {
        'events': events
    })

@login_required
def meeting_list(request):
    """View for listing meetings"""
    # Get meetings where user is a participant
    meetings = Meeting.objects.filter(participants=request.user)
    
    # Get meetings organized by the user
    organized_meetings = Meeting.objects.filter(organizer=request.user)
    
    return render(request, 'calendar_system/meeting_list.html', {
        'meetings': meetings,
        'organized_meetings': organized_meetings
    })

@login_required
def meeting_create(request):
    """View for creating a new meeting"""
    if request.method == 'POST':
        form = MeetingForm(request.POST)
        if form.is_valid():
            meeting = form.save(commit=False)
            meeting.organizer = request.user
            meeting.save()
            
            # Add participants
            form.save_m2m()
            
            # Add organizer as participant if not already included
            if request.user not in meeting.participants.all():
                meeting.participants.add(request.user)
            
            messages.success(request, 'Meeting created successfully!')
            return redirect('meeting_list')
    else:
        form = MeetingForm()
    
    return render(request, 'calendar_system/meeting_form.html', {
        'form': form,
        'title': 'Create Meeting'
    })

@login_required
def meeting_detail(request, pk):
    """View for viewing meeting details"""
    meeting = get_object_or_404(Meeting, pk=pk)
    
    # Check if user is a participant
    if request.user != meeting.organizer and request.user not in meeting.participants.all():
        messages.error(request, 'You do not have permission to view this meeting.')
        return redirect('meeting_list')
    
    return render(request, 'calendar_system/meeting_detail.html', {
        'meeting': meeting
    })

@login_required
def meeting_update(request, pk):
    """View for updating a meeting"""
    meeting = get_object_or_404(Meeting, pk=pk)
    
    # Check if user is the organizer
    if request.user != meeting.organizer:
        messages.error(request, 'You do not have permission to update this meeting.')
        return redirect('meeting_list')
    
    if request.method == 'POST':
        form = MeetingForm(request.POST, instance=meeting)
        if form.is_valid():
            form.save()
            
            # Add organizer as participant if not already included
            if request.user not in meeting.participants.all():
                meeting.participants.add(request.user)
            
            messages.success(request, 'Meeting updated successfully!')
            return redirect('meeting_detail', pk=meeting.pk)
    else:
        form = MeetingForm(instance=meeting)
    
    return render(request, 'calendar_system/meeting_form.html', {
        'form': form,
        'title': 'Update Meeting',
        'meeting': meeting
    })

@login_required
def meeting_delete(request, pk):
    """View for deleting a meeting"""
    meeting = get_object_or_404(Meeting, pk=pk)
    
    # Check if user is the organizer
    if request.user != meeting.organizer:
        messages.error(request, 'You do not have permission to delete this meeting.')
        return redirect('meeting_list')
    
    if request.method == 'POST':
        meeting.delete()
        messages.success(request, 'Meeting deleted successfully!')
        return redirect('meeting_list')
    
    return render(request, 'calendar_system/meeting_confirm_delete.html', {
        'meeting': meeting
    })
