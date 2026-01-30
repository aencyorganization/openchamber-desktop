#!/usr/bin/env node

/**
 * CLI entry point for openchamber-desktop
 * Detects OS and architecture, then launches the appropriate binary
 * Includes single-instance lock to prevent duplicate dock/taskbar icons
 */

const { spawn, exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const platform = process.platform;
const arch = process.arch;

// Single-instance lock file
const LOCK_FILE = path.join(os.tmpdir(), 'openchamber-desktop.lock');
const LOCK_TIMEOUT = 10000; // 10 seconds

if (process.argv.includes('--install-system')) {
  require('../scripts/install/install.js');
  process.exit(0);
}
if (process.argv.includes('--uninstall-system')) {
  require('../scripts/uninstall/uninstall.js');
  process.exit(0);
}

/**
 * Check if another instance is already running
 */
function checkSingleInstance() {
  try {
    if (fs.existsSync(LOCK_FILE)) {
      const lockData = fs.readFileSync(LOCK_FILE, 'utf8');
      const [pid, timestamp] = lockData.split(':');
      
      // Check if process is still alive
      const isRunning = isProcessRunning(parseInt(pid));
      const isRecent = (Date.now() - parseInt(timestamp)) < LOCK_TIMEOUT;
      
      if (isRunning && isRecent) {
        console.log('OpenChamber Desktop is already running. Focusing existing window...');
        
        // Try to focus existing window based on platform
        focusExistingWindow();
        
        return false;
      }
    }
    
    // Write lock file with current PID and timestamp
    fs.writeFileSync(LOCK_FILE, `${process.pid}:${Date.now()}`);
    
    // Clean up lock file on exit
    process.on('exit', () => {
      try {
        if (fs.existsSync(LOCK_FILE)) {
          fs.unlinkSync(LOCK_FILE);
        }
      } catch (e) {}
    });
    
    // Handle signals
    ['SIGINT', 'SIGTERM', 'SIGHUP'].forEach(signal => {
      process.on(signal, () => {
        try {
          if (fs.existsSync(LOCK_FILE)) {
            fs.unlinkSync(LOCK_FILE);
          }
        } catch (e) {}
        process.exit(0);
      });
    });
    
    return true;
  } catch (e) {
    console.error('Warning: Could not check single instance:', e.message);
    return true; // Allow running if we can't check
  }
}

/**
 * Check if a process is running
 */
function isProcessRunning(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Try to focus existing window
 */
function focusExistingWindow() {
  const platform = process.platform;
  
  try {
    if (platform === 'darwin') {
      // macOS: Use osascript to focus
      exec('osascript -e \'tell application "System Events" to tell process "openchamber-launcher" to set frontmost to true\'');
    } else if (platform === 'win32') {
      // Windows: Use PowerShell to focus window
      exec('powershell -Command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::AppActivate(\'OpenChamber Desktop\')"');
    } else {
      // Linux: Try using xdotool or wmctrl
      exec('xdotool search --name "OpenChamber Desktop" windowactivate 2>/dev/null || wmctrl -a "OpenChamber Desktop" 2>/dev/null || true');
    }
  } catch (e) {
    // Ignore errors from focus attempts
  }
}

// Map platform and arch to binary name
const binaryMap = {
  'linux': {
    'x64': 'neutralino-linux_x64',
    'arm64': 'neutralino-linux_arm64',
    'arm': 'neutralino-linux_armhf'
  },
  'darwin': {
    'x64': 'neutralino-mac_x64',
    'arm64': 'neutralino-mac_arm64'
  },
  'win32': {
    'x64': 'neutralino-win_x64.exe'
  }
};

function getBinaryName() {
  const platformBinaries = binaryMap[platform];
  if (!platformBinaries) {
    console.error(`Unsupported platform: ${platform}`);
    process.exit(1);
  }
  
  const binary = platformBinaries[arch];
  if (!binary) {
    console.error(`Unsupported architecture: ${arch} on ${platform}`);
    console.error('Supported architectures:', Object.keys(platformBinaries).join(', '));
    process.exit(1);
  }
  
  return binary;
}

function main() {
  // Check single instance (unless --new-instance flag is passed)
  if (!process.argv.includes('--new-instance')) {
    if (!checkSingleInstance()) {
      process.exit(0); // Exit gracefully, existing instance will be focused
    }
  }
  
  const binaryName = getBinaryName();
  const binaryPath = path.join(__dirname, binaryName);
  
  // Check if binary exists
  if (!fs.existsSync(binaryPath)) {
    console.error(`Binary not found: ${binaryPath}`);
    console.error('Please run: npm run postinstall');
    process.exit(1);
  }
  
  // Get the app directory (parent of bin/)
  const appDir = path.dirname(__dirname);
  
  // Launch the binary
  const args = [
    '--load-dir-res',
    '--path=.',
    '--export-auth-info'
  ];
  
  console.log('Starting OpenChamber Desktop...');
  
  const child = spawn(binaryPath, args, {
    cwd: appDir,
    stdio: 'inherit'
  });
  
  child.on('error', (err) => {
    console.error('Failed to start:', err.message);
    process.exit(1);
  });
  
  child.on('exit', (code) => {
    process.exit(code);
  });
}

main();
