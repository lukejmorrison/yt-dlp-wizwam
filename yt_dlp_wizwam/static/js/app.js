// yt-dlp-wizwam - Main JavaScript
// Socket.IO client for real-time progress updates

// Initialize Socket.IO connection
const socket = io();

// DOM elements
const downloadForm = document.getElementById('download-form');
const downloadBtn = document.getElementById('download-btn');
const btnText = downloadBtn.querySelector('.btn-text');
const btnProgressBg = downloadBtn.querySelector('.btn-progress-bg');
const messageBox = document.getElementById('message-box');
const filesList = document.getElementById('files-list');
const filesCount = document.getElementById('files-count');
const refreshFilesBtn = document.getElementById('refresh-files');
const searchFilesInput = document.getElementById('search-files');
const sortFilesSelect = document.getElementById('sort-files');

// Current job ID and files data
let currentJobId = null;
let allFiles = [];  // Store all files for filtering/sorting

// Socket.IO event handlers
socket.on('connect', () => {
    console.log('✅ Socket.IO Connected to server');
    console.log('Socket ID:', socket.id);
    console.log('Transport:', socket.io.engine.transport.name);
});

socket.on('disconnect', () => {
    console.log('❌ Socket.IO Disconnected from server');
});

socket.on('connect_error', (error) => {
    console.error('❌ Socket.IO Connection Error:', error);
});

socket.on('progress', (data) => {
    console.log('📊 Progress received:', data);
    showProgress(data);
});

socket.on('success', (data) => {
    console.log('✅ Success received:', data);
    showSuccess(data);
    loadFiles(); // Refresh file list
});

socket.on('error', (data) => {
    console.log('❌ Error received:', data);
    showError(data);
});

// Download form submission
if (downloadForm) {
    console.log('✅ Download form found, attaching event listener');
    console.log('Download button:', downloadBtn);
    console.log('Button text element:', btnText);
    console.log('Button progress bg:', btnProgressBg);
    
    downloadForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        console.log('📤 Form submitted!');
        
        const formData = {
            url: document.getElementById('url').value,
            quality: document.getElementById('quality').value,
            video_codec: document.getElementById('video_codec').value,
            audio_codec: document.getElementById('audio_codec').value,
            audio_only: document.getElementById('audio_only').checked
        };
        
        console.log('Form data:', formData);
        
        // Reset button to initial downloading state
        downloadBtn.classList.add('downloading');
        downloadBtn.classList.remove('success', 'error');
        downloadBtn.disabled = true;
        btnProgressBg.style.width = '0%';
        btnText.textContent = 'Initializing download...';
        
        try {
            const response = await fetch('/api/download', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.status === 'success' || result.status === 'started') {
                currentJobId = result.job_id;
                console.log('✅ Download started:', result);
            } else {
                console.error('❌ Download failed to start:', result);
                showError(result);
            }
        } catch (error) {
            console.error('❌ Network error:', error);
            showError({ error: error.message });
        }
    });
} else {
    console.error('❌ Download form not found!');
}

// Show progress
function showProgress(data) {
    const percent = data.percent || 0;
    const phase = data.phase || 'downloading';
    const message = data.message || '';
    
    // Update button state
    downloadBtn.classList.add('downloading');
    downloadBtn.classList.remove('success', 'error');
    downloadBtn.disabled = true;
    
    // Update progress bar background
    btnProgressBg.style.width = `${percent}%`;
    
    // Format the display text to mirror terminal output
    // Example: "Downloading: 49.2% of 40.94MiB at 489.62KiB/s ETA 00:43"
    let displayText = '';
    
    if (phase === 'downloading' && message.includes('%')) {
        // Extract download stats from message
        displayText = `Downloading: ${message}`;
    } else if (phase === 'initializing') {
        displayText = 'Initializing download...';
    } else if (phase === 'merging') {
        displayText = 'Merging video and audio...';
    } else if (phase === 'processing') {
        displayText = 'Processing...';
    } else {
        displayText = `${phase}: ${percent.toFixed(1)}%`;
    }
    
    btnText.textContent = displayText;
}

