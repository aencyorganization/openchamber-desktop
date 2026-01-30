/**
 * OpenChamber Launcher - Minimal
 * Tries to run 'openchamber' directly and detects port from output.
 */

const CONFIG = {
    APP_NAME: 'openchamber',
    PORT: 1504,
    TIMEOUT: 30000,
    RETRY: 500
};

let state = { pid: null, port: null, processId: null };

document.addEventListener('DOMContentLoaded', async () => {
    if (typeof Neutralino === 'undefined') {
        await exitWithError('Framework not loaded');
        return;
    }

    try {
        // Clear any stale tokens before initializing
        sessionStorage.removeItem('NL_TOKEN');
        localStorage.removeItem('NL_TOKEN');
        
        // Initialize with error handling for token issues
        await Neutralino.init();
        
        // Handle token errors gracefully
        Neutralino.events.on('serverOffline', async (evt) => {
            if (evt.detail && evt.detail.code === 'NE_CL_IVCTOKN') {
                console.error('Token error detected, clearing and retrying...');
                sessionStorage.removeItem('NL_TOKEN');
                // Don't exit immediately, let user know
                await exitWithError('Connection error. Please restart the application.');
            }
        });
        
        Neutralino.events.on('windowClose', cleanupAndExit);
        
        // Setup keyboard shortcuts
        setupKeyboardShortcuts();
        
        await autoStart();
    } catch (e) {
        console.error('Startup error:', e);
        // Check if it's a token error
        if (e.message && e.message.includes('NL_TOKEN')) {
            sessionStorage.removeItem('NL_TOKEN');
            await exitWithError('Authentication error. Please restart the application.');
        } else {
            await exitWithError('Startup failed: ' + e.message);
        }
    }
});

async function autoStart() {
    // Check if port 1504 is already in use
    const isPortInUse = await checkPort(CONFIG.PORT);
    if (isPortInUse) {
        // Kill any process using port 1504 before starting
        await killPort(CONFIG.PORT);
    }
    
    // Try to start openchamber on port 1504
    const port = await tryStartOpenChamber();
    
    if (port) {
        state.port = port;
        await connect(port);
    } else {
        await exitWithError('Failed to start OpenChamber on port 1504. Make sure it is installed and in PATH.');
    }
}

async function tryStartOpenChamber() {
    try {
        // Spawn the process with PORT environment variable set to 1504
        const process = await Neutralino.os.spawnProcess(CONFIG.APP_NAME, {
            env: { PORT: CONFIG.PORT.toString() }
        });
        state.processId = process.id;
        state.pid = process.pid;
        
        // Wait for port 1504 to be available
        const startTime = Date.now();
        
        return new Promise((resolve) => {
            // Set timeout
            const timeoutId = setTimeout(() => {
                resolve(null);
            }, CONFIG.TIMEOUT);
            
            // Poll for port 1504
            const pollInterval = setInterval(async () => {
                const isReady = await checkPort(CONFIG.PORT);
                if (isReady) {
                    clearInterval(pollInterval);
                    clearTimeout(timeoutId);
                    resolve(CONFIG.PORT);
                }
                
                if (Date.now() - startTime > CONFIG.TIMEOUT) {
                    clearInterval(pollInterval);
                }
            }, CONFIG.RETRY);
        });
        
    } catch (e) {
        console.error('Failed to spawn:', e);
        return null;
    }
}

async function killPort(port) {
    const os = window.NL_OS || 'Linux';
    
    try {
        if (os === 'Windows') {
            // Find PID using the port and kill it
            const result = await Neutralino.os.execCommand(`netstat -ano | findstr ":${port}" | findstr "LISTENING"`);
            const lines = result.stdOut.split('\n');
            for (const line of lines) {
                const parts = line.trim().split(/\s+/);
                if (parts.length >= 5) {
                    const pid = parts[4];
                    await Neutralino.os.execCommand(`taskkill /F /PID ${pid} 2>nul || exit 0`);
                }
            }
        } else {
            // Linux/Mac: use lsof to find and kill process on port
            await Neutralino.os.execCommand(`lsof -ti:${port} | xargs kill -9 2>/dev/null || true`);
            await Neutralino.os.execCommand(`fuser -k ${port}/tcp 2>/dev/null || true`);
        }
    } catch (e) {
        console.log('No process found on port', port);
    }
}

