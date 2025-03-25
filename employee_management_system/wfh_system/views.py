from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import WFHRequest
from .forms import WFHRequestForm, WFHRequestProcessForm

@login_required
def wfh_request_list(request):
    """View for listing user's WFH requests"""
    wfh_requests = WFHRequest.objects.filter(user=request.user)
    
    return render(request, 'wfh_system/wfh_request_list.html', {
        'wfh_requests': wfh_requests
    })

@login_required
def wfh_request_create(request):
    """View for creating a new WFH request"""
    if request.method == 'POST':
        form = WFHRequestForm(request.POST)
        if form.is_valid():
            wfh_request = form.save(commit=False)
            wfh_request.user = request.user
            
            # Check if a request already exists for this date
            existing_request = WFHRequest.objects.filter(
                user=request.user,
                date=wfh_request.date
            ).exists()
            
            if existing_request:
                messages.error(request, 'You already have a WFH request for this date.')
            else:
                wfh_request.save()
                messages.success(request, 'WFH request submitted successfully!')
                return redirect('wfh_request_list')
    else:
        form = WFHRequestForm()
    
    return render(request, 'wfh_system/wfh_request_form.html', {
        'form': form,
        'title': 'Create WFH Request'
    })

@login_required
def wfh_request_detail(request, pk):
    """View for viewing WFH request details"""
    wfh_request = get_object_or_404(WFHRequest, pk=pk, user=request.user)
    
    return render(request, 'wfh_system/wfh_request_detail.html', {
        'wfh_request': wfh_request
    })

@login_required
def wfh_request_cancel(request, pk):
    """View for cancelling a WFH request"""
    wfh_request = get_object_or_404(WFHRequest, pk=pk, user=request.user)
    
    if wfh_request.status == 'cancelled':
        messages.error(request, 'This WFH request is already cancelled.')
    elif wfh_request.status == 'rejected':
        messages.error(request, 'Cannot cancel a rejected WFH request.')
    else:
        wfh_request.cancel()
        messages.success(request, 'WFH request cancelled successfully!')
    
    return redirect('wfh_request_list')

@login_required
def wfh_request_process_list(request):
    """View for listing WFH requests to process (for managers)"""
    if not request.user.is_manager_or_above():
        messages.error(request, 'You do not have permission to access this page.')
        return redirect('dashboard')
    
    pending_requests = request.user.get_pending_wfh_requests()
    
    return render(request, 'wfh_system/wfh_request_process_list.html', {
        'pending_requests': pending_requests
    })

@login_required
def wfh_request_process(request, pk):
    """View for processing a WFH request (approve/reject)"""
    if not request.user.is_manager_or_above():
        messages.error(request, 'You do not have permission to access this page.')
        return redirect('dashboard')
    
    wfh_request = get_object_or_404(WFHRequest, pk=pk)
    
    # Check if the user is the manager of the employee
    if wfh_request.user.manager != request.user and not request.user.is_hr_or_admin():
        messages.error(request, 'You can only process WFH requests for your team members.')
        return redirect('wfh_request_process_list')
    
    if request.method == 'POST':
        form = WFHRequestProcessForm(request.POST)
        if form.is_valid():
            action = form.cleaned_data['action']
            
            if action == 'approved':
                wfh_request.approve(request.user)
                messages.success(request, 'WFH request approved successfully!')
            else:
                rejection_reason = form.cleaned_data['rejection_reason']
                wfh_request.reject(request.user, rejection_reason)
                messages.success(request, 'WFH request rejected successfully!')
            
            return redirect('wfh_request_process_list')
    else:
        form = WFHRequestProcessForm()
    
    return render(request, 'wfh_system/wfh_request_process.html', {
        'form': form,
        'wfh_request': wfh_request
    })
