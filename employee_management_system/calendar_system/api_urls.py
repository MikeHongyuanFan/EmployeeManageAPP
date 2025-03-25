from django.urls import path
from . import api_views

urlpatterns = [
    path('meetings/', api_views.meeting_list, name='meeting_list'),
    path('meetings/<int:pk>/', api_views.meeting_detail, name='meeting_detail'),
]
