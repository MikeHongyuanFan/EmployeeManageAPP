from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse

def root_view(request):
    return JsonResponse({
        'message': 'Employee Management System API',
        'endpoints': {
            'API Root': '/api/',
            'Admin': '/admin/',
            'API Test': '/api/test/',
            'Login': '/api/login/',
            'Logout': '/api/logout/',
            'Profile': '/api/profile/',
            'Employees': '/api/employees/',
            'Leave Requests': '/api/leave-requests/',
            'WFH Requests': '/api/wfh-requests/',
            'Tasks': '/api/tasks/',
            'Meetings': '/api/meetings/',
            'Documents': '/api/documents/',
            'Working Hours': '/api/working-hours/',
        }
    })

urlpatterns = [
    path('', root_view, name='root'),
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api-auth/', include('rest_framework.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
