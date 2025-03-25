from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Document
from .serializers import DocumentSerializer

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def document_list(request):
    """
    List all documents or upload a new document
    """
    if request.method == 'GET':
        # For employees, show documents they uploaded
        # For managers, show all documents
        if hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above():
            documents = Document.objects.all()
        else:
            documents = Document.objects.filter(uploaded_by=request.user)
            
        serializer = DocumentSerializer(documents, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Upload a new document
        data = request.data.copy()
        data['uploaded_by'] = request.user.id  # Set the uploader to the current user
        
        serializer = DocumentSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser, FormParser])
def document_detail(request, pk):
    """
    Retrieve, update or delete a document
    """
    try:
        document = Document.objects.get(pk=pk)
    except Document.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Check permissions
    is_manager = hasattr(request.user, 'is_manager_or_above') and request.user.is_manager_or_above()
    is_uploader = document.uploaded_by == request.user
    
    if not (is_manager or is_uploader):
        return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method == 'GET':
        serializer = DocumentSerializer(document)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        # Only the uploader or a manager can update document details
        if not (is_manager or is_uploader):
            return Response({'error': 'Permission denied'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        serializer = DocumentSerializer(document, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        # Only the uploader or a manager can delete a document
        if not (is_manager or is_uploader):
            return Response({'error': 'Permission denied'}, 
                           status=status.HTTP_403_FORBIDDEN)
        
        document.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
