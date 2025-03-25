from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.core.paginator import Paginator

from .models import Notification

@login_required
def notification_list(request):
    """Display all notifications for the current user"""
    notifications = request.user.notifications.all()
    
    # Paginate results
    paginator = Paginator(notifications, 10)  # Show 10 notifications per page
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    # Count unread notifications
    unread_count = notifications.filter(is_read=False).count()
    
    context = {
        'page_obj': page_obj,
        'unread_count': unread_count
    }
    
    return render(request, 'notifications/notification_list.html', context)

@login_required
@require_POST
def mark_as_read(request, pk):
    """Mark a notification as read"""
    notification = get_object_or_404(Notification, pk=pk, user=request.user)
    notification.mark_as_read()
    
    # If AJAX request, return JSON response
    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        return JsonResponse({'status': 'success'})
    
    # If notification has a URL, redirect to it
    if notification.url:
        return redirect(notification.url)
    
    # Otherwise redirect back to notifications list
    return redirect('notification_list')

@login_required
@require_POST
def mark_all_as_read(request):
    """Mark all notifications as read"""
    request.user.notifications.filter(is_read=False).update(is_read=True)
    
    # If AJAX request, return JSON response
    if request.headers.get('x-requested-with') == 'XMLHttpRequest':
        return JsonResponse({'status': 'success'})
    
    return redirect('notification_list')

@login_required
def get_unread_count(request):
    """Get count of unread notifications (for AJAX)"""
    unread_count = request.user.notifications.filter(is_read=False).count()
    return JsonResponse({'unread_count': unread_count})

@login_required
def get_recent_notifications(request):
    """Get recent notifications (for dropdown)"""
    notifications = request.user.notifications.filter(is_read=False)[:5]
    
    # Format notifications for JSON response
    notification_list = []
    for notification in notifications:
        notification_list.append({
            'id': notification.id,
            'title': notification.title,
            'message': notification.message[:50] + '...' if len(notification.message) > 50 else notification.message,
            'url': notification.url,
            'created_at': notification.created_at.strftime('%b %d, %Y, %H:%M')
        })
    
    return JsonResponse({
        'notifications': notification_list,
        'unread_count': request.user.notifications.filter(is_read=False).count(),
        'has_more': request.user.notifications.filter(is_read=False).count() > 5
    })
