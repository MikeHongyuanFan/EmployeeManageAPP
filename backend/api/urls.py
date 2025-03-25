from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'leave-balance', views.LeaveBalanceViewSet, basename='leave-balance')
router.register(r'leave-requests', views.LeaveRequestViewSet, basename='leave-requests')
router.register(r'wfh-requests', views.WFHRequestViewSet, basename='wfh-requests')
router.register(r'tasks', views.TaskViewSet, basename='tasks')
router.register(r'meetings', views.MeetingViewSet, basename='meetings')
router.register(r'documents', views.DocumentViewSet, basename='documents')
router.register(r'working-hours', views.WorkingHoursViewSet, basename='working-hours')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('profile/', views.profile_view, name='profile'),
    path('employees/', views.employees_view, name='employees'),
    path('test/', views.test_view, name='test'),
]
