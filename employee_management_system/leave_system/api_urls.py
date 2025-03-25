from django.urls import path
from . import api_views

urlpatterns = [
    path('leave-requests/', api_views.leave_request_list, name='leave_request_list'),
    path('leave-requests/<int:pk>/', api_views.leave_request_detail, name='leave_request_detail'),
]
