/**
 * OpenChamber Launcher - Minimal
 * Tries to run 'openchamber' directly and detects port from output.
 */

const CONFIG = {
    APP_NAME: 'openchamber',
    PORTS: [3000, 3001, 8080, 5000, 8000, 3002, 3003, 3004, 3005, 3006, 3007, 3008, 3009, 3010],
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
    // Try to find if already running
    const runningPort = await findRunningPort();
    if (runningPort) {
        state.port = runningPort;
        await connect(runningPort);
        return;
    }
    
    // Try to start openchamber directly
    const port = await tryStartOpenChamber();
    
    if (port) {
        state.port = port;
        await connect(port);
    } else {
        await exitWithError('Failed to start OpenChamber. Make sure it is installed and in PATH.');
    }
}

async function tryStartOpenChamber() {
    try {
        // Spawn the process and capture output to detect port
        const process = await Neutralino.os.spawnProcess(CONFIG.APP_NAME);
        state.processId = process.id;
        state.pid = process.pid;
        
        // Listen to process output to detect port
        let detectedPort = null;
        const startTime = Date.now();
        
        return new Promise((resolve) => {
            // Set timeout
            const timeoutId = setTimeout(() => {
                resolve(detectedPort);
            }, CONFIG.TIMEOUT);
            
            // Listen for process events
            Neutralino.events.on('spawnedProcess', (evt) => {
                if (evt.detail.id !== process.id) return;
                
                if (evt.detail.action === 'stdOut' || evt.detail.action === 'stdErr') {
                    const data = evt.detail.data || '';
                    
                    // Try to detect port from output (e.g., "Listening on port 3000" or "http://localhost:3000")
                    const portMatch = data.match(/port\s*(\d{4,5})/i) || 
                                     data.match(/localhost:(\d{4,5})/) ||
                                     data.match(/:(\d{4,5})/);
                    
                    if (portMatch && !detectedPort) {
                        const port = parseInt(portMatch[1]);
                        if (port >= 1000 && port <= 65535) {
                            detectedPort = port;
                            clearTimeout(timeoutId);
                            resolve(port);
                        }
                    }
                }
                
                if (evt.detail.action === 'exit') {
                    clearTimeout(timeoutId);
                    resolve(detectedPort);
                }
            });
            
            // Also poll for port as backup
            const pollInterval = setInterval(async () => {
                if (detectedPort) {
                    clearInterval(pollInterval);
                    return;
                }
                
                const port = await findRunningPort();
                if (port) {
                    detectedPort = port;
                    clearInterval(pollInterval);
                    clearTimeout(timeoutId);
                    resolve(port);
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

async function findRunningPort() {
    for (const port of CONFIG.PORTS) {
        if (await checkPort(port)) return port;
    }
    
    // Try to find any openchamber process and its port
    try {
        const os = window.NL_OS || 'Linux';
        let cmd;
        
        if (os === 'Windows') {
            cmd = `netstat -ano | findstr "LISTENING" | findstr "${CONFIG.APP_NAME}" 2>nul`;
        } else {
            cmd = `ss -tlnp 2>/dev/null | grep "${CONFIG.APP_NAME}" || netstat -tlnp 2>/dev/null | grep "${CONFIG.APP_NAME}"`;
        }
        
        const result = await Neutralino.os.execCommand(cmd);
        const lines = result.stdOut.split('\n');
        
        for (const line of lines) {
            const match = line.match(/:(\d{4,5})/);
            if (match) {
                const port = parseInt(match[1]);
                if (port >= 1000 && port <= 65535) {
                    return port;
                }
            }
        }
    } catch (e) {}
    
    return null;
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
            if (state.port) await Neutralino.os.execCommand(`lsof -ti:${state.port} | xargs kill -9 2>/dev/null || true`);
        }
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
