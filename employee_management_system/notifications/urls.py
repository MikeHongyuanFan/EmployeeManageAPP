from django.urls import path
from . import views

urlpatterns = [
    path('', views.notification_list, name='notification_list'),
    path('<int:pk>/read/', views.mark_as_read, name='mark_notification_read'),
    path('mark-all-read/', views.mark_all_as_read, name='mark_all_notifications_read'),
    path('unread-count/', views.get_unread_count, name='get_unread_count'),
    path('recent/', views.get_recent_notifications, name='get_recent_notifications'),
]
