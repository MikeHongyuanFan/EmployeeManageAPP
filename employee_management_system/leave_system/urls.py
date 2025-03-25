from django.urls import path
from . import views

urlpatterns = [
    path('', views.leave_request_list, name='leave_request_list'),
    path('create/', views.leave_request_create, name='leave_request_create'),
    path('<int:pk>/', views.leave_request_detail, name='leave_request_detail'),
    path('<int:pk>/cancel/', views.leave_request_cancel, name='leave_request_cancel'),
    path('process/', views.leave_request_process_list, name='leave_request_process_list'),
    path('process/<int:pk>/', views.leave_request_process, name='leave_request_process'),
    path('balance/', views.leave_balance, name='leave_balance'),
]
