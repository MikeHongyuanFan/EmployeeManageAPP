from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import HttpResponse, FileResponse
from django.utils import timezone
from .models import Document, DocumentCategory, DocumentComment
from .forms import DocumentForm, DocumentShareForm, DocumentCommentForm, DocumentCategoryForm

@login_required
def document_list(request):
    """View for listing documents"""
    # Get documents uploaded by the user
    uploaded_documents = Document.objects.filter(uploaded_by=request.user)
    
    # Get documents shared with the user
    shared_documents = Document.objects.filter(shared_with=request.user)
    
    # Get document categories
    categories = DocumentCategory.objects.all()
    
    return render(request, 'document_management/document_list.html', {
        'uploaded_documents': uploaded_documents,
        'shared_documents': shared_documents,
        'categories': categories
    })

@login_required
def document_create(request):
    """View for uploading a new document"""
    if request.method == 'POST':
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            document = form.save(commit=False)
            document.uploaded_by = request.user
            document.save()
            messages.success(request, 'Document uploaded successfully!')
            return redirect('document_list')
    else:
        form = DocumentForm()
    
    return render(request, 'document_management/document_form.html', {
        'form': form,
        'title': 'Upload Document'
    })

@login_required
def document_detail(request, pk):
    """View for viewing document details"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to view this document
    if request.user != document.uploaded_by and request.user not in document.shared_with.all():
        messages.error(request, 'You do not have permission to view this document.')
        return redirect('document_list')
    
    # Get document comments
    comments = document.comments.all()
    
    # Comment form
    comment_form = DocumentCommentForm()
    
    return render(request, 'document_management/document_detail.html', {
        'document': document,
        'comments': comments,
        'comment_form': comment_form
    })

@login_required
def document_update(request, pk):
    """View for updating a document"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to update this document
    if request.user != document.uploaded_by:
        messages.error(request, 'You do not have permission to update this document.')
        return redirect('document_list')
    
    if request.method == 'POST':
        form = DocumentForm(request.POST, request.FILES, instance=document)
        if form.is_valid():
            form.save()
            messages.success(request, 'Document updated successfully!')
            return redirect('document_detail', pk=document.pk)
    else:
        form = DocumentForm(instance=document)
    
    return render(request, 'document_management/document_form.html', {
        'form': form,
        'title': 'Update Document',
        'document': document
    })

@login_required
def document_delete(request, pk):
    """View for deleting a document"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to delete this document
    if request.user != document.uploaded_by:
        messages.error(request, 'You do not have permission to delete this document.')
        return redirect('document_list')
    
    if request.method == 'POST':
        document.delete()
        messages.success(request, 'Document deleted successfully!')
        return redirect('document_list')
    
    return render(request, 'document_management/document_confirm_delete.html', {
        'document': document
    })

@login_required
def document_download(request, pk):
    """View for downloading a document"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to download this document
    if request.user != document.uploaded_by and request.user not in document.shared_with.all():
        messages.error(request, 'You do not have permission to download this document.')
        return redirect('document_list')
    
    # Open the file for reading in binary mode
    file = document.file.open('rb')
    response = FileResponse(file)
    
    # Set the Content-Disposition header to force download
    response['Content-Disposition'] = f'attachment; filename="{document.file.name.split("/")[-1]}"'
    
    return response

@login_required
def document_share(request, pk):
    """View for sharing a document with other users"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to share this document
    if request.user != document.uploaded_by:
        messages.error(request, 'You do not have permission to share this document.')
        return redirect('document_list')
    
    if request.method == 'POST':
        form = DocumentShareForm(request.POST, document=document)
        if form.is_valid():
            # Clear existing shared users and add new ones
            document.shared_with.clear()
            document.shared_with.add(*form.cleaned_data['users'])
            messages.success(request, 'Document sharing updated successfully!')
            return redirect('document_detail', pk=document.pk)
    else:
        form = DocumentShareForm(document=document)
    
    return render(request, 'document_management/document_share.html', {
        'form': form,
        'document': document
    })

@login_required
def document_comment(request, pk):
    """View for adding a comment to a document"""
    document = get_object_or_404(Document, pk=pk)
    
    # Check if user has permission to comment on this document
    if request.user != document.uploaded_by and request.user not in document.shared_with.all():
        messages.error(request, 'You do not have permission to comment on this document.')
        return redirect('document_list')
    
    if request.method == 'POST':
        form = DocumentCommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.document = document
            comment.user = request.user
            comment.save()
            messages.success(request, 'Comment added successfully!')
    
    return redirect('document_detail', pk=document.pk)

@login_required
def category_list(request):
    """View for listing document categories"""
    categories = DocumentCategory.objects.all()
    
    return render(request, 'document_management/category_list.html', {
        'categories': categories
    })

@login_required
def category_create(request):
    """View for creating a new document category"""
    if request.method == 'POST':
        form = DocumentCategoryForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Category created successfully!')
            return redirect('category_list')
    else:
        form = DocumentCategoryForm()
    
    return render(request, 'document_management/category_form.html', {
        'form': form,
        'title': 'Create Category'
    })
