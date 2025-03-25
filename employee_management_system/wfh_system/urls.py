from django.urls import path
from . import views

urlpatterns = [
    path('', views.wfh_request_list, name='wfh_request_list'),
    path('create/', views.wfh_request_create, name='wfh_request_create'),
    path('<int:pk>/', views.wfh_request_detail, name='wfh_request_detail'),
    path('<int:pk>/cancel/', views.wfh_request_cancel, name='wfh_request_cancel'),
    path('process/', views.wfh_request_process_list, name='wfh_request_process_list'),
    path('process/<int:pk>/', views.wfh_request_process, name='wfh_request_process'),
]