// Show success message
function showSuccess(data) {
    downloadBtn.classList.remove('downloading', 'error');
    downloadBtn.classList.add('success');
    
    btnProgressBg.style.width = '100%';
    btnText.textContent = `✓ Downloaded: ${data.filename || 'Complete'}`;
    
    // Show success message in box
    messageBox.className = 'message-box success';
    messageBox.innerHTML = `
        <strong>✓ Download Complete!</strong><br>
        File: ${data.filename || 'Unknown'}<br>
        Size: ${data.filesize || 'Unknown'}
    `;
    
    // Reload files list
    loadFiles();
    
    // Reset button after 3 seconds
    setTimeout(() => {
        downloadBtn.classList.remove('success');
        downloadBtn.disabled = false;
        btnProgressBg.style.width = '0%';
        btnText.textContent = 'Download';
    }, 3000);
    
    // Hide message after 10 seconds
    setTimeout(() => {
        messageBox.classList.add('hidden');
    }, 10000);
}

// Show error message
function showError(data) {
    downloadBtn.classList.remove('downloading', 'success');
    downloadBtn.classList.add('error');
    
    btnProgressBg.style.width = '100%';
    const errorMsg = data.error || 'Download failed';
    btnText.textContent = `✗ Error`;
    
    // Show error in message box
    messageBox.className = 'message-box error';
    messageBox.innerHTML = `
        <strong>✗ Download Failed</strong><br>
        ${errorMsg}
    `;
    
    // Reset button after 4 seconds
    setTimeout(() => {
        downloadBtn.classList.remove('error');
        downloadBtn.disabled = false;
        btnProgressBg.style.width = '0%';
        btnText.textContent = 'Download';
    }, 4000);
    
    // Hide message after 15 seconds (longer for errors)
    setTimeout(() => {
        messageBox.classList.add('hidden');
    }, 15000);
}

// Load files list
async function loadFiles() {
    if (!filesList) return;
    
    try {
        const response = await fetch('/api/files');
        const data = await response.json();
        
        if (data.files && data.files.length > 0) {
            allFiles = data.files;  // Store all files
            filterAndSortFiles();
        } else {
            filesList.innerHTML = '<p>No files downloaded yet.</p>';
            if (filesCount) filesCount.textContent = '';
        }
    } catch (error) {
        console.error('Error loading files:', error);
        filesList.innerHTML = '<p class="error">Error loading files.</p>';
    }
}

// Filter and sort files based on search and sort criteria
function filterAndSortFiles() {
    if (!filesList) return;
    
    const searchTerm = searchFilesInput ? searchFilesInput.value.toLowerCase() : '';
    const sortBy = sortFilesSelect ? sortFilesSelect.value : 'newest';
    
    // Filter files
    let filteredFiles = allFiles.filter(file => {
        const fileName = (file.name || file.filename || '').toLowerCase();
        return fileName.includes(searchTerm);
    });
    
    // Sort files
    filteredFiles.sort((a, b) => {
        switch(sortBy) {
            case 'newest':
                return (b.modified || 0) - (a.modified || 0);
            case 'oldest':
                return (a.modified || 0) - (b.modified || 0);
            case 'name-asc':
                return (a.name || a.filename || '').localeCompare(b.name || b.filename || '');
            case 'name-desc':
                return (b.name || b.filename || '').localeCompare(a.name || a.filename || '');
            case 'size-desc':
                return (b.size || 0) - (a.size || 0);
            case 'size-asc':
                return (a.size || 0) - (b.size || 0);
            default:
                return (b.modified || 0) - (a.modified || 0);
        }
    });
    
    // Update count
    if (filesCount) {
        if (searchTerm) {
            filesCount.textContent = `Showing ${filteredFiles.length} of ${allFiles.length} files`;
        } else {
            filesCount.textContent = `${filteredFiles.length} file${filteredFiles.length !== 1 ? 's' : ''}`;
        }
    }
    
    // Render files
    if (filteredFiles.length > 0) {
        filesList.innerHTML = filteredFiles.map(file => `
            <div class="file-item">
                <div class="file-info">
                    <span class="file-name">${escapeHtml(file.name || file.filename)}</span>
                    <span class="file-size">${file.size_mb || 'Unknown size'}</span>
                    ${file.nas_copy ? '<span class="nas-badge">📦 NAS Copy</span>' : ''}
                </div>
                <div class="file-actions">
                    <button onclick="viewFile('${escapeJs(file.name || file.filename)}')" class="btn-view" title="View in browser">👁️ View</button>
                    <button onclick="runMacro('${escapeJs(file.name || file.filename)}')" class="btn-macro" title="Run macro script">⚡ Macro</button>
                    <button onclick="downloadFile('${escapeJs(file.name || file.filename)}')" class="btn-secondary">💾 Download</button>
                    <button onclick="deleteFile('${escapeJs(file.name || file.filename)}')" class="btn-delete">🗑️ Delete</button>
                </div>
            </div>
        `).join('');
    } else {
        filesList.innerHTML = searchTerm 
            ? '<p>No files match your search.</p>' 
            : '<p>No files downloaded yet.</p>';
    }
}