async function checkPort(port) {
    try {
        const os = window.NL_OS || 'Linux';
        const cmd = os === 'Windows' 
            ? `netstat -an | findstr ":${port}" | findstr "LISTENING"`
            : `ss -tln 2>/dev/null | grep ":${port}" || netstat -tln 2>/dev/null | grep ":${port}"`;
        
        const result = await Neutralino.os.execCommand(cmd);
        return result.stdOut.includes(port.toString());
    } catch (e) {
        return false;
    }
}

async function connect(port) {
    document.getElementById('app-frame').src = `http://localhost:${port}`;
    document.getElementById('loading-screen').classList.remove('active');
    document.getElementById('webview-screen').classList.add('active');
}

async function exitWithError(msg) {
    try {
        await Neutralino.os.showMessageBox('Error', msg, 'OK', 'ERROR');
    } catch (e) {}
    await cleanupAndExit();
}

async function cleanupAndExit() {
    const os = window.NL_OS || 'Linux';
    
    try {
        if (state.processId) {
            await Neutralino.os.updateSpawnedProcess(state.processId, 'exit');
        }
    } catch (e) {}
    
    try {
        if (os === 'Windows') {
            if (state.pid) await Neutralino.os.execCommand(`taskkill /F /PID ${state.pid} 2>nul || exit 0`);
            await Neutralino.os.execCommand(`taskkill /F /IM openchamber.exe 2>nul || exit 0`);
        } else {
            if (state.pid) await Neutralino.os.execCommand(`kill -9 ${state.pid} 2>/dev/null || true`);
            await Neutralino.os.execCommand(`pkill -9 -f "openchamber" 2>/dev/null || true`);
        }
    } catch (e) {}
    
    // Always kill port 1504 on exit
    try {
        await killPort(1504);
    } catch (e) {}
    
    try {
        await Neutralino.app.exit();
    } catch (e) {
        window.close();
    }
}

/**
 * Setup keyboard shortcuts for fullscreen and zoom
 */
function setupKeyboardShortcuts() {
    let zoomLevel = 1.0;
    const ZOOM_STEP = 0.1;
    const MIN_ZOOM = 0.5;
    const MAX_ZOOM = 3.0;
    
    document.addEventListener('keydown', async (e) => {
        const isMac = window.NL_OS === 'Darwin';
        const ctrlKey = isMac ? e.metaKey : e.ctrlKey;
        
        // Fullscreen: F11
        if (e.key === 'F11') {
            e.preventDefault();
            try {
                await Neutralino.window.setFullScreen();
            } catch (err) {
                console.error('Fullscreen error:', err);
            }
        }
        
        // Zoom controls
        if (ctrlKey) {
            // Zoom In: Ctrl/Cmd + Plus
            if (e.key === '+' || e.key === '=') {
                e.preventDefault();
                zoomLevel = Math.min(zoomLevel + ZOOM_STEP, MAX_ZOOM);
                applyZoom(zoomLevel);
            }
            
            // Zoom Out: Ctrl/Cmd + Minus
            if (e.key === '-' || e.key === '_') {
                e.preventDefault();
                zoomLevel = Math.max(zoomLevel - ZOOM_STEP, MIN_ZOOM);
                applyZoom(zoomLevel);
            }
            
            // Reset Zoom: Ctrl/Cmd + 0
            if (e.key === '0') {
                e.preventDefault();
                zoomLevel = 1.0;
                applyZoom(zoomLevel);
            }
        }
    });
}

/**
 * Apply zoom level to the app
 */
function applyZoom(level) {
    document.body.style.zoom = level;
    document.body.style.transform = `scale(${level})`;
    document.body.style.transformOrigin = 'top left';
    console.log(`Zoom level: ${level}`);
}
