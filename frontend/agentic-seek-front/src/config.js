// Configuration utility for dynamic backend URL detection
export const getBackendUrl = () => {
  // If we're in a browser and can detect the current URL
  if (typeof window !== 'undefined') {
    const currentHost = window.location.hostname;
    
    // If running in GitHub Codespaces (detected by hostname pattern)
    if (currentHost.includes('app.github.dev')) {
      // Try to construct the backend URL from current URL
      const codespaceUrl = window.location.origin;
      const backendUrl = codespaceUrl.replace('-3000.', '-7777.');
      console.log('Codespace detected, trying backend URL:', backendUrl);
      return backendUrl;
    }
    
    // If running locally in development
    if (currentHost === 'localhost' || currentHost === '127.0.0.1') {
      return 'http://localhost:7777';
    }
  }

  // If REACT_APP_BACKEND_URL is set (from .env files)
  if (process.env.REACT_APP_BACKEND_URL) {
    return process.env.REACT_APP_BACKEND_URL;
  }

  // Fallback for local development
  return 'http://localhost:7777';
};

// Function to test if a URL is reachable
export const testBackendUrl = async (url) => {
  try {
    const response = await fetch(`${url}/health`, {
      method: 'GET',
      timeout: 5000,
    });
    return response.ok;
  } catch (error) {
    console.warn(`Backend URL ${url} not reachable:`, error.message);
    return false;
  }
};

// Function to find working backend URL
export const findWorkingBackendUrl = async () => {
  const possibleUrls = [
    getBackendUrl(), // Primary URL from detection
    'http://localhost:7777', // Local fallback
    process.env.REACT_APP_BACKEND_URL, // Environment variable fallback
  ].filter(Boolean); // Remove undefined values

  for (const url of possibleUrls) {
    console.log(`Testing backend URL: ${url}`);
    if (await testBackendUrl(url)) {
      console.log(`✅ Backend URL confirmed working: ${url}`);
      return url;
    }
  }
  
  console.error('❌ No working backend URL found');
  return possibleUrls[0]; // Return first URL as fallback
};

// Export the backend URL
export const BACKEND_URL = getBackendUrl();

console.log('Initial backend URL detected:', BACKEND_URL);