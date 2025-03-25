/**
 * Main JavaScript file for Employee Management System
 */

// Initialize tooltips and popovers
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Initialize Bootstrap popovers
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Initialize notification badge animation
    const notificationBadge = document.getElementById('notification-badge');
    if (notificationBadge && notificationBadge.innerText !== '0' && notificationBadge.innerText !== '') {
        notificationBadge.classList.add('has-notifications');
    }
    
    // Handle task completion checkboxes
    const taskCheckboxes = document.querySelectorAll('.task-checkbox');
    taskCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const taskId = this.dataset.taskId;
            const taskItem = document.getElementById(`task-item-${taskId}`);
            const taskForm = document.getElementById(`task-form-${taskId}`);
            
            if (this.checked) {
                taskItem.classList.add('completed');
                taskForm.submit();
            }
        });
    });
    
    // Handle file input display
    const fileInputs = document.querySelectorAll('.custom-file-input');
    fileInputs.forEach(input => {
        input.addEventListener('change', function() {
            const fileName = this.files[0]?.name || 'No file chosen';
            const fileLabel = this.nextElementSibling;
            fileLabel.textContent = fileName;
        });
    });
    
    // Handle dark mode toggle
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', function() {
            document.body.classList.toggle('dark-mode-enabled');
            
            // Save preference to localStorage
            const isDarkMode = document.body.classList.contains('dark-mode-enabled');
            localStorage.setItem('darkMode', isDarkMode ? 'enabled' : 'disabled');
            
            // Update icon
            const darkModeIcon = document.getElementById('dark-mode-icon');
            if (isDarkMode) {
                darkModeIcon.classList.replace('bi-moon', 'bi-sun');
            } else {
                darkModeIcon.classList.replace('bi-sun', 'bi-moon');
            }
        });
        
        // Check for saved preference
        const savedDarkMode = localStorage.getItem('darkMode');
        if (savedDarkMode === 'enabled') {
            document.body.classList.add('dark-mode-enabled');
            document.getElementById('dark-mode-icon').classList.replace('bi-moon', 'bi-sun');
        }
    }
    
    // Handle date range pickers
    const dateRangePickers = document.querySelectorAll('.date-range-picker');
    if (dateRangePickers.length > 0 && typeof daterangepicker !== 'undefined') {
        dateRangePickers.forEach(picker => {
            $(picker).daterangepicker({
                opens: 'left',
                autoUpdateInput: false,
                locale: {
                    cancelLabel: 'Clear',
                    format: 'YYYY-MM-DD'
                }
            });
            
            $(picker).on('apply.daterangepicker', function(ev, picker) {
                $(this).val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
            });
            
            $(picker).on('cancel.daterangepicker', function(ev, picker) {
                $(this).val('');
            });
        });
    }
    
    // Handle single date pickers
    const datePickers = document.querySelectorAll('.date-picker');
    if (datePickers.length > 0 && typeof flatpickr !== 'undefined') {
        flatpickr(datePickers, {
            dateFormat: "Y-m-d",
            allowInput: true
        });
    }
    
    // Handle time pickers
    const timePickers = document.querySelectorAll('.time-picker');
    if (timePickers.length > 0 && typeof flatpickr !== 'undefined') {
        flatpickr(timePickers, {
            enableTime: true,
            noCalendar: true,
            dateFormat: "H:i",
            time_24hr: true
        });
    }
    
    // Handle datetime pickers
    const datetimePickers = document.querySelectorAll('.datetime-picker');
    if (datetimePickers.length > 0 && typeof flatpickr !== 'undefined') {
        flatpickr(datetimePickers, {
            enableTime: true,
            dateFormat: "Y-m-d H:i",
            time_24hr: true
        });
    }
    
    // Handle document search
    const documentSearch = document.getElementById('document-search');
    if (documentSearch) {
        documentSearch.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const documentItems = document.querySelectorAll('.document-item');
            
            documentItems.forEach(item => {
                const documentName = item.querySelector('.document-name').textContent.toLowerCase();
                const documentType = item.querySelector('.document-type').textContent.toLowerCase();
                const documentOwner = item.querySelector('.document-owner').textContent.toLowerCase();
                
                if (documentName.includes(searchTerm) || 
                    documentType.includes(searchTerm) || 
                    documentOwner.includes(searchTerm)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        });
    }
    
    // Handle task filters
    const taskFilterButtons = document.querySelectorAll('.task-filter');
    if (taskFilterButtons.length > 0) {
        taskFilterButtons.forEach(button => {
            button.addEventListener('click', function() {
                const filter = this.dataset.filter;
                const taskItems = document.querySelectorAll('.task-list-item');
                
                // Update active button
                document.querySelectorAll('.task-filter').forEach(btn => {
                    btn.classList.remove('active');
                });
                this.classList.add('active');
                
                // Filter tasks
                taskItems.forEach(item => {
                    if (filter === 'all') {
                        item.style.display = '';
                    } else if (filter === 'completed' && item.classList.contains('completed')) {
                        item.style.display = '';
                    } else if (filter === 'pending' && !item.classList.contains('completed')) {
                        item.style.display = '';
                    } else if (filter === 'high' && item.classList.contains('priority-high')) {
                        item.style.display = '';
                    } else if (filter === 'medium' && item.classList.contains('priority-medium')) {
                        item.style.display = '';
                    } else if (filter === 'low' && item.classList.contains('priority-low')) {
                        item.style.display = '';
                    } else {
                        item.style.display = 'none';
                    }
                });
            });
        });
    }
});
