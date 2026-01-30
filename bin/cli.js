#!/usr/bin/env node

/**
 * CLI entry point for openchamber-desktop
 * Detects OS and architecture, then launches the appropriate binary
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const platform = process.platform;
const arch = process.arch;

if (process.argv.includes('--install-system')) {
  require('../scripts/install/install.js');
  process.exit(0);
}
if (process.argv.includes('--uninstall-system')) {
  require('../scripts/uninstall/uninstall.js');
  process.exit(0);
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