// Helper function to escape HTML in filenames
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Helper function to escape strings for JavaScript (for use in onclick attributes)
function escapeJs(text) {
    return text.replace(/\\/g, '\\\\')
               .replace(/'/g, "\\'")
               .replace(/"/g, '\\"')
               .replace(/\n/g, '\\n')
               .replace(/\r/g, '\\r');
}

// View file in browser (opens video player in new tab)
function viewFile(filename) {
    window.open(`/view/${encodeURIComponent(filename)}`, '_blank');
}

// Run macro script on file
async function runMacro(filename) {
    if (!confirm(`Run macro on ${filename}?`)) return;
    
    try {
        const response = await fetch('/api/macro/run', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ filename: filename })
        });
        
        const result = await response.json();
        
        if (result.status === 'success') {
            // Show success in message box
            messageBox.className = 'message-box success';
            messageBox.innerHTML = `
                <strong>✓ Macro Complete!</strong><br>
                ${result.message || 'File processed successfully'}
            `;
            
            if (result.share_link) {
                // Copy share link to clipboard
                try {
                    await navigator.clipboard.writeText(result.share_link);
                    messageBox.innerHTML += `<br><br>📋 Share link copied to clipboard:<br><code>${result.share_link}</code>`;
                } catch (clipError) {
                    messageBox.innerHTML += `<br><br>Share link:<br><code>${result.share_link}</code>`;
                }
            }
            
            // Hide message after 10 seconds
            setTimeout(() => {
                messageBox.classList.add('hidden');
            }, 10000);
            
            loadFiles(); // Refresh to show NAS badge
        } else {
            // Show error in message box
            messageBox.className = 'message-box error';
            messageBox.innerHTML = `
                <strong>✗ Macro Failed</strong><br>
                ${result.error || 'Macro execution failed'}
            `;
            
            // Hide after 15 seconds
            setTimeout(() => {
                messageBox.classList.add('hidden');
            }, 15000);
        }
    } catch (error) {
        // Show error in message box
        messageBox.className = 'message-box error';
        messageBox.innerHTML = `
            <strong>✗ Network Error</strong><br>
            ${error.message}
        `;
        
        setTimeout(() => {
            messageBox.classList.add('hidden');
        }, 15000);
    }
}

