from django.urls import path
from . import api_views

urlpatterns = [
    path('wfh-requests/', api_views.wfh_request_list, name='wfh_request_list'),
    path('wfh-requests/<int:pk>/', api_views.wfh_request_detail, name='wfh_request_detail'),
]
