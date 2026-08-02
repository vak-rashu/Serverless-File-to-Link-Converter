document.addEventListener('DOMContentLoaded', () => {
  // DOM Elements
  const apiEndpointInput = document.getElementById('api-endpoint');
  const saveEndpointBtn = document.getElementById('save-endpoint-btn');
  const uploadForm = document.getElementById('upload-form');
  const dropZone = document.getElementById('drop-zone');
  const fileInput = document.getElementById('file-input');
  const dropZoneContent = document.getElementById('drop-zone-content');
  const filePreview = document.getElementById('file-preview');
  const previewFilename = document.getElementById('preview-filename');
  const previewFilesize = document.getElementById('preview-filesize');
  const removeFileBtn = document.getElementById('remove-file-btn');
  const customFilenameInput = document.getElementById('custom-filename');
  const submitBtn = document.getElementById('submit-btn');
  const btnText = submitBtn.querySelector('.btn-text');
  const spinner = document.getElementById('spinner');
  const statusMessage = document.getElementById('status-message');
  const resultCard = document.getElementById('result-card');
  const generatedUrlInput = document.getElementById('generated-url');
  const copyBtn = document.getElementById('copy-btn');
  const copyBtnText = document.getElementById('copy-btn-text');
  const openLinkBtn = document.getElementById('open-link-btn');
  const timerBadge = document.getElementById('timer-badge');

  let selectedFile = null;
  let timerInterval = null;

  // 1. API Endpoint LocalStorage Handler
  const STORAGE_KEY = 'serverless_file_api_endpoint';
  const savedEndpoint = localStorage.getItem(STORAGE_KEY);
  if (savedEndpoint) {
    apiEndpointInput.value = savedEndpoint;
  }

  saveEndpointBtn.addEventListener('click', () => {
    const endpoint = apiEndpointInput.value.trim();
    if (endpoint) {
      localStorage.setItem(STORAGE_KEY, endpoint);
      showStatus('API Endpoint saved to browser storage!', 'success');
    } else {
      localStorage.removeItem(STORAGE_KEY);
      showStatus('API Endpoint cleared from browser storage.', 'success');
    }
  });

  // 2. Drag & Drop and File Selection Handlers
  ['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, (e) => {
      e.preventDefault();
      e.stopPropagation();
      dropZone.classList.add('dragover');
    }, false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, (e) => {
      e.preventDefault();
      e.stopPropagation();
      dropZone.classList.remove('dragover');
    }, false);
  });

  dropZone.addEventListener('drop', (e) => {
    const dt = e.dataTransfer;
    const files = dt.files;
    if (files.length > 0) {
      handleFileSelection(files[0]);
    }
  });

  fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      handleFileSelection(e.target.files[0]);
    }
  });

  removeFileBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    resetFileSelection();
  });

  function handleFileSelection(file) {
    selectedFile = file;
    previewFilename.textContent = file.name;
    previewFilesize.textContent = formatBytes(file.size);
    
    dropZoneContent.classList.add('hidden');
    filePreview.classList.remove('hidden');
    submitBtn.disabled = false;
  }

  function resetFileSelection() {
    selectedFile = null;
    fileInput.value = '';
    previewFilename.textContent = '';
    previewFilesize.textContent = '';
    
    filePreview.classList.add('hidden');
    dropZoneContent.classList.remove('hidden');
    submitBtn.disabled = true;
  }

  // 3. Form Submission
  uploadForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const endpoint = apiEndpointInput.value.trim();
    if (!endpoint) {
      showStatus('Please enter your AWS API Gateway Endpoint URL first.', 'error');
      apiEndpointInput.focus();
      return;
    }

    if (!selectedFile) {
      showStatus('Please select a file to upload.', 'error');
      return;
    }

    // Prepare FormData
    const formData = new FormData();
    formData.append('file', selectedFile);

    const customName = customFilenameInput.value.trim();
    if (customName) {
      formData.append('filename', customName);
    }

    // Set Loading state
    setLoading(true);
    hideStatus();
    resultCard.classList.add('hidden');
    if (timerInterval) clearInterval(timerInterval);

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        body: formData
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.msg || `Server returned error status ${response.status}`);
      }

      // Successful response
      const shortUrl = data.msg;
      displayResult(shortUrl);
      showStatus('File uploaded and link generated successfully!', 'success');

    } catch (err) {
      console.error('Upload Error:', err);
      showStatus(`Upload failed: ${err.message || 'Network error or CORS issue'}`, 'error');
    } finally {
      setLoading(false);
    }
  });

  // 4. Display Results & Start Countdown
  function displayResult(url) {
    generatedUrlInput.value = url;
    openLinkBtn.href = url;
    resultCard.classList.remove('hidden');

    // Start 5 min countdown
    startCountdown(300); // 300 seconds = 5 minutes
  }

  function startCountdown(durationSeconds) {
    let remaining = durationSeconds;
    updateTimerDisplay(remaining);

    if (timerInterval) clearInterval(timerInterval);

    timerInterval = setInterval(() => {
      remaining--;
      if (remaining <= 0) {
        clearInterval(timerInterval);
        timerBadge.textContent = '⚠️ Expired';
        timerBadge.style.color = '#ef4444';
        timerBadge.style.backgroundColor = 'rgba(239, 68, 68, 0.15)';
        timerBadge.style.borderColor = 'rgba(239, 68, 68, 0.3)';
      } else {
        updateTimerDisplay(remaining);
      }
    }, 1000);
  }

  function updateTimerDisplay(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    const formatted = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    timerBadge.textContent = `⏱️ Expires in ${formatted}`;
  }

  // 5. Copy to Clipboard
  copyBtn.addEventListener('click', async () => {
    const url = generatedUrlInput.value;
    if (!url) return;

    try {
      await navigator.clipboard.writeText(url);
      copyBtnText.textContent = 'Copied!';
      copyBtn.style.background = '#10b981';

      setTimeout(() => {
        copyBtnText.textContent = 'Copy Link';
        copyBtn.style.background = 'var(--primary-color)';
      }, 2000);
    } catch (err) {
      // Fallback selection
      generatedUrlInput.select();
      document.execCommand('copy');
      copyBtnText.textContent = 'Copied!';
      setTimeout(() => {
        copyBtnText.textContent = 'Copy Link';
      }, 2000);
    }
  });

  // Utility Functions
  function setLoading(isLoading) {
    if (isLoading) {
      submitBtn.disabled = true;
      btnText.textContent = 'Uploading & Shortening...';
      spinner.classList.remove('hidden');
    } else {
      submitBtn.disabled = !selectedFile;
      btnText.textContent = 'Generate Short Link';
      spinner.classList.add('hidden');
    }
  }

  function showStatus(message, type = 'info') {
    statusMessage.textContent = message;
    statusMessage.className = `status-message ${type}`;
    statusMessage.classList.remove('hidden');
  }

  function hideStatus() {
    statusMessage.classList.add('hidden');
  }

  function formatBytes(bytes, decimals = 2) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }
});