// Custom Modal Dialogs (OS-style)
function showModal(title, message, buttons = []) {
    return new Promise((resolve) => {
        // Create overlay
        const overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        
        // Create dialog
        const dialog = document.createElement('div');
        dialog.className = 'modal-dialog';
        
        // Title
        const titleEl = document.createElement('div');
        titleEl.className = 'modal-title';
        titleEl.textContent = title;
        dialog.appendChild(titleEl);
        
        // Message
        const messageEl = document.createElement('div');
        messageEl.className = 'modal-message';
        messageEl.textContent = message;
        dialog.appendChild(messageEl);
        
        // Buttons container
        const buttonsContainer = document.createElement('div');
        buttonsContainer.className = 'modal-buttons';
        
        // Add buttons
        buttons.forEach(btn => {
            const button = document.createElement('button');
            button.className = `modal-btn ${btn.className || ''}`;
            button.textContent = btn.label;
            button.onclick = () => {
                overlay.remove();
                resolve(btn.value);
            };
            buttonsContainer.appendChild(button);
        });
        
        dialog.appendChild(buttonsContainer);
        overlay.appendChild(dialog);
        document.body.appendChild(overlay);
        
        // Close on overlay click
        overlay.onclick = (e) => {
            if (e.target === overlay) {
                overlay.remove();
                resolve(null);
            }
        };
        
        // Close on Escape key
        const escapeHandler = (e) => {
            if (e.key === 'Escape') {
                overlay.remove();
                document.removeEventListener('keydown', escapeHandler);
                resolve(null);
            }
        };
        document.addEventListener('keydown', escapeHandler);
    });
}

function showAlert(message, title = 'Notice') {
    return showModal(title, message, [
        { label: 'OK', value: true, className: 'modal-btn-primary' }
    ]);
}

function showConfirm(message, title = 'Confirm') {
    return showModal(title, message, [
        { label: 'Cancel', value: false, className: '' },
        { label: 'OK', value: true, className: 'modal-btn-primary' }
    ]);
}

function showSuccess(message) {
    return showAlert(message, '✓ Success');
}

function showError(message) {
    return showAlert(message, '✗ Error');
}

// Download file
function downloadFile(filename) {
    window.location.href = `/api/files/${encodeURIComponent(filename)}`;
}

// Delete file
async function deleteFile(filename) {
    const confirmed = await showModal(
        '🗑️ Delete File',
        `Are you sure you want to delete "${filename}"?\n\nThis action cannot be undone.`,
        [
            { label: 'Cancel', value: false, className: '' },
            { label: 'Delete', value: true, className: 'modal-btn-danger' }
        ]
    );
    
    if (!confirmed) return;
    
    try {
        const response = await fetch(`/api/files/${encodeURIComponent(filename)}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (result.status === 'success') {
            await showSuccess(`File "${filename}" has been deleted.`);
            loadFiles();
        } else {
            await showError(result.error || 'Failed to delete file.');
        }
    } catch (error) {
        await showError(`Network error: ${error.message}`);
    }
}

// Refresh files button
if (refreshFilesBtn) {
    refreshFilesBtn.addEventListener('click', loadFiles);
}

// Reset download button when URL is changed
const urlInput = document.getElementById('url');
if (urlInput) {
    urlInput.addEventListener('input', () => {
        // Reset button to default state when user types/pastes a new URL
        if (downloadBtn.classList.contains('success') || downloadBtn.classList.contains('error')) {
            downloadBtn.classList.remove('success', 'error', 'downloading');
            downloadBtn.disabled = false;
            btnProgressBg.style.width = '0%';
            btnText.textContent = 'Download';
            
            // Also hide any message box
            if (messageBox) {
                messageBox.classList.add('hidden');
            }
        }
    });
}

// Search and sort event listeners
if (searchFilesInput) {
    searchFilesInput.addEventListener('input', filterAndSortFiles);
}

if (sortFilesSelect) {
    sortFilesSelect.addEventListener('change', filterAndSortFiles);
}

// Load files on page load
if (filesList) {
    loadFiles();
}

// Load saved settings
const savedQuality = localStorage.getItem('default_quality');
const savedVideoCodec = localStorage.getItem('default_video_codec');
const savedAudioCodec = localStorage.getItem('default_audio_codec');

if (savedQuality && document.getElementById('quality')) {
    document.getElementById('quality').value = savedQuality;
}
if (savedVideoCodec && document.getElementById('video_codec')) {
    document.getElementById('video_codec').value = savedVideoCodec;
}
if (savedAudioCodec && document.getElementById('audio_codec')) {
    document.getElementById('audio_codec').value = savedAudioCodec;
}
