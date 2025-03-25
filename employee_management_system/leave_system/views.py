from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import LeaveRequest, LeaveBalance
from .forms import LeaveRequestForm, LeaveRequestProcessForm

@login_required
def leave_request_list(request):
    """View for listing user's leave requests"""
    leave_requests = LeaveRequest.objects.filter(user=request.user)
    
    return render(request, 'leave_system/leave_request_list.html', {
        'leave_requests': leave_requests
    })

@login_required
def leave_request_create(request):
    """View for creating a new leave request"""
    if request.method == 'POST':
        form = LeaveRequestForm(request.POST)
        if form.is_valid():
            leave_request = form.save(commit=False)
            leave_request.user = request.user
            leave_request.save()
            messages.success(request, 'Leave request submitted successfully!')
            return redirect('leave_request_list')
    else:
        form = LeaveRequestForm()
    
    return render(request, 'leave_system/leave_request_form.html', {
        'form': form,
        'title': 'Create Leave Request'
    })

@login_required
def leave_request_detail(request, pk):
    """View for viewing leave request details"""
    leave_request = get_object_or_404(LeaveRequest, pk=pk, user=request.user)
    
    return render(request, 'leave_system/leave_request_detail.html', {
        'leave_request': leave_request
    })

@login_required
def leave_request_cancel(request, pk):
    """View for cancelling a leave request"""
    leave_request = get_object_or_404(LeaveRequest, pk=pk, user=request.user)
    
    if leave_request.status == 'cancelled':
        messages.error(request, 'This leave request is already cancelled.')
    elif leave_request.status == 'rejected':
        messages.error(request, 'Cannot cancel a rejected leave request.')
    else:
        leave_request.cancel()
        messages.success(request, 'Leave request cancelled successfully!')
    
    return redirect('leave_request_list')

@login_required
def leave_request_process_list(request):
    """View for listing leave requests to process (for managers)"""
    if not request.user.is_manager_or_above():
        messages.error(request, 'You do not have permission to access this page.')
        return redirect('dashboard')
    
    pending_requests = request.user.get_pending_leave_requests()
    
    return render(request, 'leave_system/leave_request_process_list.html', {
        'pending_requests': pending_requests
    })

@login_required
def leave_request_process(request, pk):
    """View for processing a leave request (approve/reject)"""
    if not request.user.is_manager_or_above():
        messages.error(request, 'You do not have permission to access this page.')
        return redirect('dashboard')
    
    leave_request = get_object_or_404(LeaveRequest, pk=pk)
    
    # Check if the user is the manager of the employee
    if leave_request.user.manager != request.user and not request.user.is_hr_or_admin():
        messages.error(request, 'You can only process leave requests for your team members.')
        return redirect('leave_request_process_list')
    
    if request.method == 'POST':
        form = LeaveRequestProcessForm(request.POST)
        if form.is_valid():
            action = form.cleaned_data['action']
            
            if action == 'approved':
                leave_request.approve(request.user)
                messages.success(request, 'Leave request approved successfully!')
            else:
                rejection_reason = form.cleaned_data['rejection_reason']
                leave_request.reject(request.user, rejection_reason)
                messages.success(request, 'Leave request rejected successfully!')
            
            return redirect('leave_request_process_list')
    else:
        form = LeaveRequestProcessForm()
    
    return render(request, 'leave_system/leave_request_process.html', {
        'form': form,
        'leave_request': leave_request
    })

@login_required
def leave_balance(request):
    """View for displaying user's leave balance"""
    try:
        balance = LeaveBalance.objects.get(user=request.user)
    except LeaveBalance.DoesNotExist:
        # Create default balance if it doesn't exist
        balance = LeaveBalance.objects.create(user=request.user)
    
    return render(request, 'leave_system/leave_balance.html', {
        'balance': balance
    })
