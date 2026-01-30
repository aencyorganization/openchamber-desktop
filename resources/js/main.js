/**
 * OpenChamber Launcher - Core Logic Improvements
 * Implementation of dynamic port system, configuration, retries, and health checks.
 */

const CONFIG_KEY = 'openchamber_config';
let appConfig = {
    preferredPort: 1504,
    zoomLevel: 1.0,
    windowSize: { width: 1000, height: 800 },
    lastUsedPorts: []
};

let state = { 
    pid: null, 
    port: null, 
    processId: null,
    managedPorts: new Set(),
    isReconnecting: false,
    healthInterval: null
};

const APP_NAME = 'openchamber';
const START_PORT_RANGE = 1504;
const END_PORT_RANGE = 1550;

// 1. Configuration System
function loadConfig() {
    const saved = localStorage.getItem(CONFIG_KEY);
    if (saved) {
        try {
            const parsed = JSON.parse(saved);
            appConfig = { ...appConfig, ...parsed };
        } catch (e) {
            console.error('Failed to load config', e);
        }
    }
}

function saveConfig() {
    localStorage.setItem(CONFIG_KEY, JSON.stringify(appConfig));
}

// 2. Dynamic Port System
async function findAvailablePort(start, end) {
    for (let port = start; port <= end; port++) {
        if (!(await checkPort(port))) {
            return port;
        }
    }
    // Fallback: search for any available port above range
    for (let port = end + 1; port < end + 200; port++) {
        if (!(await checkPort(port))) {
            return port;
        }
    }
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

async function killPort(port) {
    const os = window.NL_OS || 'Linux';
    console.log(`Cleaning up port ${port}`);
    try {
        if (os === 'Windows') {
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
            // Linux/Mac: use lsof and fuser to ensure process is killed
            await Neutralino.os.execCommand(`lsof -ti:${port} | xargs kill -9 2>/dev/null || true`);
            await Neutralino.os.execCommand(`fuser -k ${port}/tcp 2>/dev/null || true`);
        }
    } catch (e) {}
}

// 6. Single Instance Lock
async function checkSingleInstance() {
    const LOCK_KEY = 'openchamber_instance_lock';
    const now = Date.now();
    const lock = localStorage.getItem(LOCK_KEY);
    
    if (lock) {
        try {
            const { timestamp } = JSON.parse(lock);
            // If the lock is less than 10 seconds old, another instance is running
            if (now - timestamp < 10000) {
                console.log('Another instance detected, focusing and exiting...');
                try {
                    await Neutralino.window.show();
                    await Neutralino.window.focus();
                } catch (e) {}
                await Neutralino.app.exit();
                return false;
            }
        } catch (e) {}
    }
    
    // Set lock and start heartbeat
    localStorage.setItem(LOCK_KEY, JSON.stringify({ timestamp: now }));
    setInterval(() => {
        localStorage.setItem(LOCK_KEY, JSON.stringify({ timestamp: Date.now() }));
    }, 5000);
    
    window.addEventListener('unload', () => {
        localStorage.removeItem(LOCK_KEY);
    });
    
    return true;
}

// 7. Version Validation
function compareVersions(v1, v2) {
    const a = String(v1).split('.').map(Number);
    const b = String(v2).split('.').map(Number);
    for (let i = 0; i < 3; i++) {
        const ai = a[i] || 0;
        const bi = b[i] || 0;
        if (ai > bi) return 1;
        if (ai < bi) return -1;
    }
    return 0;
}

// 8. Origin Validation
async function validateOrigin(port) {
    try {
        const response = await fetch(`http://localhost:${port}/`, { method: 'GET', cache: 'no-store' });
        const text = await response.text();
        const hasHeader = response.headers.get('X-OpenChamber') || response.headers.get('Server')?.includes('OpenChamber');
        const hasMeta = text.toLowerCase().includes('openchamber');
        
        if (!hasHeader && !hasMeta) {
            console.error('Origin validation failed: Content does not appear to be OpenChamber');
            return false;
        }
        return true;
    } catch (e) {
        console.error('Origin validation error:', e);
        return false;
    }
}

// 5. Health Check
function startHealthCheck() {
    if (state.healthInterval) clearInterval(state.healthInterval);
    let failures = 0;
    state.healthInterval = setInterval(async () => {
        if (!state.port || state.isReconnecting) return;
        try {
            const controller = new AbortController();
            const id = setTimeout(() => controller.abort(), 2000);
            const res = await fetch(`http://localhost:${state.port}/api/health`, { signal: controller.signal });
            clearTimeout(id);
            
            if (res.ok) {
                failures = 0;
            } else {
                throw new Error('Health check status not OK');
            }
        } catch (e) {
            failures++;
            console.warn(`Health check failure ${failures}/3`);
            if (failures >= 3) {
                state.isReconnecting = true;
                showOverlay('Reconectando...');
                
                // Try to reconnect
                try {
                    await autoStart();
                } catch (reconnectErr) {
                    console.error('Reconnection failed:', reconnectErr);
                } finally {
                    state.isReconnecting = false;
                }
            }
        }
    }, 5000);
}

// 3. Retry with Backoff & Startup Logic
async function autoStart() {
    loadConfig();
    
    let retries = 0;
    const maxRetries = 3;
    let delay = 1000;
    let logs = [];
    
    const addLog = (msg) => {
        const timestamp = new Date().toISOString().split('T')[1].split('.')[0];
        logs.push(`[${timestamp}] ${msg}`);
        console.log(msg);
    };
    
    while (retries <= maxRetries) {
        try {
            if (retries > 0) {
                updateLoadingStep(1, `Tentativa ${retries}/${maxRetries}...`);
                addLog(`Retry attempt ${retries}/${maxRetries} after ${delay}ms`);
                await new Promise(r => setTimeout(r, delay));
                delay *= 2; // Exponential backoff
            } else {
                updateLoadingStep(1, 'Procurando OpenChamber...');
                addLog('Starting OpenChamber...');
            }

            // Step 1: Find available port
            updateLoadingStep(1, 'Procurando porta disponível...');
            const port = await findAvailablePort(appConfig.preferredPort, END_PORT_RANGE);
            if (!port) {
                addLog('ERROR: No available ports found in range');
                retries++;
                continue;
            }
            addLog(`Found available port: ${port}`);

            // Step 2: Spawn process
            updateLoadingStep(2, 'Iniciando servidor...');
            const process = await Neutralino.os.spawnProcess(APP_NAME, {
                env: { PORT: port.toString() }
            });
            
            state.processId = process.id;
            state.pid = process.pid;
            state.port = port;
            state.managedPorts.add(port);
            addLog(`Spawned process PID: ${process.pid} on port ${port}`);
            
            // Step 3: Wait for port to be ready
            updateLoadingStep(3, 'Conectando...');
            let ready = false;
            for (let i = 0; i < 60; i++) { // Poll for 30 seconds
                if (await checkPort(port)) {
                    ready = true;
                    break;
                }
                await new Promise(r => setTimeout(r, 500));
            }

            if (ready) {
                addLog(`Port ${port} is ready`);
                
                // 7. Version Validation
                try {
                    const vRes = await fetch(`http://localhost:${port}/api/version`);
                    const vData = await vRes.json();
                    addLog(`OpenChamber version: ${vData.version}`);
                    if (compareVersions(vData.version, '1.0.0') < 0) {
                        await Neutralino.os.showMessageBox('Warning', `Incompatible OpenChamber version: ${vData.version}. Recommended >= 1.0.0`, 'OK', 'WARNING');
                    }
                } catch (e) {
                    addLog(`Warning: Could not validate version - ${e.message}`);
                }

                // 8. Origin Validation
                addLog('Validating origin...');
                if (await validateOrigin(port)) {
                    addLog('Origin validation passed');
                    
                    // Update config with success info
                    appConfig.lastUsedPorts.push(port);
                    appConfig.lastUsedPorts = [...new Set(appConfig.lastUsedPorts)].slice(-10);
                    saveConfig();
                    
                    // Step 4: Connected
                    updateLoadingStep(4, 'Pronto!');
                    await new Promise(r => setTimeout(r, 500)); // Brief pause to show "Ready"
                    
                    connect(port);
                    return;
                } else {
                    addLog(`ERROR: Origin validation failed on port ${port}`);
                }
            } else {
                addLog(`ERROR: Port ${port} did not become ready in time`);
            }
        } catch (e) {
            addLog(`ERROR: ${e.message}`);
            console.error('Spawn error:', e);
        }
        retries++;
    }
    
    // Show elegant error screen instead of native message box
    showErrorScreen(
        'Falha ao Iniciar',
        'Não foi possível iniciar o OpenChamber. Verifique se está instalado e disponível no PATH.',
        logs.join('\n')
    );
}

function connect(port) {
    const frame = document.getElementById('app-frame');
    frame.src = `http://localhost:${port}`;
    document.getElementById('loading-screen').classList.remove('active');
    document.getElementById('webview-screen').classList.add('active');
    hideOverlay();
    
    applyZoom(appConfig.zoomLevel);
}

// UI Update Functions
function updateLoadingStep(step, message) {
    // Update status text
    const statusEl = document.getElementById('loading-status');
    if (statusEl) statusEl.textContent = message;
    
    // Update progress bar (25% per step)
    const progressEl = document.getElementById('loading-progress');
    if (progressEl) progressEl.style.width = `${step * 25}%`;
    
    // Update step dots
    for (let i = 1; i <= 4; i++) {
        const dot = document.getElementById(`step-${i}`);
        if (dot) {
            if (i <= step) {
                dot.classList.add('active');
            } else {
                dot.classList.remove('active');
            }
        }
    }
    
    console.log(`[Launcher] Step ${step}: ${message}`);
}

function showErrorScreen(title, message, logs = '') {
    document.getElementById('loading-screen').classList.remove('active');
    document.getElementById('error-screen').classList.add('active');
    
    const titleEl = document.getElementById('error-title');
    const msgEl = document.getElementById('error-message');
    const logsEl = document.getElementById('error-logs');
    
    if (titleEl) titleEl.textContent = title || 'Erro ao Iniciar';
    if (msgEl) msgEl.textContent = message || 'Não foi possível estabelecer conexão com o sistema.';
    if (logsEl && logs) {
        logsEl.querySelector('pre').textContent = logs;
    }
    
    // Setup button handlers
    const btnRetry = document.getElementById('btn-retry');
    const btnLogs = document.getElementById('btn-logs');
    const btnQuit = document.getElementById('btn-quit');
    
    if (btnRetry) {
        btnRetry.onclick = async () => {
            document.getElementById('error-screen').classList.remove('active');
            document.getElementById('loading-screen').classList.add('active');
            await autoStart();
        };
    }
    
    if (btnLogs) {
        btnLogs.onclick = () => {
            logsEl.classList.toggle('visible');
            btnLogs.textContent = logsEl.classList.contains('visible') ? 'Ocultar logs' : 'Ver logs';
        };
    }
    
    if (btnQuit) {
        btnQuit.onclick = cleanupAndExit;
    }
}

function showStatus(msg) {
    console.log(`[Launcher] ${msg}`);
    const statusEl = document.getElementById('loading-status');
    if (statusEl) statusEl.textContent = msg;
}

function showOverlay(msg) {
    let overlay = document.getElementById('reconnect-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'reconnect-overlay';
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.width = '100%';
        overlay.style.height = '100%';
        overlay.style.background = 'rgba(0,0,0,0.8)';
        overlay.style.color = 'white';
        overlay.style.display = 'flex';
        overlay.style.alignItems = 'center';
        overlay.style.justifyContent = 'center';
        overlay.style.zIndex = '10000';
        overlay.style.fontFamily = 'sans-serif';
        overlay.innerHTML = `<div style="text-align:center"><div class="spinner"></div><div style="margin-top:15px; font-size: 1.2em;">${msg}</div></div>`;
        document.body.appendChild(overlay);
    }
    overlay.style.display = 'flex';
}

function hideOverlay() {
    const overlay = document.getElementById('reconnect-overlay');
    if (overlay) overlay.style.display = 'none';
}

// 4. Graceful Shutdown
async function cleanupAndExit() {
    const os = window.NL_OS || 'Linux';
    console.log('Cleaning up and exiting...');
    
    // 1. Send SIGTERM (standard termination)
    try {
        if (state.pid) {
            if (os === 'Windows') {
                await Neutralino.os.execCommand(`taskkill /PID ${state.pid} 2>nul`);
            } else {
                await Neutralino.os.execCommand(`kill -15 ${state.pid} 2>/dev/null`);
            }
        }
        if (state.processId) {
            await Neutralino.os.updateSpawnedProcess(state.processId, 'exit');
        }
    } catch (e) {}

    // 2. Wait 3 seconds
    await new Promise(r => setTimeout(r, 3000));

    // 3. Send SIGKILL to all managed ports and the primary PID
    for (const port of state.managedPorts) {
        await killPort(port);
    }

    try {
        if (state.pid) {
            if (os === 'Windows') {
                await Neutralino.os.execCommand(`taskkill /F /PID ${state.pid} 2>nul`);
            } else {
                await Neutralino.os.execCommand(`kill -9 ${state.pid} 2>/dev/null`);
            }
        }
    } catch (e) {}

    try {
        await Neutralino.app.exit();
    } catch (e) {
        window.close();
    }
}

async function exitWithError(msg, title = 'Erro', logs = '') {
    showErrorScreen(title, msg, logs);
}

function applyZoom(level) {
    appConfig.zoomLevel = level;
    document.body.style.zoom = level;
    saveConfig();
}

function setupKeyboardShortcuts() {
    document.addEventListener('keydown', async (e) => {
        const isMac = window.NL_OS === 'Darwin';
        const ctrlKey = isMac ? e.metaKey : e.ctrlKey;
        
        // Fullscreen
        if (e.key === 'F11') {
            e.preventDefault();
            try {
                await Neutralino.window.setFullScreen();
            } catch (err) {}
        }
        
        // Zoom Controls
        if (ctrlKey) {
            if (e.key === '+' || e.key === '=') {
                e.preventDefault();
                applyZoom(Math.min(appConfig.zoomLevel + 0.1, 3.0));
            }
            if (e.key === '-' || e.key === '_') {
                e.preventDefault();
                applyZoom(Math.max(appConfig.zoomLevel - 0.1, 0.5));
            }
            if (e.key === '0') {
                e.preventDefault();
                applyZoom(1.0);
            }
        }
    });
}

// Initialization
document.addEventListener('DOMContentLoaded', async () => {
    if (typeof Neutralino === 'undefined') {
        console.error('Neutralino framework not found');
        return;
    }

    try {
        await Neutralino.init();
        
        loadConfig();
        
        // 6. Single Instance Lock
        if (!(await checkSingleInstance())) return;

        // Apply saved window size
        if (appConfig.windowSize) {
            try {
                await Neutralino.window.setSize(appConfig.windowSize);
            } catch (e) {}
        }

        Neutralino.events.on('windowClose', cleanupAndExit);
        
        Neutralino.events.on('serverOffline', async () => {
             console.error('Neutralino server offline');
             await exitWithError('Connection lost to Neutralino server. Please restart.');
        });
        
        setupKeyboardShortcuts();
        startHealthCheck();
        
        await autoStart();
        
        // Persistent window size tracking
        setInterval(async () => {
            try {
                const size = await Neutralino.window.getSize();
                if (size.width !== appConfig.windowSize.width || size.height !== appConfig.windowSize.height) {
                    appConfig.windowSize = { width: size.width, height: size.height };
                    saveConfig();
                }
            } catch (e) {}
        }, 5000);

    } catch (e) {
        console.error('Initialization error:', e);
    }
});
