"""
URL Configuration for employee_management_system
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('accounts.urls')),
    path('leave/', include('leave_system.urls')),
    path('wfh/', include('wfh_system.urls')),
    path('calendar/', include('calendar_system.urls')),
    path('tasks/', include('task_management.urls')),
    path('documents/', include('document_management.urls')),
    path('api/', include('accounts.api_urls')),
    path('api/', include('leave_system.api_urls')),
    path('api/', include('wfh_system.api_urls')),
    path('api/', include('task_management.api_urls')),
    path('api/', include('calendar_system.api_urls')),
    path('api/', include('document_management.api_urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
