from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from .models import Task, TaskComment
from .forms import TaskForm, TaskCommentForm

@login_required
def task_list(request):
    """View for listing tasks"""
    # Get tasks assigned to the user
    assigned_tasks = Task.objects.filter(assigned_to=request.user)
    
    # Get tasks created by the user
    created_tasks = Task.objects.filter(created_by=request.user)
    
    # Get personal tasks
    personal_tasks = Task.objects.filter(assigned_to=request.user, is_personal=True)
    
    # Get overdue tasks
    overdue_tasks = [task for task in assigned_tasks if task.is_overdue]
    
    return render(request, 'task_management/task_list.html', {
        'assigned_tasks': assigned_tasks,
        'created_tasks': created_tasks,
        'personal_tasks': personal_tasks,
        'overdue_tasks': overdue_tasks
    })

@login_required
def task_create(request, personal=False):
    """View for creating a new task"""
    if request.method == 'POST':
        form = TaskForm(request.POST)
        if form.is_valid():
            task = form.save(commit=False)
            task.created_by = request.user
            
            # If personal task, assign to self
            if personal or task.is_personal:
                task.assigned_to = request.user
                task.is_personal = True
            
            task.save()
            messages.success(request, 'Task created successfully!')
            return redirect('task_list')
    else:
        form = TaskForm()
        
        # If creating a personal task, pre-fill assigned_to with current user
        if personal or request.GET.get('personal') == 'true':
            form.initial['is_personal'] = True
            form.initial['assigned_to'] = request.user
    
    return render(request, 'task_management/task_form.html', {
        'form': form,
        'title': 'Create Personal Task' if personal else 'Create Task'
    })

@login_required
def task_detail(request, pk):
    """View for viewing task details"""
    task = get_object_or_404(Task, pk=pk)
    
    # Check if user has permission to view this task
    if request.user != task.created_by and request.user != task.assigned_to:
        messages.error(request, 'You do not have permission to view this task.')
        return redirect('task_list')
    
    # Get task comments
    comments = task.comments.all()
    
    # Comment form
    comment_form = TaskCommentForm()
    
    return render(request, 'task_management/task_detail.html', {
        'task': task,
        'comments': comments,
        'comment_form': comment_form
    })

@login_required
def task_update(request, pk):
    """View for updating a task"""
    task = get_object_or_404(Task, pk=pk)
    
    # Check if user has permission to update this task
    if request.user != task.created_by:
        messages.error(request, 'You do not have permission to update this task.')
        return redirect('task_list')
    
    if request.method == 'POST':
        form = TaskForm(request.POST, instance=task)
        if form.is_valid():
            task = form.save()
            messages.success(request, 'Task updated successfully!')
            return redirect('task_detail', pk=task.pk)
    else:
        form = TaskForm(instance=task)
    
    return render(request, 'task_management/task_form.html', {
        'form': form,
        'title': 'Update Task',
        'task': task
    })

@login_required
def task_delete(request, pk):
    """View for deleting a task"""
    task = get_object_or_404(Task, pk=pk)
    
    # Check if user has permission to delete this task
    if request.user != task.created_by:
        messages.error(request, 'You do not have permission to delete this task.')
        return redirect('task_list')
    
    if request.method == 'POST':
        task.delete()
        messages.success(request, 'Task deleted successfully!')
        return redirect('task_list')
    
    return render(request, 'task_management/task_confirm_delete.html', {
        'task': task
    })

@login_required
def task_complete(request, pk):
    """View for marking a task as complete"""
    task = get_object_or_404(Task, pk=pk)
    
    # Check if user has permission to complete this task
    if request.user != task.assigned_to:
        messages.error(request, 'You do not have permission to complete this task.')
        return redirect('task_list')
    
    task.complete()
    messages.success(request, 'Task marked as completed!')
    return redirect('task_list')

@login_required
def task_comment(request, pk):
    """View for adding a comment to a task"""
    task = get_object_or_404(Task, pk=pk)
    
    # Check if user has permission to comment on this task
    if request.user != task.created_by and request.user != task.assigned_to:
        messages.error(request, 'You do not have permission to comment on this task.')
        return redirect('task_list')
    
    if request.method == 'POST':
        form = TaskCommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.task = task
            comment.user = request.user
            comment.save()
            messages.success(request, 'Comment added successfully!')
    
    return redirect('task_detail', pk=task.pk)
