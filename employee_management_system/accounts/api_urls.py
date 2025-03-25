from django.urls import path
from . import api_views

urlpatterns = [
    path('login/', api_views.login, name='api_login'),
    path('logout/', api_views.logout, name='api_logout'),
    path('profile/', api_views.profile, name='api_profile'),
    path('employees/', api_views.employees_list, name='api_employees_list'),
    path('test/', api_views.test, name='api_test'),
]
