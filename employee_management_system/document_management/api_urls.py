from django.urls import path
from . import api_views

urlpatterns = [
    path('documents/', api_views.document_list, name='document_list'),
    path('documents/<int:pk>/', api_views.document_detail, name='document_detail'),
]
