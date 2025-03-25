from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from datetime import timedelta
from .forms import (
    CustomUserCreationForm, 
    ManagerRegistrationForm,
    CustomAuthenticationForm, 
    UserProfileForm, 
    CustomPasswordChangeForm,
    WorkingTimeForm
)
from .models import CustomUser, WorkingTime

def register(request):
    """User registration view"""
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, 'Account created successfully!')
            return redirect('dashboard')
    else:
        form = CustomUserCreationForm()
    
    return render(request, 'accounts/register.html', {'form': form})

def register_manager(request):
    """Manager registration view"""
    # Only allow HR or admin users to register managers
    if not request.user.is_authenticated or not request.user.is_hr_or_admin():
        messages.error(request, 'You do not have permission to register managers.')
        return redirect('dashboard' if request.user.is_authenticated else 'login')
    
    if request.method == 'POST':
        form = ManagerRegistrationForm(request.POST)
        if form.is_valid():
            manager = form.save()
            messages.success(request, f'Manager account for {manager.get_full_name()} created successfully!')
            return redirect('dashboard')
    else:
        form = ManagerRegistrationForm()
    
    return render(request, 'accounts/register_manager.html', {'form': form})

def user_login(request):
    """User login view"""
    if request.method == 'POST':
        form = CustomAuthenticationForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=password)
            if user is not None:
                login(request, user)
                messages.success(request, f'Welcome back, {user.get_full_name() or user.username}!')
                return redirect('dashboard')
    else:
        form = CustomAuthenticationForm()
    
    return render(request, 'accounts/login.html', {'form': form})

@login_required
def dashboard(request):
    """User dashboard view"""
    # If user is a manager, redirect to manager dashboard
    if request.user.is_manager_or_above():
        return redirect('manager_dashboard')
    
    # Get pending leave requests
    pending_leave_requests = request.user.leave_requests.filter(
        status='pending'
    )[:5]
    
    # Get pending WFH requests
    pending_wfh_requests = request.user.wfh_requests.filter(
        status='pending'
    )[:5]
    
    # Get assigned tasks
    assigned_tasks = request.user.assigned_tasks.exclude(
        status='completed'
    ).order_by('deadline')[:5]
    
    # Get upcoming meetings
    today = timezone.now()
    upcoming_meetings = request.user.meetings.filter(
        start_time__gte=today
    ).order_by('start_time')[:5]
    
    # Get today's working time
    today_date = timezone.now().date()
    try:
        today_working_time = WorkingTime.objects.get(user=request.user, date=today_date)
    except WorkingTime.DoesNotExist:
        today_working_time = None
    
    # Calculate week hours
    week_start = today_date - timedelta(days=today_date.weekday())
    week_end = week_start + timedelta(days=6)
    week_times = WorkingTime.objects.filter(
        user=request.user,
        date__range=[week_start, week_end]
    )
    week_hours = sum(wt.hours_worked for wt in week_times)
    
    context = {
        'pending_leave_requests': pending_leave_requests,
        'pending_wfh_requests': pending_wfh_requests,
        'assigned_tasks': assigned_tasks,
        'upcoming_meetings': upcoming_meetings,
        'today_working_time': today_working_time,
        'week_hours': week_hours,
    }
    
    return render(request, 'accounts/dashboard.html', context)

@login_required
def manager_dashboard(request):
    """Manager dashboard view"""
    if not request.user.is_manager_or_above():
        messages.error(request, 'You do not have permission to access the manager dashboard.')
        return redirect('dashboard')
    
    # Get employees managed by this user
    employees = request.user.get_managed_employees()
    
    # Get pending leave requests to process
    pending_leave_requests = request.user.get_pending_leave_requests()[:5]
    
    # Get pending WFH requests to process
    pending_wfh_requests = request.user.get_pending_wfh_requests()[:5]
    
    # Get tasks created by this user
    created_tasks = request.user.created_tasks.all()[:5]
    
    context = {
        'employees': employees,
        'pending_leave_requests': pending_leave_requests,
        'pending_wfh_requests': pending_wfh_requests,
        'created_tasks': created_tasks,
    }
    
    return render(request, 'accounts/manager_dashboard.html', context)

@login_required
def profile(request):
    """User profile view"""
    if request.method == 'POST':
        form = UserProfileForm(request.POST, request.FILES, instance=request.user)
        if form.is_valid():
            form.save()
            messages.success(request, 'Profile updated successfully!')
            return redirect('profile')
    else:
        form = UserProfileForm(instance=request.user)
    
    return render(request, 'accounts/profile.html', {'form': form})

@login_required
def change_password(request):
    """Change password view"""
    if request.method == 'POST':
        form = CustomPasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Your password was successfully updated!')
            return redirect('profile')
    else:
        form = CustomPasswordChangeForm(request.user)
    
    return render(request, 'accounts/change_password.html', {'form': form})

@login_required
def track_working_time(request):
    """Track working time view"""
    today = timezone.now().date()
    
    # Check if working time already exists for today
    try:
        working_time = WorkingTime.objects.get(user=request.user, date=today)
    except WorkingTime.DoesNotExist:
        working_time = None
    
    if request.method == 'POST':
        form = WorkingTimeForm(request.POST, instance=working_time)
        if form.is_valid():
            working_time = form.save(commit=False)
            working_time.user = request.user
            working_time.date = today
            working_time.save()
            messages.success(request, 'Working time logged successfully!')
            return redirect('dashboard')
    else:
        form = WorkingTimeForm(instance=working_time)
    
    return render(request, 'accounts/track_working_time.html', {
        'form': form,
        'today': today
    })
